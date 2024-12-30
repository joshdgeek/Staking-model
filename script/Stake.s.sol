// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Stake} from "../src/stake.sol";

contract CounterScript is Script {
    Stake public stake;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        stake = new Stake();

        vm.stopBroadcast();
    }
}
