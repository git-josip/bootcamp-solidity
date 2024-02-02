// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {LookRareTokenDistributor} from "../src/LookRareTokenDistributor.sol";
import {LooksRareToken} from "../src/LooksRareToken.sol";
import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ILooksRareToken} from "../src/interfaces/ILooksRareToken.sol";


contract LookRareTokenDistributorTest is Test {
    using SafeERC20 for LooksRareToken;

    address internal owner;
    address internal beneficiary;

    address internal user1;
    address internal user2;
    address internal user3;
    address internal user4;

    LooksRareToken looksRareToken;

    LookRareTokenDistributor lookRareTokenDistributor;

    function setUp() public {
        beneficiary = vm.addr(1);
        vm.label(beneficiary, "beneficiary");

        beneficiary = vm.addr(1);
        vm.label(beneficiary, "beneficiary");

        user1 = vm.addr(2);
        vm.label(user1, "user1");

        user2 = vm.addr(3);
        vm.label(user2, "user2");

        user3 = vm.addr(4);
        vm.label(user3, "user3");

        user4 = vm.addr(5);
        vm.label(user4, "user4");

        owner = vm.addr(99);
        vm.label(owner, "owner");


        vm.deal(owner, 100 ether);
        vm.deal(beneficiary, 100 ether);

        vm.startPrank(owner);
        looksRareToken = new LooksRareToken(owner, 2250 ether, 21000 ether);

        uint256[] memory _rewardsPerBlockForStaking =  new uint256[](4);
        _rewardsPerBlockForStaking[0] = 30 ether;
        _rewardsPerBlockForStaking[1] = 15 ether;
        _rewardsPerBlockForStaking[2] = 7.5 ether;
        _rewardsPerBlockForStaking[3] = 3.75 ether;

        uint256[] memory _rewardsPerBlockForOthers =  new uint256[](4);
        _rewardsPerBlockForOthers[0] = 70 ether;
        _rewardsPerBlockForOthers[1] = 35 ether;
        _rewardsPerBlockForOthers[2] = 17.5 ether;
        _rewardsPerBlockForOthers[3] = 8.75  ether;

        uint32[] memory _periodLengthesInBlocks =  new uint32[](4);
        _periodLengthesInBlocks[0] = 100;
        _periodLengthesInBlocks[1] = 100;
        _periodLengthesInBlocks[2] = 100;
        _periodLengthesInBlocks[3] = 100;
        
        uint256 nonCirculatingSupply = ILooksRareToken(looksRareToken).SUPPLY_CAP() - ILooksRareToken(looksRareToken).totalSupply();
        console.log("YYYYYY nonCirculatingSupply: ", nonCirculatingSupply);

        /**
         * @notice Constructor
         * @param _looksRareToken LOOKS token address
         * @param _tokenSplitter token splitter contract address (for team and trading rewards)
         * @param _startBlock start block for reward program
         * @param _rewardsPerBlockForStaking array of rewards per block for staking
         * @param _rewardsPerBlockForOthers array of rewards per block for other purposes (team + treasury + trading rewards)
         * @param _periodLengthesInBlocks array of period lengthes
         * @param _numberPeriods number of periods with different rewards/lengthes (e.g., if 3 changes --> 4 periods)
         */
        lookRareTokenDistributor = new LookRareTokenDistributor(
            address(looksRareToken),
            address(owner),
            uint32(block.number) + 100,
            _rewardsPerBlockForStaking,
            _rewardsPerBlockForOthers,
            _periodLengthesInBlocks,
            4
        );

        assertEq(looksRareToken.balanceOf(owner), 2250 ether);
        looksRareToken.transferOwnership(address(lookRareTokenDistributor));
        assertEq(looksRareToken.owner(), address(lookRareTokenDistributor));


        looksRareToken.transfer(user1, 500 ether);
        assertEq(looksRareToken.balanceOf(user1), 500 ether);
        looksRareToken.transfer(user2, 500 ether);
        assertEq(looksRareToken.balanceOf(user2), 500 ether);
        looksRareToken.transfer(user3, 500 ether);
        assertEq(looksRareToken.balanceOf(user3), 500 ether);
        looksRareToken.transfer(user4, 500 ether);
        assertEq(looksRareToken.balanceOf(user4), 500 ether);

        vm.startPrank(user1);
        looksRareToken.approve(address(lookRareTokenDistributor), 1_000_000 ether);
        lookRareTokenDistributor.deposit(100 ether);

        vm.startPrank(user2);
        looksRareToken.approve(address(lookRareTokenDistributor), 1_000_000 ether);
        lookRareTokenDistributor.deposit(100 ether);

        vm.startPrank(user3);
        looksRareToken.approve(address(lookRareTokenDistributor), 1_000_000 ether);
        lookRareTokenDistributor.deposit(100 ether);

        vm.startPrank(user4);
        looksRareToken.approve(address(lookRareTokenDistributor), 1_000_000 ether);
        lookRareTokenDistributor.deposit(100 ether);
    }

    function testRegularAdminUserInteraction() public {
        vm.roll(149);

        assertEq(lookRareTokenDistributor.calculatePendingRewards(user1), 360 ether);
        assertEq(lookRareTokenDistributor.calculatePendingRewards(user2), 360 ether);
        assertEq(lookRareTokenDistributor.calculatePendingRewards(user3), 360 ether);
        assertEq(lookRareTokenDistributor.calculatePendingRewards(user4), 360 ether);

        vm.startPrank(user1);
        lookRareTokenDistributor.harvestAndCompound();
        lookRareTokenDistributor.withdraw(100 ether);
        lookRareTokenDistributor.updatePool();

        vm.startPrank(user2);
        lookRareTokenDistributor.harvestAndCompound();
        lookRareTokenDistributor.withdraw(100 ether);
        lookRareTokenDistributor.updatePool();

        vm.startPrank(user3);
        lookRareTokenDistributor.harvestAndCompound();
        lookRareTokenDistributor.withdraw(100 ether);
        lookRareTokenDistributor.updatePool();

        vm.startPrank(user4);
        lookRareTokenDistributor.harvestAndCompound();
        lookRareTokenDistributor.withdraw(100 ether);
        lookRareTokenDistributor.updatePool();

        vm.roll(199);
        vm.startPrank(user1);
        lookRareTokenDistributor.withdrawAll();
        lookRareTokenDistributor.updatePool();


    }
}