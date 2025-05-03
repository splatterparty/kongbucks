// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

interface IRL1 {

    function withdrawable(address guy) external view returns (uint);

    function withdraw() external;

}