// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DeleteUser} from "../src/DeleteUser.sol";

contract GatekeeperOneTest is Test {
    DeleteUser public deleteUser;
    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    address user3 = vm.addr(3);

    function setUp() public {
        vm.startPrank(user1);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);
        
        deleteUser = new DeleteUser();
    
    }

    function test_deleteuser() public {
        assertEq(user1.balance, 100 ether);
        deleteUser.deposit{value: 2 ether}();

        vm.startPrank(user2);
        deleteUser.deposit{value: 1 ether}();

        vm.startPrank(user3);
        deleteUser.deposit{value: 3 ether}();

        vm.startPrank(user1);
        deleteUser.withdraw(0);
        deleteUser.withdraw(0);
        deleteUser.withdraw(0);

        assertEq(user1.balance, 104 ether);
    }
}
