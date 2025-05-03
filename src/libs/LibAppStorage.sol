// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "../shared/Structs.sol";
import { IKongPromise } from "../interfaces/IKongPromise.sol";
import { IRL1 } from "../interfaces/IRL1.sol";
import { IStaking } from "../interfaces/IStaking.sol";

struct AppStorage {
    bool diamondInitialized;
    uint256 reentrancyStatus;
    MetaTxContextStorage metaTxContext;
    
    uint256 totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    mapping(address => bool) preApproved;
    
    IKongPromise kpn;
    IRL1 rl1;
    IStaking staking;

    uint256 minStakingThreshold;
    uint16 lastStakingClaimDay;

}

library LibAppStorage {
    bytes32 internal constant DIAMOND_APP_STORAGE_POSITION = keccak256("diamond.app.storage");

    function diamondStorage() internal pure returns (AppStorage storage ds) {
        bytes32 position = DIAMOND_APP_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
