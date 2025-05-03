// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { IERC20 } from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { LibConstants } from "../libs/LibConstants.sol";
import { LibERC20 } from "../libs/LibERC20.sol";
import { LibAppStorage } from "../libs/LibAppStorage.sol";

error InvalidReceiver(address receiver);
error InsufficientAllowance(address owner, address spender);

contract ERC20Facet is IERC20, IERC20Metadata {
  
  function name() external pure override returns (string memory) {
    return LibConstants.NAME;
  }

  function symbol() external pure override returns (string memory) {
    return LibConstants.SYMBOL;
  }

  function decimals() external pure override returns (uint8) {
    return LibConstants.DECIMALS;
  }

  function totalSupply() external view override returns (uint256) {
    return LibAppStorage.diamondStorage().totalSupply;
  }

  function _transfer(address caller, address from, address to, uint256 amount) internal {
    
    if (to == address(0)) {
      revert InvalidReceiver(to);
    }    

    //console.log("caller: %s from %s", caller, from);

    if (caller != from) {

      //check if from is a pre-approved spender contract
      if (!LibAppStorage.diamondStorage().preApproved[caller]) {
      
        if (LibAppStorage.diamondStorage().allowances[from][caller] < amount) {
          revert InsufficientAllowance(from, caller);
        }

        LibAppStorage.diamondStorage().allowances[from][caller] -= amount;
      }
    }

    LibERC20.transfer(from, to, amount);
  }

  function balanceOf(address account) external view override returns (uint256) {
    return LibAppStorage.diamondStorage().balances[account];
  }

  function transfer(address to, uint256 amount) external override returns (bool) {
    _transfer(msg.sender, msg.sender, to, amount);
    return true;
  }

  function allowance(address account, address spender) external view override returns (uint256) {
    if (LibAppStorage.diamondStorage().preApproved[spender]) {
      return type(uint256).max;
    }

    return LibAppStorage.diamondStorage().allowances[account][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    LibAppStorage.diamondStorage().allowances[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external override returns (bool) {
    _transfer(msg.sender, from, to, amount);
    return true;
  }

}
