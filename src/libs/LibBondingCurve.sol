// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibAppStorage } from "./LibAppStorage.sol";
import { LibConstants } from "./LibConstants.sol";

library LibBondingCurve {

  function getPrice(uint256 supply) internal pure returns (uint256) {
    //simple linear curve
    if (supply < LibConstants.INITIAL_SUPPLY) {
      return LibConstants.INITIAL_PRICE;
    }

    return LibConstants.INITIAL_PRICE + (supply - LibConstants.INITIAL_SUPPLY) / (10 ** LibConstants.DECIMALS) * LibConstants.PRICE_INCREMENT;
  }

  function priceToMint(uint256 amount) internal view returns (uint256) {
    uint256 currentSupply = LibAppStorage.diamondStorage().totalSupply;
    uint256 a = getPrice(currentSupply);
    uint256 b = getPrice(currentSupply + amount);
    uint256 totalPrice = (amount * (a + b) / 2)  / (10 ** LibConstants.DECIMALS);
    return totalPrice;
  }

  function rewardForBurn(uint256 amount) internal view returns (uint256) {
    uint256 currentSupply = LibAppStorage.diamondStorage().totalSupply;
    if (currentSupply - amount < LibConstants.INITIAL_SUPPLY) {
      return 0;
    }
    uint256 a = getPrice(currentSupply);
    uint256 b = getPrice(currentSupply - amount);
    uint256 totalReward = ((amount * (a + b)) / 2) / (10 ** LibConstants.DECIMALS);
    return totalReward;
  }

}
