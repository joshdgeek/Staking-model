// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Stake} from "../src/stake.sol";

contract CounterTest is Test {
    Stake stake;
    address admin;
    address dummy;
    uint256 mintAmount;

    function setUp() public {
        dummy = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        mintAmount = 1000000000 * 10 ** 18;
        admin = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        stake = new Stake(admin, mintAmount);

        vm.startPrank(admin);
        stake.requestToken(100000 * 1e18);
        stake.transfer(dummy, 5000 * 1e18);
        vm.stopPrank();
    }

    function testRequestToken() public {
        vm.prank(admin);
        stake.requestToken(100000 * 10 ** 18);
        emit log_named_uint(" balance Amount", stake.balanceOf(admin));
        assertNotEq(stake.balanceOf(admin), 10000 * 10 ** 18, "not authorized");
    }

    function testStake() public {
        vm.startPrank(dummy);
        emit log_named_uint(" balance before STAKE", stake.balanceOf(dummy));
        stake.stake(1000 * 1e18, 1);
        emit log_named_uint(" balance after STAKE", stake.balanceOf(dummy));
        vm.stopPrank();

        assertNotEq(stake.balanceOf(dummy), 1000 * 1e18, "Staking transaction failed");
    }

    function testUnstake() public {
        //stake
        vm.startPrank(dummy);
        emit log_named_uint(" balance before STAKE", stake.balanceOf(dummy) / 1e18);

        stake.stake(1000 * 1e18, 1);
        emit log_named_uint(" balance after STAKE", stake.balanceOf(dummy) / 1e18);
        vm.stopPrank();

        assertEq(stake.staked(dummy) > 0, true, "nope");

        vm.warp(3 days);

        emit log_named_uint(" time delay", block.timestamp);
        emit log_named_uint("Time of Lockup", stake.timeOfLockUp(dummy));
        //unstake
        vm.startPrank(dummy);

        stake.unStake(1000 * 10 ** 18, 3 days);
        emit log_named_uint(" balance AFTER UNSTAKE", stake.balanceOf(dummy) / 10e18);

        vm.stopPrank();
        assertNotEq(stake.balanceOf(dummy), 500 * 10 ** 18, "wrong");
    }
}
