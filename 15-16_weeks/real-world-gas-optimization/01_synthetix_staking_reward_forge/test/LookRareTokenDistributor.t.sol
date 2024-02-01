// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {LookRareTokenDistributor} from "../src/LookRareTokenDistributor.sol";
import {LooksRareToken} from "../src/LooksRareToken.sol";
import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract LookRareTokenDistributorTest is Test {
    using SafeERC20 for LooksRareToken;

    address internal owner;
    address internal beneficiary;

    LooksRareToken looksRareToken;

    LookRareTokenDistributor lookRareTokenDistributor;

    function setUp() public {
        beneficiary = vm.addr(1);
        vm.label(beneficiary, "beneficiary");

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

        uint256[] memory _periodLengthesInBlocks =  new uint256[](4);
        _rewardsPerBlockForOthers[0] = 100;
        _rewardsPerBlockForOthers[1] = 100;
        _rewardsPerBlockForOthers[2] = 100;
        _rewardsPerBlockForOthers[3] = 100;
    
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
            block.number + 1,
            _rewardsPerBlockForStaking,
            _rewardsPerBlockForOthers,
            _periodLengthesInBlocks,
            4
        );

        assertEq(looksRareToken.balanceOf(owner), 2150 ether);

        // await looksRareToken.connect(admin).transferOwnership(tokenDistributor.address);

        looksRareToken.transferOwnership(address(lookRareTokenDistributor));
        assertEq(looksRareToken.owner(), address(lookRareTokenDistributor));
    }

}