// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

contract MockKongPromise {
    uint256 private _totalSupply;
    
    function setTotalSupply(uint256 amount) external {
        _totalSupply = amount;
    }
    
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    
    function deposit() external payable {
        // Accept ETH
    }
    
    // Fallback to accept ETH directly
    receive() external payable {}
}