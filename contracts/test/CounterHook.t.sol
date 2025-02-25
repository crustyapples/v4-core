// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {GasSnapshot} from "../../lib/forge-gas-snapshot/src/GasSnapshot.sol";
import {TestERC20} from "./TestERC20.sol";
import {IERC20Minimal} from "../interfaces/external/IERC20Minimal.sol";
import {IHooks} from "../interfaces/IHooks.sol";
import {Hooks} from "../libraries/Hooks.sol";
import {TickMath} from "../libraries/TickMath.sol";
import {PoolManager} from "../PoolManager.sol";
import {IPoolManager} from "../interfaces/IPoolManager.sol";
import {PoolId, PoolIdLibrary} from "../libraries/PoolId.sol";
import {PoolModifyPositionTest} from "./PoolModifyPositionTest.sol";
import {PoolSwapTest} from "./PoolSwapTest.sol";
import {PoolDonateTest} from "./PoolDonateTest.sol";
import {Deployers} from "../../test/foundry-tests/utils/Deployers.sol";
import {CurrencyLibrary, Currency} from "../libraries/CurrencyLibrary.sol";
import {Counter} from "../CounterHook.sol";
import {CounterImplementation} from "./shared/implementation/CounterHookImplementation.sol";

contract CounterTest is Test, Deployers, GasSnapshot {
    using PoolIdLibrary for IPoolManager.PoolKey;
    using CurrencyLibrary for Currency;

    Counter counter = Counter(
        address(uint160(Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG))
    );
    PoolManager manager;
    PoolModifyPositionTest modifyPositionRouter;
    PoolSwapTest swapRouter;
    TestERC20 token0;
    TestERC20 token1;
    IPoolManager.PoolKey poolKey;
    PoolId poolId;

    function setUp() public {
        token0 = new TestERC20(2**128);
        token1 = new TestERC20(2**128);
        manager = new PoolManager(500000);

        // testing environment requires our contract to override `validateHookAddress`
        // well do that via the Implementation contract to avoid deploying the override with the production contract
        CounterImplementation impl = new CounterImplementation(manager, counter);
        (, bytes32[] memory writes) = vm.accesses(address(impl));
        vm.etch(address(counter), address(impl).code);
        // for each storage key that was written during the hook implementation, copy the value over
        unchecked {
            for (uint256 i = 0; i < writes.length; i++) {
                bytes32 slot = writes[i];
                vm.store(address(counter), slot, vm.load(address(impl), slot));
            }
        }

        // Create the pool
        poolKey = IPoolManager.PoolKey(Currency.wrap(address(token0)), Currency.wrap(address(token1)), 3000, 60, IHooks(counter));
        poolId = poolKey.toId();
        manager.initialize(poolKey, SQRT_RATIO_1_1);

        // Helpers for interacting with the pool
        modifyPositionRouter = new PoolModifyPositionTest(IPoolManager(address(manager)));
        swapRouter = new PoolSwapTest(IPoolManager(address(manager)));

        // Provide liquidity to the pool
        token0.approve(address(modifyPositionRouter), 100 ether);
        token1.approve(address(modifyPositionRouter), 100 ether);
        token0.mint(address(this), 100 ether);
        token1.mint(address(this), 100 ether);
        modifyPositionRouter.modifyPosition(poolKey, IPoolManager.ModifyPositionParams(-60, 60, 10 ether));
        modifyPositionRouter.modifyPosition(poolKey, IPoolManager.ModifyPositionParams(-120, 120, 10 ether));
        modifyPositionRouter.modifyPosition(
            poolKey, IPoolManager.ModifyPositionParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 10 ether)
        );

        // Approve for swapping
        token0.approve(address(swapRouter), 100 ether);
        token1.approve(address(swapRouter), 100 ether);
    }

    function testCounterHooks() public {
        assertEq(counter.beforeSwapCount(), 0);
        assertEq(counter.afterSwapCount(), 0);
        
        // Perform a test swap //
        IPoolManager.SwapParams memory params =
            IPoolManager.SwapParams({zeroForOne: true, amountSpecified: 100, sqrtPriceLimitX96: SQRT_RATIO_1_2});

        PoolSwapTest.TestSettings memory testSettings =
            PoolSwapTest.TestSettings({withdrawTokens: true, settleUsingTransfer: true});
        
        swapRouter.swap(
            poolKey,
            params,
            testSettings
        );
        // ------------------- //
        
        assertEq(counter.beforeSwapCount(), 1);
        assertEq(counter.afterSwapCount(), 1);
    }
}