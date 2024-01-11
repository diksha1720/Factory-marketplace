// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

interface INFTContract{
    function safeMint(address to, uint256 amount) external;
    function getCurrentMintedTokenId() external view returns(uint);
    function approve(address _user  , uint _tokenId) external;
}