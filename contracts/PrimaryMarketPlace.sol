// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./ContractFactory.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Interfaces/INFTContract.sol";
import "./Interfaces/ICurrencyToken.sol";
import "hardhat/console.sol";


contract PrimaryMarketPlace is Ownable{

    ContractFactory contractFactory;    

    constructor() Ownable(msg.sender){
    }

    mapping(address => uint) tokenMintsByAddress;
    mapping(address => uint) nftMintsByAddress;
    //useraddress => currencyaddress => amount
    mapping(address => mapping(address => uint)) tokensOwnedByUser;

    event NFTMinted(address minter, uint fromTokenId , uint toTokenId );
    event TokensMinted(address minter , uint amount);

    function mintTokens(uint256 _eventId,uint256 _amount , bytes32[] memory _proof ) public {
        require(contractFactory.isWhiteListed(_eventId , msg.sender , _proof), "Not whitelisted");
        ContractFactory.Event memory _currentEvent = contractFactory.getEventDetails(_eventId);
        require(tokenMintsByAddress[msg.sender] + _amount  <= _currentEvent.allowance , "mint amount exceeds allowance") ;
        tokenMintsByAddress[msg.sender] += _amount;
        ICurrencyToken(_currentEvent.currencyContract).mint(msg.sender, _amount);
        // ICurrencyToken(_currentEvent.currencyContract).mint(address(this), _amount);
        emit TokensMinted(msg.sender, _amount);
    }

    // Mint a new NFT ticket (called by Factory contract)
    function mintNFT(uint256 _eventId,uint256 _amount ,  bytes32[] memory _proof) public {
        require(contractFactory.isWhiteListed(_eventId , msg.sender, _proof), "Not whitelisted");
        ContractFactory.Event memory _currentEvent = contractFactory.getEventDetails(_eventId);
        require(nftMintsByAddress[msg.sender] + _amount  <= _currentEvent.maxMint , "mint amount exceeds allowance");
        address nftContract = _currentEvent.nftContract;
        address currencyContract = _currentEvent.currencyContract;
        uint tokenBalanceOfUser = IERC20(currencyContract).balanceOf(msg.sender);
        uint totalCost = _amount * _currentEvent.ticketPrice;
        require(totalCost <= tokenBalanceOfUser , "insufficient funds");
        nftMintsByAddress[msg.sender]+=_amount;
        tokensOwnedByUser[msg.sender][currencyContract] += totalCost;
        address  _minter = msg.sender;
        IERC20(currencyContract).transferFrom( _minter ,_currentEvent.organizer, totalCost);
        uint prevTokenId = INFTContract(nftContract).getCurrentMintedTokenId();
        INFTContract(nftContract).safeMint(_minter, _amount);
        uint aftTokenId = INFTContract(nftContract).getCurrentMintedTokenId();
        emit NFTMinted(msg.sender , ++prevTokenId , aftTokenId);
    }


    function addFactoryContract(address _factory) external onlyOwner{
        contractFactory = ContractFactory(_factory);
    }

    function withDrawTokensByOrganizer(uint amount, address _currencyContract) external {
        require(amount > tokensOwnedByUser[msg.sender][_currencyContract], "withdrawal amount exceeds balance");
        tokensOwnedByUser[msg.sender][_currencyContract] -= amount;
        IERC20(_currencyContract).transferFrom(address(this), msg.sender, amount);
    }

}
