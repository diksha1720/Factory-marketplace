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

    //useraddress => contractaddress => amountoftokensowned
     mapping(address => mapping(address => uint)) tokenMintsByAddress;
     mapping(address => mapping(address => uint)) nftMintsByAddress;
    
    event NFTMinted(address minter, uint fromTokenId , uint toTokenId );
    event TokensMinted(address minter , uint amount);

    /// @notice function to mint tokens by whitelisted user
    /// @param _eventId event Id of the event of which the token collection was a part of
    /// @param _amount no of tokens to be minted
    /// @param _proof proof array of the whitelisted address for the merkle tree
    /// @dev only whitelisted users for the contarct can call this function
    function mintTokens(uint256 _eventId,uint256 _amount , bytes32[] memory _proof ) external {
        require(contractFactory.isWhiteListed(_eventId , msg.sender , _proof), "Not whitelisted");
        ContractFactory.Event memory _currentEvent = contractFactory.getEventDetails(_eventId);
        require(tokenMintsByAddress[msg.sender][_currentEvent.currencyContract] + _amount  <= _currentEvent.allowance , "mint amount exceeds allowance") ;
        tokenMintsByAddress[msg.sender][_currentEvent.currencyContract] += _amount;
        ICurrencyToken(_currentEvent.currencyContract).mint(msg.sender, _amount);
        emit TokensMinted(msg.sender, _amount);
    }

    /// @notice function to mint NFTs by whitelisted addresses 
    /// @param _eventId event Id of the event of which the NFT collection was a part of
    /// @param _amount no of NFTs to be minted
    /// @param _proof proof array of the whitelisted address for the merkle tree
    /// @dev only whitelisted users for the contarct can call this function
    function mintNFT(uint256 _eventId,uint256 _amount ,  bytes32[] memory _proof) external {
        require(contractFactory.isWhiteListed(_eventId , msg.sender, _proof), "Not whitelisted");
        ContractFactory.Event memory _currentEvent = contractFactory.getEventDetails(_eventId);
        address nftContract = _currentEvent.nftContract;
        address currencyContract = _currentEvent.currencyContract;
        require(nftMintsByAddress[msg.sender][nftContract] + _amount  <= _currentEvent.maxMint , "mint amount exceeds allowance");
        uint tokenBalanceOfUser = IERC20(currencyContract).balanceOf(msg.sender);
        uint totalCost = _amount * _currentEvent.ticketPrice;
        require(totalCost <= tokenBalanceOfUser , "insufficient funds");
        nftMintsByAddress[msg.sender][nftContract]+=_amount;
        address  _minter = msg.sender;
        IERC20(currencyContract).transferFrom( _minter ,_currentEvent.organizer, totalCost);
        uint prevTokenId = INFTContract(nftContract).getCurrentMintedTokenId();
        INFTContract(nftContract).safeMint(_minter, _amount);
        uint aftTokenId = INFTContract(nftContract).getCurrentMintedTokenId();
        emit NFTMinted(msg.sender , ++prevTokenId , aftTokenId);
    }

    /// @notice function to add the factory contract address
    /// @param _factory address of the factory contract 
    /// @dev this function should be called post deployment and before any execution
    /// @dev only admin can call this function
    function addFactoryContract(address _factory) external onlyOwner{
        contractFactory = ContractFactory(_factory);
    }

}
