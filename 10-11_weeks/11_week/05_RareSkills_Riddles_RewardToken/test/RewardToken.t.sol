// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {RewardToken, NftToStake, Depositoor, Exploit} from "../src/RewardToken.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract RewardTokenTest is Test {
    NftToStake nftToStake;
    RewardToken rewardToken;
    Depositoor depositor;
    Exploit exploit;

    address user1 = vm.addr(1);

    function setUp() public {
        vm.deal(user1, 100 ether);

        exploit = new Exploit();
        nftToStake = new NftToStake(address(exploit));
        depositor = new Depositoor(IERC721(nftToStake));
        rewardToken = new RewardToken(address(depositor));
        depositor.setRewardToken(IERC20(address(rewardToken)));
        exploit.initialize(
            address(nftToStake),
            address(rewardToken),
            address(depositor)
        );
    }

    function test_rewardTokenExploit() public {
        vm.startPrank(user1);
        assertEq(rewardToken.balanceOf(address(exploit)), 0);
        assertEq(rewardToken.balanceOf(address(depositor)), 100 ether);
        
        uint256 SIX_DAYS_IN_SECONDS = 6 * 24 * 60 * 60;
        vm.warp(SIX_DAYS_IN_SECONDS);
        exploit.attack();

        assertEq(rewardToken.balanceOf(address(exploit)), 100 ether);
        assertEq(rewardToken.balanceOf(address(depositor)), 0);
    }
}
