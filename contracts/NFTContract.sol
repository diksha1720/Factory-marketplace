// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "hardhat/console.sol";


contract NFTContract is ERC721, Ownable {

    address primaryMarketPlace;
    address secondaryMarketPlace;

    uint public currentTokenId ;

    constructor(string memory name , string memory symbol , address initialOwner , address _primaryMarketPlace, address _secondaryMarketPlace)
        ERC721(name, symbol)
        Ownable(initialOwner)
    {
        primaryMarketPlace = _primaryMarketPlace;
        secondaryMarketPlace = _secondaryMarketPlace;
    }

    /// @notice function to mint NFT tokens
    /// @param to address of the minter
    /// @param amount number of NFTs to be minted
    /// @dev can only be called from the primary or secondary marketplace contract
    function safeMint(address to, uint256 amount) external  {
        require(msg.sender == primaryMarketPlace || msg.sender == secondaryMarketPlace, "Unauthorized acces");
        for(uint i=0;i<amount;i++){
            _safeMint(to, ++currentTokenId);
        }
    }

    /// @notice returns the total NFTs minted till now
    function getCurrentMintedTokenId() external view returns(uint){
        return currentTokenId;
    }

}