// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TokenVesting} from "../src/TraderJoeTokenVesting.sol";
import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface TestTokenERC20 is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract Token1 is ERC20, TestTokenERC20 {
    constructor() ERC20("TOKEN_STAKING", "TKS") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract Token2 is ERC20 {
    constructor() ERC20("TOKEN_REWARD", "TKR") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract Token3 is ERC20 {
    constructor() ERC20("TOKEN_REWARD", "TKR") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract Token4 is ERC20 {
    constructor() ERC20("TOKEN_REWARD", "TKR") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}


contract TokenVestingTest is Test {
    using SafeERC20 for Token1;
    using SafeERC20 for Token2;
    using SafeERC20 for Token3;
    using SafeERC20 for Token4;

    address internal owner;
    address internal beneficiary;

    Token1 token1;
    Token2 token2;
    Token3 token3;
    Token4 token4;

    TokenVesting tokenVesting;

    function setUp() public {
        beneficiary = vm.addr(1);
        vm.label(beneficiary, "beneficiary");

        owner = vm.addr(99);
        vm.label(owner, "owner");


        vm.deal(owner, 100 ether);
        vm.deal(beneficiary, 100 ether);

        vm.startPrank(owner);
        token1 = new Token1();
        token2 = new Token2();
        token3 = new Token3();
        token4 = new Token4();

        tokenVesting = new TokenVesting(
            beneficiary,
            block.timestamp + 10,
            100,
            7 days,
            true
        );

        token1.mint(address(tokenVesting), 1_000_000 ether);
        token2.mint(address(tokenVesting), 1_000_000 ether);
        token3.mint(address(tokenVesting), 1_000_000 ether);
        token4.mint(address(tokenVesting), 1_000_000 ether);

        assertEq(token1.balanceOf(address(tokenVesting)), 1_000_000 ether);
        assertEq(token2.balanceOf(address(tokenVesting)), 1_000_000 ether);
        assertEq(token3.balanceOf(address(tokenVesting)), 1_000_000 ether);
        assertEq(token4.balanceOf(address(tokenVesting)), 1_000_000 ether);

        assertEq(tokenVesting.owner(), owner);
    }

    function test_revoke() public {
        assertTrue(token1.balanceOf(owner) == 0);
        assertTrue(token2.balanceOf(owner) == 0);
        assertTrue(token3.balanceOf(owner) == 0);
        assertTrue(token4.balanceOf(owner) == 0);

        vm.startPrank(owner);
        tokenVesting.revoke(token1);

        vm.startPrank(owner);
        tokenVesting.revoke(token2);

        vm.startPrank(owner);
        tokenVesting.revoke(token3);

        vm.startPrank(owner);
        tokenVesting.revoke(token4);

        assertTrue(token1.balanceOf(owner) > 0);
        assertTrue(token2.balanceOf(owner) > 0);
        assertTrue(token3.balanceOf(owner) > 0);
        assertTrue(token4.balanceOf(owner) > 0);
    }

    function test_emergencyRevoke() public {
        assertTrue(token1.balanceOf(owner) == 0);
        assertTrue(token2.balanceOf(owner) == 0);
        assertTrue(token3.balanceOf(owner) == 0);
        assertTrue(token4.balanceOf(owner) == 0);

        vm.startPrank(owner);
        tokenVesting.emergencyRevoke(token1);

        vm.startPrank(owner);
        tokenVesting.emergencyRevoke(token2);

        vm.startPrank(owner);
        tokenVesting.emergencyRevoke(token3);

        vm.startPrank(owner);
        tokenVesting.emergencyRevoke(token4);

        assertTrue(token1.balanceOf(owner) > 0);
        assertTrue(token2.balanceOf(owner) > 0);
        assertTrue(token3.balanceOf(owner) > 0);
        assertTrue(token4.balanceOf(owner) > 0);
    }

    function test_release() public {
        assertTrue(token1.balanceOf(beneficiary) == 0);
        assertTrue(token2.balanceOf(beneficiary) == 0);
        assertTrue(token3.balanceOf(beneficiary) == 0);
        assertTrue(token4.balanceOf(beneficiary) == 0);

        vm.warp(tokenVesting.start() + 2 days);

        vm.startPrank(beneficiary);
        tokenVesting.release(token1);

        vm.startPrank(beneficiary);
        tokenVesting.release(token2);

        vm.startPrank(beneficiary);
        tokenVesting.release(token3);

        vm.startPrank(beneficiary);
        tokenVesting.release(token4);

        assertTrue(token1.balanceOf(beneficiary) > 0);
        assertTrue(token2.balanceOf(beneficiary) > 0);
        assertTrue(token3.balanceOf(beneficiary) > 0);
        assertTrue(token4.balanceOf(beneficiary) > 0);
    }
    
    function test_revoked() public {
        vm.startPrank(owner);
        tokenVesting.revoke(token1);

        vm.startPrank(owner);
        tokenVesting.revoke(token2);

        tokenVesting.revoked(address(token1));
        tokenVesting.revoked(address(token2));
        tokenVesting.revoked(address(token3));
        tokenVesting.revoked(address(token4));
    }
}