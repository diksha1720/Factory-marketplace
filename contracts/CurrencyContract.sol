// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CurrencyContract is ERC20, Ownable {

    address primaryMarketPlace;

    constructor(string memory name , string memory symbol ,address initialOwner, address _primaryMarketPlace)
        ERC20(name, symbol)
        Ownable(initialOwner)
    {
         primaryMarketPlace = _primaryMarketPlace;
    }

    function mint(address to, uint256 amount) public  {
        require(msg.sender == primaryMarketPlace, "Unauthorized access");
        _mint(to, amount);
    }
}
