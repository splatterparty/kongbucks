// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

interface IStaking {

    /**
    * @notice Lock tokens and mint Stake tokens.
    * @param _days The number of days to lock the tokens for.
    */
    function lock(uint16 _days) external payable;

    /**
    * @notice Unlock locked tokens for the caller.
    * @param _day The day to unlock tokens for.
    */
    function unlock(uint16 _day) external;

    /**
    *@notice claim all function for Will.
    *
    */
    function claimAll() external;


    /**
    * @notice Claim RL1 tokens for a specific day.
    * @param _day The day to claim RL1 tokens for.
    */
    function claimRL1(uint16 _day) external;

    /**
    * @notice Claim RL1 tokens for a range of days.
    * @param _start The start day of the range.
    * @param _end The end day of the range.
    */
    function claimRL1Range(uint16 _start, uint16 _end) external;

    /**
    * @notice Get the current day.
    * @return The current day.
    */
    function today() external view returns (uint16);

}

