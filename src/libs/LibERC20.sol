// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AppStorage, LibAppStorage } from "./LibAppStorage.sol";

error InsufficientBalance(address sender);

library LibERC20 {

  event Transfer(address indexed from, address indexed to, uint256 value);
  
  function transfer(address from, address to, uint256 amount) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();

    if (amount > s.balances[from]) {
      revert InsufficientBalance(from);
    }

    s.balances[from] -= amount;
    s.balances[to] += amount;

    emit Transfer(from, to, amount);
  }

  function mint(address to, uint256 amount) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();
    s.totalSupply += amount;
    s.balances[to] += amount;
    emit Transfer(address(0), to, amount);
  }  

  function burn(address from, uint256 amount) internal {
    AppStorage storage s = LibAppStorage.diamondStorage();
    if (s.balances[from] < amount) {
      revert InsufficientBalance(from);
    }
    s.totalSupply -= amount;
    s.balances[from] -= amount;
    emit Transfer(from, address(0), amount);  
  }  
}
