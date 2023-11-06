// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {NaughtCoin, ExploitContract} from "../src/NaughtCoin.sol";

contract CounterTest is Test {
    NaughtCoin public naughtCoin;
    ExploitContract public exploitContract;
    address user1 = vm.addr(1);

    function setUp() public {
        vm.startPrank(user1);
        exploitContract = new ExploitContract();
        naughtCoin = new NaughtCoin(user1);
        exploitContract.setCoint(naughtCoin);

        vm.deal(user1, 100 ether);
        vm.deal(address(exploitContract), 100 ether);
    }

    function test_exploit() public {
        assertEq(naughtCoin.balanceOf(user1), naughtCoin.INITIAL_SUPPLY());
        assertEq(naughtCoin.balanceOf(address(exploitContract)), 0);

        naughtCoin.approve(address(exploitContract), naughtCoin.INITIAL_SUPPLY());
        exploitContract.exploit();

        assertEq(naughtCoin.balanceOf(user1), 0);
        assertEq(naughtCoin.balanceOf(address(exploitContract)), naughtCoin.INITIAL_SUPPLY());
    }
}
