// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContractFactory.sol";
import "./NFTContract.sol";
import "./Interfaces/INFTContract.sol";
import "hardhat/console.sol";


contract SecondaryMarketPlace is Ownable {

    ContractFactory contractFactory;    

    constructor() Ownable(msg.sender){
    }

    struct NFTList{
        uint eventId;
        address seller;
        address currentOwner;
        bool isListed;
        uint prevPrice;
        uint price;
    }
    uint public listingId ;
    uint public organizerFeePercent;

    mapping(address =>  mapping( uint => NFTList)) allNFTListings;

    event NFTListed(address nftContract,uint tokenId , address listingUserAddress);
    event NFTBought(address nftContract,uint tokenId , address buyerAddress);

    // List an NFT for sale
    function listNFT(uint256 _eventId, uint256 _tokenId, uint256 _price) public {
        ContractFactory.Event memory _currentEvent = contractFactory.getEventDetails(_eventId);
        require(IERC721(_currentEvent.nftContract).ownerOf(_tokenId) == msg.sender, "Not the owner");
        NFTList storage _newListing = allNFTListings[_currentEvent.nftContract][_tokenId];
        if(_newListing.prevPrice==0){
            _newListing.prevPrice =  _currentEvent.ticketPrice;
        }
        require(_price <= _newListing.prevPrice  , "listing price can't exceed mint price");
        _newListing.eventId = _eventId;
        _newListing.seller = msg.sender;
        _newListing.currentOwner =  address(0);
        _newListing.isListed = true;
        _newListing.price = _price;
        emit NFTListed(_currentEvent.nftContract,_tokenId , msg.sender );
    }

    // Buy a listed NFT
    function buyNFT(address _nftContract , uint _tokenId) public payable {
        NFTList storage _nftListing = allNFTListings[_nftContract][_tokenId];
        require(_nftListing.isListed , "NFT not listed");
        ContractFactory.Event memory _currentEvent = contractFactory.getEventDetails(_nftListing.eventId);
        require(msg.value >= _nftListing.price , "Insufficient funds");
        // require(IERC20(_currentEvent.currencyContract).balanceOf(msg.sender) >= _nftListing.price, "Insufficient funds");
        _nftListing.isListed = false;
        _nftListing.prevPrice = _nftListing.price;
        _nftListing.price = 0;
        _nftListing.currentOwner = msg.sender;
        (uint organizerFee, uint sellerFee) = calculateFee(_nftListing.price);
        IERC721(_currentEvent.nftContract).safeTransferFrom(_nftListing.seller, msg.sender, _tokenId);
        IERC20(_currentEvent.currencyContract).transfer(_currentEvent.organizer, organizerFee);
        IERC20(_currentEvent.currencyContract).transfer(_nftListing.seller, sellerFee);
        emit NFTBought(_currentEvent.nftContract,_tokenId , msg.sender );
    }

    function calculateFee(uint _price) internal view returns(uint , uint ){
        uint organizerFee = _price * organizerFeePercent / 100 ;
        uint sellerFee = _price - organizerFee;
        return(organizerFee, sellerFee);
    }

    function addFactoryContract(address _factory) external onlyOwner{
        contractFactory = ContractFactory(_factory);
    }

    function getNFTListingDetails(address _nftContract , uint _tokenId) external view returns(NFTList memory){
        return allNFTListings[_nftContract][_tokenId];
    }

    function setOrganizerFeePercent(uint _percent) external onlyOwner{
        organizerFeePercent = _percent;
    } 

}
