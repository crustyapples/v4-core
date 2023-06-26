// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Counter} from "../../../CounterHook.sol";
import {BaseHook} from "../../../BaseHook.sol";
import {IPoolManager} from "../../../interfaces/IPoolManager.sol";
import {Hooks} from "../../../libraries/Hooks.sol";

contract CounterImplementation is Counter {
    constructor(IPoolManager poolManager, Counter addressToEtch) Counter(poolManager) {
        Hooks.validateHookAddress(addressToEtch, getHooksCalls());
    }

    // make this a no-op in testing
    function validateHookAddress(BaseHook _this) internal pure override {}
}