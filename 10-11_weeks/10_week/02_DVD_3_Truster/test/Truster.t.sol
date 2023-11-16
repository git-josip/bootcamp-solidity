// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TrusterLenderPool, DamnValuableToken, Exploit} from "../src/TrusterLenderPool.sol";

contract TrusterTest is Test {
    DamnValuableToken public token;
    TrusterLenderPool public trusterLenderPool;
    Exploit public trusterExploit;
    address user1 = vm.addr(1);

    function setUp() public {
        vm.startPrank(user1);
        vm.deal(user1, 100 ether);

        token = new DamnValuableToken();
        trusterLenderPool = new TrusterLenderPool(token);
        token.transfer(address(trusterLenderPool), 1_000_000 ether);

        trusterExploit = new Exploit(trusterLenderPool, token);
    }

    function test_trusterExploitr() public {
        assertEq(token.balanceOf(address(trusterLenderPool)), 1_000_000 ether);
        assertEq(token.balanceOf(address(trusterExploit)), 0);

        trusterExploit.exploit();

        assertEq(token.balanceOf(address(trusterLenderPool)), 0);
        assertEq(token.balanceOf(address(trusterExploit)), 1_000_000 ether);
    }
}
