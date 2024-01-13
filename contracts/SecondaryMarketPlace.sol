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
    uint public organizerFeePercent;

    mapping(address =>  mapping( uint => NFTList)) allNFTListings;

    event NFTListed(address nftContract,uint tokenId , address listingUserAddress , uint _price);
    event NFTBought(address nftContract,uint tokenId , address buyerAddress);

    /// @notice function to list an NFT for sale by the nftOwner
    /// @param _eventId event Id of the event for which the NFT collection was created
    /// @param _tokenId tokenId of the NFT to be listed for sale
    /// @param _price losting price of the NFT 
    /// @dev function can only be called by the owner of the NFT
    function listNFT(uint256 _eventId, uint256 _tokenId, uint256 _price) external {
        ContractFactory.Event memory _currentEvent = contractFactory.getEventDetails(_eventId);
        require(IERC721(_currentEvent.nftContract).ownerOf(_tokenId) == msg.sender, "Not the owner");
        NFTList storage _newListing = allNFTListings[_currentEvent.nftContract][_tokenId];
        if(_newListing.prevPrice!=0){
            require(_price <= _newListing.prevPrice  , "listing price can't exceed mint price");
        }
        _newListing.eventId = _eventId;
        _newListing.seller = msg.sender;
        _newListing.currentOwner =  address(0);
        _newListing.isListed = true;
        _newListing.price = _price;
        emit NFTListed(_currentEvent.nftContract,_tokenId , msg.sender , _price);
    }

    /// @notice function to buy a listed NFT
    /// @param _nftContract contract address of the NFT collection
    /// @param _tokenId token Id of the NFT to be bought
    /// @dev function can be called by any end user
    function buyNFT(address _nftContract , uint _tokenId) external payable {
        NFTList storage _nftListing = allNFTListings[_nftContract][_tokenId];
        require(_nftListing.isListed , "NFT not listed");
        ContractFactory.Event memory _currentEvent = contractFactory.getEventDetails(_nftListing.eventId);
        require(msg.value >= _nftListing.price , "Insufficient funds");
        _nftListing.isListed = false;
        _nftListing.prevPrice = _nftListing.price;
        _nftListing.price = 0;
        _nftListing.currentOwner = msg.sender;
        (uint organizerFee, uint sellerFee) = _calculateFee(_nftListing.price);
        IERC721(_currentEvent.nftContract).safeTransferFrom(_nftListing.seller, msg.sender, _tokenId);
        IERC20(_currentEvent.currencyContract).transfer(_currentEvent.organizer, organizerFee);
        IERC20(_currentEvent.currencyContract).transfer(_nftListing.seller, sellerFee);
        emit NFTBought(_currentEvent.nftContract,_tokenId , msg.sender);
    }

    /// @notice function to calculate the percent fee for the organizer and the owner on the sale of NFTs
    /// @param _price original sale price of the NFT
    /// @return calculated fee for the organizer
    /// @return calculated fee for the seller
    /// @dev internal function , can be called only from within the contract
    function _calculateFee(uint _price) internal view returns(uint , uint ){
        uint organizerFee = _price * organizerFeePercent / 100 ;
        uint sellerFee = _price - organizerFee;
        return(organizerFee, sellerFee);
    }

    /// @notice function to get nft listing details
    /// @param _nftContract contract address of the nft contract
    /// @param _tokenId token id of the nft isted
    /// @dev external read only function
    function getNFTListingDetails(address _nftContract , uint _tokenId) external view returns(NFTList memory){
        return allNFTListings[_nftContract][_tokenId];
    }

    /// @notice function to set the percent fee for the organizer for NFT sales
    /// @param _percent decided percent fee for the organizer
    /// @dev this function should be called post deployment and before any execution
    /// @dev only admin can call this function
    function setOrganizerFeePercent(uint _percent) external onlyOwner{
        organizerFeePercent = _percent;
    } 

    /// @notice function to add the factory contract address
    /// @param _factory address of the factory contract 
    /// @dev this function should be called post deployment and before any execution
    /// @dev only admin can call this function
    function addFactoryContract(address _factory) external onlyOwner{
        contractFactory = ContractFactory(_factory);
    }

}
