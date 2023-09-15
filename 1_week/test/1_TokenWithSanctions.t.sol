// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Test, console2} from "forge-std/Test.sol";
import {TokenWithSanctions} from "../src/1_TokenWithSanctions.sol";

contract TokenWithSanctionsTest is Test {
    TokenWithSanctions public tokenWithSanctions;

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
        tokenWithSanctions = new TokenWithSanctions("RareSkills Address Sanctions", "RAS", 1_000_000 ether);
    }

    function test_TokensCanBeTransferedToAddressIfItIsNotSanctioned() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);

        // test execution
        assertEq(0, tokenWithSanctions.balanceOf(user1), "Initials address tokens are 0.");

        tokenWithSanctions.transfer(user1, 10 * 10 ** tokenWithSanctions.decimals());

        assertEq(
            10 * 10 ** tokenWithSanctions.decimals(),
            tokenWithSanctions.balanceOf(user1),
            "Address should have balance which is transfered."
        );
    }

    function test_TokensCanNotBeTransferedToAddressIfItIsSanctioned() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);

        tokenWithSanctions.addSanctionForAddress(user1);

        // test execution
        assertEq(true, tokenWithSanctions.isAddressSanctioned(user1), "Address needs to be sanctioned.");

        uint256 amountToSend = 10 * 10 ** tokenWithSanctions.decimals();
        vm.expectRevert(bytes("Address to is sanctioned."));
        tokenWithSanctions.transfer(user1, amountToSend);
    }

    function test_AddressCanNotSendTokensIfItIsSanctioned() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);

        tokenWithSanctions.transfer(user1, 10 * 10 ** tokenWithSanctions.decimals());

        tokenWithSanctions.addSanctionForAddress(user1);

        // test execution
        assertEq(true, tokenWithSanctions.isAddressSanctioned(user1), "Address needs to be sanctioned.");

        assertEq(
            10 * 10 ** tokenWithSanctions.decimals(),
            tokenWithSanctions.balanceOf(user1),
            "Address should have balance which is transfered."
        );

        uint256 amountToSend = 5 * 10 ** tokenWithSanctions.decimals();
        vm.startPrank(user1);
        vm.expectRevert(bytes("Address from is sanctioned."));
        tokenWithSanctions.transfer(user2, amountToSend);
    }

    function test_AddressCanSendTokensIfSanctionIsRemoved() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);

        tokenWithSanctions.transfer(user1, 10 * 10 ** tokenWithSanctions.decimals());

        tokenWithSanctions.addSanctionForAddress(user1);

        // test execution
        assertEq(true, tokenWithSanctions.isAddressSanctioned(user1), "Address needs to be sanctioned.");

        assertEq(
            10 * 10 ** tokenWithSanctions.decimals(),
            tokenWithSanctions.balanceOf(user1),
            "Address should have balance which is transfered."
        );

        uint256 amountToSendToUser2 = 5 * 10 ** tokenWithSanctions.decimals();
        vm.startPrank(user1);
        vm.expectRevert(bytes("Address from is sanctioned."));
        tokenWithSanctions.transfer(user2, amountToSendToUser2);

        vm.startPrank(owner);
        tokenWithSanctions.removeSanctionForAddress(user1);

        assertEq(false, tokenWithSanctions.isAddressSanctioned(user1), "Address sanction needs to be removed.");

        vm.startPrank(user1);
        tokenWithSanctions.transfer(user2, amountToSendToUser2);

        assertEq(
            amountToSendToUser2, tokenWithSanctions.balanceOf(user2), "Address should have balance which is transfered."
        );
    }

    function test_TokensCanBeTransferedToAddressIfSanctionIsRemoved() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);

        tokenWithSanctions.addSanctionForAddress(user1);

        // test execution
        assertEq(true, tokenWithSanctions.isAddressSanctioned(user1), "Address needs to be sanctioned.");

        assertEq(0, tokenWithSanctions.balanceOf(user1), "Address should not have token balance on start.");

        uint256 amountToSend = 10 * 10 ** tokenWithSanctions.decimals();
        vm.expectRevert(bytes("Address to is sanctioned."));
        tokenWithSanctions.transfer(user1, amountToSend);

        tokenWithSanctions.removeSanctionForAddress(user1);
        tokenWithSanctions.transfer(user1, amountToSend);

        assertEq(
            amountToSend, tokenWithSanctions.balanceOf(user1), "Address should have token balance which is transfered."
        );
    }
}
