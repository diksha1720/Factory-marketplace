// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

interface ICurrencyToken{
    function mint(address to, uint256 tokenId) external;
}