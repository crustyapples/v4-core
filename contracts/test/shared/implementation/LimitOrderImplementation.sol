// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BaseHook} from "../../../BaseHook.sol";
import {LimitOrder} from "../../../LimitOrder.sol";
import {IPoolManager} from "../../../interfaces/IPoolManager.sol";
import {Hooks} from "../../../libraries/Hooks.sol";

contract LimitOrderImplementation is LimitOrder {
    constructor(IPoolManager _poolManager, LimitOrder addressToEtch) LimitOrder(_poolManager) {
        Hooks.validateHookAddress(addressToEtch, getHooksCalls());
    }

    // make this a no-op in testing
    function validateHookAddress(BaseHook _this) internal pure override {}
}
