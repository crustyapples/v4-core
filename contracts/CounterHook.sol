// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Hooks} from "./libraries/Hooks.sol";
import {BaseHook} from "./BaseHook.sol";

import {IPoolManager} from "./interfaces/IPoolManager.sol";
import {BalanceDelta} from "./types/BalanceDelta.sol";

contract Counter is BaseHook {
    uint256 public beforeSwapCount;
    uint256 public afterSwapCount;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: false,
            beforeModifyPosition: false,
            afterModifyPosition: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false
        });
    }

    function beforeSwap(address, IPoolManager.PoolKey calldata, IPoolManager.SwapParams calldata)
        external
        override
        returns (bytes4)
    {
        beforeSwapCount++;
        return BaseHook.beforeSwap.selector;
    }

    function afterSwap(address, IPoolManager.PoolKey calldata, IPoolManager.SwapParams calldata, BalanceDelta)
        external
        override
        returns (bytes4)
    {
        afterSwapCount++;
        return BaseHook.afterSwap.selector;
    }
}