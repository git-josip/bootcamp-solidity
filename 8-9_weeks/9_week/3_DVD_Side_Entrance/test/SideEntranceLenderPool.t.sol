// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SideEntranceLenderPool.sol";
import {console} from "forge-std/console.sol";

contract RetirementFundTest is Test {
    address user1 = vm.addr(1);
    
    SideEntranceLenderPool sideEntranceLenderPool;
    ExploitContract exploitContract;
    function setUp() public {
        // Deploy contracts
        vm.deal(user1, 200 ether);
        
        vm.startPrank(user1);

        sideEntranceLenderPool = new SideEntranceLenderPool();
        sideEntranceLenderPool.deposit{value: 100 ether}();
        exploitContract = new ExploitContract(address(sideEntranceLenderPool));
        vm.deal(address(exploitContract), 1 ether);
    }

    function testIncrement() public {
        // Test your Exploit Contract below
        // check start condition
        assertTrue(address(sideEntranceLenderPool).balance == 100 ether, "Challenge Incomplete 1");
        assertTrue(address(exploitContract).balance == 1 ether, "Challenge Incomplete 2");

        // Put your solution here
        exploitContract.exploit();
        exploitContract.withdraw();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(address(sideEntranceLenderPool).balance == 0, "Challenge Incomplete 3");
        assertTrue(address(exploitContract).balance > 100 ether, "Challenge Incomplete 4");
    }

    receive() external payable {}
}