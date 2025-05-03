// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibAppStorage } from "../libs/LibAppStorage.sol";
import { LibConstants } from "../libs/LibConstants.sol";
import { LibERC20 } from "../libs/LibERC20.sol";
import { LibBondingCurve } from "../libs/LibBondingCurve.sol";
import { AccessControl } from "../shared/AccessControl.sol";

error InsufficientValueToMint();
error CantMintMoreThanMaxSupply();
error CantBurnMoreThanInitialSupply();
error InsufficientBalanceToBurn();
error InsufficientValueForReward();

error CantAdminMintMoreThanInitialSupply();

contract MintFacet is AccessControl {

  function getPrice(uint256 supply) external pure returns (uint256) {
    return LibBondingCurve.getPrice(supply);
  }

  //check price to mint
  function priceToMint(uint256 amount) external view returns (uint256) {
    return LibBondingCurve.priceToMint(amount);
  }

  function mint(uint256 amount) external payable {

    uint256 price = LibBondingCurve.priceToMint(amount);

    if (msg.value < price) {
      revert InsufficientValueToMint();
    }

    LibERC20.mint(msg.sender, amount);

    if (msg.value > price) {
      payable(msg.sender).transfer(msg.value - price);
    }
  }

  function rewardForBurn(uint256 amount) external view returns (uint256) {
    return LibBondingCurve.rewardForBurn(amount);
  }

  function burn(uint256 amount) external {

    // check if sender has enough KB to burn
    if (amount > LibAppStorage.diamondStorage().balances[msg.sender]) {
      revert InsufficientBalanceToBurn();
    }

    // can't burn more than initial supply of KB
    uint256 currentSupply = LibAppStorage.diamondStorage().totalSupply;
    if (currentSupply - amount < LibConstants.INITIAL_SUPPLY) {
      revert CantBurnMoreThanInitialSupply();
    }

    uint256 reward = LibBondingCurve.rewardForBurn(amount);

    LibERC20.burn(msg.sender, amount);

    uint256 balanceAmount = address(this).balance;

    if (balanceAmount < reward) {

      //send available balance
      payable(msg.sender).transfer(balanceAmount);
      
      //mint remainder as IOU tokens instead
      uint256 iouAmount = reward - balanceAmount;
      LibAppStorage.diamondStorage().kpn.mint(msg.sender, iouAmount);
  
    }
    else {    
      payable(msg.sender).transfer(reward);
    }

  }


}
