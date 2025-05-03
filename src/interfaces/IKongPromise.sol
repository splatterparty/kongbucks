// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { IERC20 } from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IKongPromise is IERC20 {

    function mint(address to, uint256 amount) external;

    function deposit() external payable;

}