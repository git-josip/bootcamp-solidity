// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Test, console2} from "forge-std/Test.sol";
import {TokenWIthGodMode} from "../src/2_TokenWIthGodMode.sol";

contract TokenWIthGodModeTest is Test {
    TokenWIthGodMode public tokenWIthGodMode;

    address internal owner;
    address internal user1;
    address internal user2;

    function setUp() public {
        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        owner = vm.addr(8);
        vm.label(owner, "owner");

        vm.prank(owner);
        tokenWIthGodMode = new TokenWIthGodMode("RareSkills GodMode Token", "RGT", 1_000_000);
    }

    function test_OwnerCanAssignGodModeUser() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);

        tokenWIthGodMode.setGodModeAddress(user1);

        // test execution
        assertEq(
            user1,
            tokenWIthGodMode.godModeAddress(),
            "GodMode address must be equal to user1 which has been set by owner of the contract."
        );
    }

    function test_OwnerCanResetGodModeUser() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);

        tokenWIthGodMode.setGodModeAddress(user1);

        // test execution
        assertEq(
            user1,
            tokenWIthGodMode.godModeAddress(),
            "GodMode address must be equal to user1 which has been set by owner of the contract."
        );

        tokenWIthGodMode.resetGodModeAddress();

        assertEq(address(0), tokenWIthGodMode.godModeAddress(), "After reset god mode address should be address(0).");
    }

    function test_GodModeUserCanTransferTokenToAnyone() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);

        tokenWIthGodMode.setGodModeAddress(user1);

        // test execution
        assertEq(tokenWIthGodMode.totalSupply(), tokenWIthGodMode.balanceOf(owner), "Owner has all tokens on start.");

        uint256 amountToTransfer = 100_000;
        vm.startPrank(user1);
        tokenWIthGodMode.godModeTransfer(owner, user2, amountToTransfer);

        assertEq(
            tokenWIthGodMode.totalSupply() - amountToTransfer,
            tokenWIthGodMode.balanceOf(owner),
            "Owner has now less tokens. totalsupply - amountToTransfer"
        );
        assertEq(
            amountToTransfer,
            tokenWIthGodMode.balanceOf(user2),
            "User2 has now tokens that have been transfered from owner."
        );
    }

    function test_GodModeTransferShouldFailIfCalledByNonGodAddress() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);

        tokenWIthGodMode.setGodModeAddress(user1);

        // test execution
        vm.startPrank(user2);
        uint256 amountToTransfer = 100_000;

        vm.expectRevert(bytes("caller is not the God"));
        tokenWIthGodMode.godModeTransfer(owner, user2, amountToTransfer);
    }
}
