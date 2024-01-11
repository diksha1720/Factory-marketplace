// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";


contract NFTContract is ERC721, Ownable {

    address primaryMarketPlace;
    address secondaryMarketPlace;

    uint public tokenId ;

    constructor(string memory name , string memory symbol , address initialOwner , address _primaryMarketPlace, address _secondaryMarketPlace)
        ERC721(name, symbol)
        Ownable(initialOwner)
    {
        primaryMarketPlace = _primaryMarketPlace;
        secondaryMarketPlace = _secondaryMarketPlace;
    }

    function safeMint(address to, uint256 amount) external  {
        require(msg.sender == primaryMarketPlace || msg.sender == secondaryMarketPlace, "Unauthorized acces");
        for(uint i=0;i<amount;i++){
            _safeMint(to, ++tokenId);
        }
    }

    function getCurrentMintedTokenId() external view returns(uint){
        return tokenId;
    }

}