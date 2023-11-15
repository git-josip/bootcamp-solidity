// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Forwarder, Wallet, ForwarderExploit} from "../src/Forwarder.sol";

contract CounterTest is Test {
    Forwarder public forwarder;
    Wallet public wallet;
    ForwarderExploit public forwarderExploit;
    address user1 = vm.addr(1);

    function setUp() public {
        vm.startPrank(user1);
        vm.deal(user1, 100 ether);

        forwarder = new Forwarder();
        wallet = new Wallet{value: 1 ether}(address(forwarder));
        forwarderExploit = new ForwarderExploit(address(forwarder), address(wallet));
    }

    function testFuzz_SetNumber() public {
        assertEq(address(wallet).balance, 1 ether);
        assertEq(address(forwarderExploit).balance, 0);

        forwarderExploit.exploit();

        assertEq(address(forwarderExploit).balance, 1 ether);
        assertEq(address(wallet).balance, 0);
    }
}
