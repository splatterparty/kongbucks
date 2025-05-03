// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

library LibConstants {

    string public constant NAME = "Kongbucks";
    
    string public constant SYMBOL = "KB";
    
    uint8 public constant DECIMALS = 18;

    uint256 public constant INITIAL_SUPPLY = 250000 * 10**DECIMALS;

    uint256 public constant INITIAL_PRICE = 0.0001 ether;
    
    uint256 public constant PRICE_INCREMENT = 0.0000001 ether;

}

