// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Denial, ExploitContract} from "../src/Denial.sol";

contract DenialTest is Test {
    ExploitContract public exploit;
    Denial public denial;
    address user1 = vm.addr(1);

    function setUp() public {
        denial = new Denial();
        exploit = new ExploitContract(payable(address(denial)));
        // denial.setWithdrawPartner(address(exploit));

        vm.deal(user1, 1000 ether);
        vm.deal(address(denial), 100 ether);
    }

    function test_exploit() public {
        
        vm.expectRevert(bytes(""));
        exploit.exploit{gas: 1_000_000}();
    }
}
