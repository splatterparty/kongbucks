// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AppStorage, LibAppStorage } from "../libs/LibAppStorage.sol";

import { LibERC20 } from "../libs/LibERC20.sol";
import { LibConstants } from "../libs/LibConstants.sol";

error DiamondAlreadyInitialized();

contract InitDiamond {
  event InitializeDiamond(address sender);

  function init() external {
    AppStorage storage s = LibAppStorage.diamondStorage();
    if (s.diamondInitialized) {
      revert DiamondAlreadyInitialized();
    }
    s.diamondInitialized = true;

    /*
        TODO: add custom initialization logic here
    */

    // mint to the deployer
    LibERC20.mint(msg.sender, LibConstants.INITIAL_SUPPLY);



    emit InitializeDiamond(msg.sender);
  }
}
