// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.19;

import {IPoolManager} from "./interfaces/IPoolManager.sol";
import {IDynamicFeeManager} from "./interfaces/IDynamicFeeManager.sol";
import {Hooks} from "./libraries/Hooks.sol";
import {BaseHook} from "./BaseHook.sol";
import {Fees} from "./libraries/Fees.sol";

contract VolatilityOracle is BaseHook, IDynamicFeeManager {
    using Fees for uint24;

    error MustUseDynamicFee();

    uint32 deployTimestamp;

    function getFee(IPoolManager.PoolKey calldata) external view returns (uint24) {
        uint24 startingFee = 3000;
        uint32 lapsed = _blockTimestamp() - deployTimestamp;
        return startingFee + (uint24(lapsed) * 100) / 60; // 100 bps a minute
    }

    /// @dev For mocking
    function _blockTimestamp() internal view virtual returns (uint32) {
        return uint32(block.timestamp);
    }

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {
        deployTimestamp = _blockTimestamp();
    }

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: true,
            afterInitialize: false,
            beforeModifyPosition: false,
            afterModifyPosition: false,
            beforeSwap: false,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }

    function beforeInitialize(address, IPoolManager.PoolKey calldata key, uint160)
        external
        pure
        override
        returns (bytes4)
    {
        if (key.fee.isDynamicFee()) revert MustUseDynamicFee();
        return VolatilityOracle.beforeInitialize.selector;
    }
}
