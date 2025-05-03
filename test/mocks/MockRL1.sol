// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

contract MockRL1 {
    uint256 public withdrawableAmount;
    bool public withdrawCalled;
    
    function setWithdrawable(uint256 _amount) external {
        withdrawableAmount = _amount;
    }
    
    function withdrawable(address) external view returns (uint256) {
        return withdrawableAmount;
    }
    
    function withdraw() external {
        withdrawCalled = true;
        withdrawableAmount = 0;
    }
}