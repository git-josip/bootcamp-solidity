// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {StakingRewards} from "../src/StakingRewards.sol";
import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface TestTokenERC20 is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract TokenStaking is ERC20, TestTokenERC20 {
    constructor() ERC20("TOKEN_STAKING", "TKS") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract TokenReward is ERC20 {
    constructor() ERC20("TOKEN_REWARD", "TKR") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract StakingRewardTest is Test {
    using SafeERC20 for TokenReward;
    using SafeERC20 for TokenStaking;

    address internal owner;
    address internal user1;
    address internal user2;

    TokenStaking tokenStaking;
    TokenReward tokenReward;
    StakingRewards stakingRewards;

    function setUp() public {
        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        owner = vm.addr(99);
        vm.label(owner, "owner");


        vm.deal(owner, 100 ether);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);

        vm.prank(owner);
        tokenStaking = new TokenStaking();
        tokenReward = new TokenReward();
        stakingRewards = new StakingRewards(
            owner,
            address(tokenReward),
            address(tokenStaking)
        );

        tokenReward.mint(address(stakingRewards), 1_000_000 ether);
        tokenStaking.mint(user1, 100_000 ether);
        tokenStaking.mint(user2, 100_000 ether);

        assertEq(tokenReward.balanceOf(address(stakingRewards)), 1_000_000 ether);
        assertEq(tokenStaking.balanceOf(user1), 100_000 ether);
        assertEq(tokenStaking.balanceOf(user2), 100_000 ether);
    }

    function test_StakeUser1(uint256 _amount) public {
        uint256 balance = tokenStaking.balanceOf(user1);
        vm.assume(_amount > 100e18);
        vm.assume(_amount < balance);

        uint256 amount = bound(_amount, 100e18, balance);

        vm.startPrank(user1);
        tokenStaking.approve(address(stakingRewards), amount);
        stakingRewards.stake(amount);

        vm.startPrank(owner);
        stakingRewards.notifyRewardAmount(100_000 ether);
    }

    function test_WithdrawUser1(uint256 _amount) public {
        uint256 balance = tokenStaking.balanceOf(user1);
        vm.assume(_amount > 1000e18);
        vm.assume(_amount < balance);

        uint256 amount = bound(_amount, 100e18, balance);

        vm.startPrank(user1);
        tokenStaking.approve(address(stakingRewards), amount);
        stakingRewards.stake(amount);

        vm.startPrank(owner);
        stakingRewards.notifyRewardAmount(100_000 ether);

        vm.warp(4 days);
        vm.startPrank(user1);
        stakingRewards.withdraw(amount - 800e18);
    }

    function test_GetRewardUser1(uint256 _amount) public {
        uint256 balance = tokenStaking.balanceOf(user1);
        vm.assume(_amount > 1000e18);
        vm.assume(_amount < balance);

        uint256 amount = bound(_amount, 100e18, balance);

        vm.startPrank(user1);
        tokenStaking.approve(address(stakingRewards), amount);
        stakingRewards.stake(amount);

        vm.startPrank(owner);
        stakingRewards.notifyRewardAmount(100_000 ether);

        vm.warp(6 days);
        vm.startPrank(user1);
        stakingRewards.getReward();
    }

    function test_StakeUser2(uint256 _amount) public {
        uint256 balance = tokenStaking.balanceOf(user2);
        vm.assume(_amount > 100e18);
        vm.assume(_amount < balance);

        uint256 amount = bound(_amount, 100e18, balance);
        vm.startPrank(user2);
        tokenStaking.approve(address(stakingRewards), amount);
        stakingRewards.stake(amount);

        vm.startPrank(owner);
        stakingRewards.notifyRewardAmount(100_000 ether);
    }

    function test_WithdrawUser2(uint256 _amount) public {
        uint256 balance = tokenStaking.balanceOf(user2);
        vm.assume(_amount > 1000e18);
        vm.assume(_amount < balance);

        uint256 amount = bound(_amount, 100e18, balance);

        vm.startPrank(user2);
        tokenStaking.approve(address(stakingRewards), amount);
        stakingRewards.stake(amount);

        vm.startPrank(owner);
        stakingRewards.notifyRewardAmount(100_000 ether);

        vm.warp(5 days);
        vm.startPrank(user2);
        stakingRewards.withdraw(amount - 800e18);
    }

    function test_GetRewardUser2(uint256 _amount) public {
        uint256 balance = tokenStaking.balanceOf(user2);
        vm.assume(_amount > 1000e18);
        vm.assume(_amount < balance);

        uint256 amount = bound(_amount, 100e18, balance);

        vm.startPrank(user2);
        tokenStaking.approve(address(stakingRewards), amount);
        stakingRewards.stake(amount);

        vm.startPrank(owner);
        stakingRewards.notifyRewardAmount(100_000 ether);

        vm.warp(4 days);
        vm.startPrank(user2);
        stakingRewards.getReward();
    }


    function test_notifyRewardAmount() public {
        vm.startPrank(owner);
        stakingRewards.notifyRewardAmount(100_000 ether);
    }
}