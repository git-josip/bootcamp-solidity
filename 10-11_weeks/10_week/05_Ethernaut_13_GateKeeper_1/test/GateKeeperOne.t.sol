// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {GatekeeperOne, Exploit} from "../src/GatekeeperOne.sol";

contract GatekeeperOneTest is Test {
    GatekeeperOne public gatekeeperOne;
    Exploit public exploit;
    address user1 = vm.addr(1);

    function setUp() public {
        vm.startPrank(user1);
        vm.deal(user1, 100 ether);
        
        gatekeeperOne = new GatekeeperOne();
        exploit = new Exploit(address(gatekeeperOne));
    }

    function test_gatekeepr() public {
        exploit.exploit();
    }
}
