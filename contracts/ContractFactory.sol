// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./NFTContract.sol";
import "./CurrencyContract.sol";

contract ContractFactory is Ownable{
    address public primaryMarketPlace;
    address public secondaryMarketPlace;

    struct Event {
        address nftContract;
        address currencyContract;
        address organizer;
        uint ticketPrice;
        uint maxMint;
        uint allowance;
        bytes32 whiteListedUsersRootHash;
    }
    mapping(uint256 => Event) public allEvents;

    // Events
    event NewEventCreated(uint256 eventId, string name, address nftContract , address currencyContract);
    event EventUpdated(uint256 eventId, address organizer);
    event OrganizerUpdated(uint256 eventId, address newOrganizer);
    event GlobalVarUpdated();

    error GlobalVarNotUpdated();
    error InvalidEventId();
    error InvalidOrganizer();

    constructor() Ownable(msg.sender){
    }

    /// @notice function to create a new event and deploy corresponding NFT and currency token contracts
    /// @param _name name of the NFT Token / Currency Token
    /// @param _symbol symbol of the NFT Token
    /// @param _ticketPrice price of the NFT
    /// @param _maxMintAllowed maximum NFT mints allowed to a whitelisted address
    /// @param _allowance maximum currency mints allowed to a whitelisted address
    /// @param _merkleRootHash merkle root hash for whitelisted users
    /// @dev the organizers need to call this function to add an event
    function createEvent(uint eventId , string memory _name, string memory _symbol , uint _ticketPrice, uint _maxMintAllowed , uint _allowance , bytes32  _merkleRootHash) external {
        if(primaryMarketPlace == address(0)){
            revert GlobalVarNotUpdated();
        } 
        NFTContract nftContract = new NFTContract(_name, _symbol,msg.sender , primaryMarketPlace, secondaryMarketPlace);
        CurrencyContract currencyContract = new CurrencyContract(_name,  _symbol, msg.sender,primaryMarketPlace);
        allEvents[eventId] = Event(address(nftContract) , address(currencyContract) ,  msg.sender, _ticketPrice ,_maxMintAllowed , _allowance ,_merkleRootHash);  
        emit NewEventCreated(eventId, _name, address(nftContract), address(currencyContract));
    }

    /// @notice function to create a new event and deploy corresponding NFT and currency token contracts
    /// @param _eventId event Id of the event to be updated
    /// @param _ticketPrice updated price of NFT
    /// @param _maxMintAllowed updated maximum NFT mints allowed to a whitelisted address
    /// @param _allowance updated maximum currency mints allowed to a whitelisted address
    /// @param _merkleRootHash updated merkle root hash for whitelisted users
    /// @dev only organizers of that particular event can update existing event
    function updateEvent(uint _eventId ,  uint _ticketPrice, uint _maxMintAllowed , uint _allowance , bytes32 _merkleRootHash) external  {
        Event storage _currentEvent = allEvents[_eventId];
        if(_currentEvent.nftContract == address(0))
        {
            revert InvalidEventId();
        }
        if(_currentEvent.organizer != msg.sender)
        {
            revert InvalidOrganizer();
        }
        _currentEvent.ticketPrice = _ticketPrice;
        _currentEvent.maxMint = _maxMintAllowed;
        _currentEvent.allowance = _allowance;
        _currentEvent.whiteListedUsersRootHash = _merkleRootHash;
        emit EventUpdated(_eventId , msg.sender);
    }

    /// @notice function to update the organizer of the event
    /// @param _organizer the new organizer address
    /// @param _eventId event Id of the event for which the details needs to be fetched
    /// @dev only organizers of that particular event can update the organizer
    function changeOrganizer(address _organizer , uint _eventId) external {
        Event storage _currentEvent = allEvents[_eventId];
        if(_currentEvent.nftContract == address(0))
        {
            revert InvalidEventId();
        }       
         if(_currentEvent.organizer != msg.sender)
        {
            revert InvalidOrganizer();
        }
         _currentEvent.organizer = _organizer;
        emit OrganizerUpdated(_eventId,_organizer );
    }

    /// @notice read function to get event details
    /// @param _eventId event Id of the event for which the details needs to be fetched
    /// @return returns the Event struct with event details
    function getEventDetails(uint256 _eventId) external view returns (Event memory) {
        return allEvents[_eventId] ;
    }


    /// @notice function to check whether an address is whitelisted or not
    /// @param _eventId event Id of the event for which the details needs to be fetched
    /// @param _user address of the end user to be verified
    /// @param _proof proof for the merkle tree root verification
    function isWhiteListed(uint256 _eventId, address _user , bytes32[] memory _proof) external view returns(bool){
        bytes32 leaf = keccak256(abi.encodePacked(_user));
        return MerkleProof.verify(_proof, allEvents[_eventId].whiteListedUsersRootHash, leaf);
    }


    /// @notice function to initialize the variables in the current contract
    /// @param _primaryMarketPlace primary market place contract address
    /// @param _secondaryMarketPlace secondart market place contract address
    /// @dev this fucntion should be called post deployment and before any execution
    /// @dev only admin can call this function
    function setGlobalVar(address _primaryMarketPlace, address _secondaryMarketPlace ) external onlyOwner{
        primaryMarketPlace = _primaryMarketPlace;
        secondaryMarketPlace = _secondaryMarketPlace;
        emit GlobalVarUpdated();
    }

}