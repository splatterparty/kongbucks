// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {TestBaseContract} from "./utils/TestBaseContract.sol";
import {MockStaking} from "./mocks/MockStaking.sol";
import {MockRL1} from "./mocks/MockRL1.sol";
import {MockKongPromise} from "./mocks/MockKongPromise.sol";
import {LibConstants} from "../src/libs/LibConstants.sol";

import {CallerMustBeAdminError} from "../src/shared/AccessControl.sol";

contract TestStaking is TestBaseContract {
    MockStaking public mockStaking;
    MockRL1 public mockRL1;
    MockKongPromise public mockKPN;

    function setUp() public override {
        super.setUp();
        
        //fund account1 with 1000 ether
        vm.deal(account1, 1000 ether);

        // Deploy mock contracts
        mockStaking = new MockStaking();
        mockRL1 = new MockRL1();
        mockKPN = new MockKongPromise();
        
        // Setup staking configuration
        diamond.setupStaking(address(mockStaking), address(mockRL1), address(mockKPN));
        
        // Set min threshold to 20%
        diamond.setMinStakingThreshold(20);

        //mint kongbucks to account1
        vm.startPrank(account1);
        uint256 price = diamond.priceToMint(1000 ether);
        diamond.mint{ value: price }(1000 ether);
        vm.stopPrank();
    }
        
       
    function testProcessStaking_ClaimRewards() public {
        // Setup mock to simulate rewards
        mockStaking.setRewardsAvailable(true);
        
        // Execute processStaking
        diamond.processStaking();
        
        // Verify claimAll was called
        assertTrue(mockStaking.claimAllCalled(), "claimAll was not called");
    }
    
    function testProcessStaking_UnwrapRL1() public {
        // Setup RL1 mock to have withdrawable tokens
        mockRL1.setWithdrawable(1 ether);
        
        // Execute processStaking
        diamond.processStaking();
        
        // Verify withdraw was called
        assertTrue(mockRL1.withdrawCalled(), "withdraw was not called");
    }
    
    function testProcessStaking_SendEthToKPN() public {
        // Setup: KPN has outstanding tokens but no ETH
        mockKPN.setTotalSupply(5 ether);
        
        // Send ETH to contract
        vm.deal(address(diamond), 10 ether);
        
        // Execute processStaking
        diamond.processStaking();
        
        // Verify ETH was sent to KPN contract
        assertEq(address(mockKPN).balance, 5 ether, "KPN did not receive ETH");
    }
    
    function testProcessStaking_StakeExcessETH() public {
        // Setup: No KPN debt, enough ETH to stake        
        uint256 totalSupply = diamond.totalSupply();
        
        // Calculate target ETH based on bonding curve
        uint256 targetETH = diamond.rewardForBurn(totalSupply - LibConstants.INITIAL_SUPPLY);
        
        //assert that the contract has the targetETH
        assertEq(address(diamond).balance, targetETH, "Contract does not have targetETH");

        
        // Calculate how much should be staked
        uint256 threshold = 20; // 20%
        uint256 minBalance = targetETH * threshold / 100;
        uint256 expectedStake = targetETH - minBalance;
        
        // Execute processStaking
        diamond.processStaking();
        
        // Verify stake was called with correct amount
        assertTrue(mockStaking.lockCalled(), "lock was not called");
        assertEq(mockStaking.lockedAmount(), expectedStake, "Incorrect stake amount");
        assertEq(mockStaking.lockDuration(), 3650, "Incorrect stake duration");
    }
    
    function testProcessStaking_KPNPriorityOverStaking() public {
        // Setup: Both KPN debt and excess ETH
        mockKPN.setTotalSupply(5 ether);
        
        uint256 initialSupply = LibConstants.INITIAL_SUPPLY;
        uint256 additionalSupply = 100 ether;
        uint256 totalSupply = initialSupply + additionalSupply;
        
        // Set totalSupply in contract
        vm.mockCall(
            address(diamond),
            abi.encodeWithSignature("totalSupply()"),
            abi.encode(totalSupply)
        );
        
        // Fund contract with a lot of ETH
        vm.deal(address(diamond), 20 ether);
        
        // Execute processStaking
        diamond.processStaking();
        
        // Verify KPN was paid first
        assertEq(address(mockKPN).balance, 5 ether, "KPN did not receive ETH");
        
        // Then verify remaining excess was staked
        assertTrue(mockStaking.lockCalled(), "lock was not called");
    }
    
    function testProcessStaking_InsufficientBalanceForKPN() public {
        // Setup: KPN debt exceeds balance
        mockKPN.setTotalSupply(10 ether);
        
        // Fund contract with less ETH than KPN debt
        vm.deal(address(diamond), 5 ether);
        
        // Execute processStaking
        diamond.processStaking();
        
        // Verify all available ETH was sent to KPN
        assertEq(address(mockKPN).balance, 5 ether, "KPN did not receive available ETH");
        
        // Verify no staking was done
        assertFalse(mockStaking.lockCalled(), "lock should not be called");
    }
    
    function testProcessStaking_NonAdminCannotProcess() public {
        vm.prank(account2);
        vm.expectRevert(CallerMustBeAdminError.selector);
        diamond.processStaking();
    }
}