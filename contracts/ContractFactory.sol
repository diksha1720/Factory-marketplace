// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./NFTContract.sol";
import "./CurrencyContract.sol";

contract ContractFactory is Ownable{
    address public primaryMarketPlace;
    address public secondaryMarketPlace;

    // Event details and NFT contract addresses
    struct Event {
        string name;
        string description;
        address nftContract;
        address currencyContract;
        address organizer;
        uint ticketPrice;
        uint maxMint;
        uint allowance;
        bytes32 whiteListedUsersRootHash;
    }
    mapping(uint256 => Event) public allEvents;
    uint256 public currentEventId;

    // Events
    event EventCreated(uint256 eventId, string name, address nftContract , address currencyContract);
    event EventUpdated(uint256 eventId, address organizer);
    event OrganizerUpdated(uint256 eventId, address newOrganizer);
    event GlobalVarUpdated();

    constructor() Ownable(msg.sender){
    }

    // Create a new event and deploy corresponding NFT and currency token contracts
    function createEvent(string memory _name, string memory _symbol , string memory _description , uint _ticketPrice, uint _maxMintAllowed , uint _allowance , bytes32  _merkleRootHash) public {
        require(primaryMarketPlace != address(0), "Global var not updated");
        uint256 eventId = ++currentEventId;
        NFTContract nftContract = new NFTContract(_name, _symbol,msg.sender , primaryMarketPlace, secondaryMarketPlace);
        CurrencyContract currencyContract = new CurrencyContract(_name,  _symbol, msg.sender,primaryMarketPlace);
        allEvents[eventId] = Event(_name, _description, address(nftContract) , address(currencyContract) ,  msg.sender, _ticketPrice ,_maxMintAllowed , _allowance ,_merkleRootHash);  
        emit EventCreated(eventId, _name, address(nftContract), address(currencyContract));
    }

    // Update allowance for a whitelisted user
    function updateEvent(uint _eventId ,  uint _ticketPrice, uint _maxMintAllowed , uint _allowance , bytes32 _merkleRootHash) external  {
        Event storage _currentEvent = allEvents[_eventId];
        require(_currentEvent.nftContract != address(0), "invalid event id");
        require(_currentEvent.organizer == msg.sender, "only organizer can update events");
        _currentEvent.ticketPrice = _ticketPrice;
        _currentEvent.maxMint = _maxMintAllowed;
        _currentEvent.allowance = _allowance;
        _currentEvent.whiteListedUsersRootHash = _merkleRootHash;
        emit EventUpdated(_eventId , msg.sender);
    }

    // Get event details by ID
    function getEventDetails(uint256 _eventId) external view returns (Event memory) {
        return allEvents[_eventId] ;
    }

    function changeOrganizer(address _organizer , uint _eventId) external {
        Event storage _currentEvent = allEvents[_eventId];
        require(_currentEvent.nftContract != address(0), "invalid event id");
        require(_currentEvent.organizer == msg.sender, "only organizer can update events");
        _currentEvent.organizer = _organizer;
        emit OrganizerUpdated(_eventId,_organizer );
    }

    function isWhiteListed(uint256 _eventId, address _user , bytes32[] memory _proof) external view returns(bool){
        bytes32 leaf = keccak256(abi.encodePacked(_user));
        return MerkleProof.verify(_proof, allEvents[_eventId].whiteListedUsersRootHash, leaf);
    }

    //INITILIZATION 
    function setGlobalVar(address _primaryMarketPlace, address _secondaryMarketPlace ) public onlyOwner{
        primaryMarketPlace = _primaryMarketPlace;
        secondaryMarketPlace = _secondaryMarketPlace;
        emit GlobalVarUpdated();
    }

}
