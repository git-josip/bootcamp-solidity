// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenBank.sol";

contract TankBankTest is Test {
    TokenBankChallenge public tokenBankChallenge;
    TokenBankAttacker public tokenBankAttacker;
    address player = address(1234);

    uint256 constant AMOUNT_500K = 500_000 ether;

    function setUp() public {
        tokenBankAttacker = new TokenBankAttacker();
        tokenBankChallenge = new TokenBankChallenge(address(tokenBankAttacker));
        tokenBankAttacker.setTokenBankChallenge(tokenBankChallenge);
    }

    function testExploit() public {
        vm.deal(player, 100 ether);
        vm.startPrank(player);

        // Put your solution here
        tokenBankAttacker.withdraw();

        // assert
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenBankChallenge.isComplete(), "Challenge Incomplete");
    }
}