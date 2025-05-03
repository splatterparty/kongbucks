// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AccessControl } from "../shared/AccessControl.sol";
import { LibBondingCurve } from "../libs/LibBondingCurve.sol";
import { LibAppStorage, AppStorage } from "../libs/LibAppStorage.sol";
import { LibConstants } from "../libs/LibConstants.sol";
import { IStaking } from "../interfaces/IStaking.sol";
import { IRL1 } from "../interfaces/IRL1.sol";
import { IKongPromise } from "../interfaces/IKongPromise.sol";

// The Kongbucks Staking Protocol:

// Staking overview:
// - Stake the L1 held in the contract with the IStaking interface
// - Staking will reward STAKE and VOTE tokens
// - RL1 is rewarded each day for staking

// The Kongbucks contract will max stake (3650 days) a percentage of the L1 held in the contract

// If Kongbucks are burned and there is no L1 in the contract, the contract will mint KPN tokens
// (Kong Promissory Notes) instead on a 1:1 basis

// Every 24 hours, the contract will claim RL1 tokens and unwrap RL1 tokens to L1
// If there are outstanding KPN tokens, the contract will keep sending L1 to the KPN contract
// until it matches the KPN supply.

// Otherwise the contract will hold onto the L1 until it exceeds the min threshold to stake again
// the min threshold is configurable but initially is set to 20%

// that is: rewardForBurn(totalSupply - initialSupply) * threshold > balance

contract StakingFacet is AccessControl {
  
  function setupStaking(address _staking, address _rl1, address _kpn) external isAdmin {
    AppStorage storage s = LibAppStorage.diamondStorage();

    s.staking = IStaking(_staking);
    s.rl1 = IRL1(_rl1);
    s.kpn = IKongPromise(_kpn);
  }

  function getMinStakingThreshold() external view returns (uint256) {
    return LibAppStorage.diamondStorage().minStakingThreshold;
  }

  function setMinStakingThreshold(uint256 _threshold) external isAdmin {
    LibAppStorage.diamondStorage().minStakingThreshold = _threshold;
  }

  // this gets called daily by an external process based on the reward contract timer
  function processStaking() external isAdmin {
    AppStorage storage s = LibAppStorage.diamondStorage();

    //check for rewards
    //if rewards are available, claim them

    IStaking staking = s.staking;

    uint16 lastStakingClaimDay = s.lastStakingClaimDay;
    uint16 today = staking.today();
    require(today > 0);
    uint16 yesterday = today - 1;

    if (yesterday > lastStakingClaimDay) {
      staking.claimRL1Range(lastStakingClaimDay, yesterday);
      s.lastStakingClaimDay = yesterday;
    }

    //check for unwrappable RL1
    //if available, unwrap RL1 to L1

    IRL1 rl = s.rl1;
    if (rl.withdrawable(address(this)) > 0) {
      rl.withdraw();
    }

    //check KPN totalSupply
    //if KPN totalSupply is greater than 0, and KPN's L1 balance is less than the KPN totalSupply
    //send L1 to KPN contract until the KPN's L1 balance matches the KPN totalSupply

    uint256 myL1Balance = address(this).balance;

    IKongPromise kpn = s.kpn;
    uint256 kpnTotalSupply = kpn.totalSupply();
    if (kpnTotalSupply > 0) {
      uint256 kpnL1Balance = address(kpn).balance;
      if (kpnL1Balance < kpnTotalSupply) {
        uint256 wad = kpnTotalSupply - kpnL1Balance;
        if (wad > myL1Balance) {
          wad = myL1Balance;
        }
        //send L1 to KPN
        kpn.deposit{ value: wad }();
      }
    }

    //check L1 balance
    //if L1 balance is greater than the min threshold, stake the L1 over the threshold

    uint256 minThreshold = s.minStakingThreshold;

    uint256 totalSupply = s.totalSupply;

    //assert that totalSupply > INITIAL_SUPPLY
    if (totalSupply > LibConstants.INITIAL_SUPPLY) {
      //figure out how much L1 we should have based on the totalSupply
      uint256 targetL1 = LibBondingCurve.rewardForBurn(totalSupply - LibConstants.INITIAL_SUPPLY);
      uint256 thresholdAmount = (targetL1 * minThreshold) / 100;
      uint256 currentBalance = address(this).balance; // Get updated balance
      //if actual L1 is greater than the threshold, stake the difference
      if (currentBalance > thresholdAmount) {
        uint256 wad = currentBalance - thresholdAmount;
        staking.lock{ value: wad }(3650);
      }
    }
  }

  function claimAll() external isAdmin {
    AppStorage storage s = LibAppStorage.diamondStorage();
    IStaking staking = s.staking;
    staking.claimAll();
    uint16 today = staking.today();
    require(today > 0);
    s.lastStakingClaimDay = today - 1;
  }
}
