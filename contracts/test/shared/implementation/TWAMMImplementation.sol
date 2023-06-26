// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BaseHook} from "../../../BaseHook.sol";
import {TWAMM} from "../../../TWAMM.sol";
import {IPoolManager} from "../../../interfaces/IPoolManager.sol";
import {Hooks} from "../../../libraries/Hooks.sol";

contract TWAMMImplementation is TWAMM {
    constructor(IPoolManager poolManager, uint256 interval, TWAMM addressToEtch) TWAMM(poolManager, interval) {
        Hooks.validateHookAddress(addressToEtch, getHooksCalls());
    }

    // make this a no-op in testing
    function validateHookAddress(BaseHook _this) internal pure override {}
}
