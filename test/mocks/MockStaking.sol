// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

contract MockStaking {
    bool public rewardsAvailable;
    bool public claimAllCalled;
    bool public lockCalled;
    uint256 public lockedAmount;
    uint256 public lockDuration;
    
    function setRewardsAvailable(bool _available) external {
        rewardsAvailable = _available;
    }
    
    function claimAll() external {
        claimAllCalled = true;
    }

    function claimRL1Range(uint16 /*_start*/, uint16 /*_end*/) external
    {
        claimAllCalled = true;
    }
    
    function lock(uint16 _days) external payable {
        lockCalled = true;
        lockedAmount += msg.value;
        lockDuration = _days;
    }

    function today() external pure returns (uint16)
    {
        return 1;
    }

}