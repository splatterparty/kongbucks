// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { LibAppStorage } from "../libs/LibAppStorage.sol";
import { AccessControl } from "../shared/AccessControl.sol";

contract AdminFacet is AccessControl {

    event AdminSetPreApproved(address account, bool approved);

    function setPreApproved(address account, bool approved) isAdmin external {
        LibAppStorage.diamondStorage().preApproved[account] = approved;
        emit AdminSetPreApproved(account, approved);
    }

    function isPreApproved(address account) external view returns (bool) {
        return LibAppStorage.diamondStorage().preApproved[account];
    }

}