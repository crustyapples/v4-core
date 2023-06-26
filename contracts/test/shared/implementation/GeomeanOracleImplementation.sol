// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BaseHook} from "../../../BaseHook.sol";
import {GeomeanOracle} from "../../../GeomeanOracle.sol";
import {IPoolManager} from "../../../interfaces/IPoolManager.sol";
import {Hooks} from "../../../libraries/Hooks.sol";

contract GeomeanOracleImplementation is GeomeanOracle {
    uint32 public time;

    constructor(IPoolManager _poolManager, GeomeanOracle addressToEtch) GeomeanOracle(_poolManager) {
        Hooks.validateHookAddress(addressToEtch, getHooksCalls());
    }

    // make this a no-op in testing
    function validateHookAddress(BaseHook _this) internal pure override {}

    function setTime(uint32 _time) external {
        time = _time;
    }

    function _blockTimestamp() internal view override returns (uint32) {
        return time;
    }
}
