// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {StakeAndGetReward} from "../src/2_StakeAndGetReward.sol";
import {RewardToken} from "../src/2_RewardToken.sol";
import {NftStakingToken} from "../src/2_NftStakingToken.sol";
import {IRewardToken} from "../src/2_RewardToken.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {IERC1363} from "@payabletoken/contracts/token/ERC1363/IERC1363.sol";

contract StakeAndGetRewardTest is Test {
    StakeAndGetReward public stakeAndGetReward;
    RewardToken public rewardToken;
    NftStakingToken public nftStakingToken;

    address internal owner;
    address internal user1;
    address internal user2;
    address internal user3;
    address internal user4;

    function setUp() public {
        owner = vm.addr(100);
        vm.label(owner, "owner");

        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        user3 = vm.addr(3);
        vm.label(user3, "user3");

        user4 = vm.addr(4);
        vm.label(user4, "user4");

        vm.prank(owner);
        nftStakingToken = new NftStakingToken("RareSkills NFT", "RNFT", 20);
        stakeAndGetReward = new StakeAndGetReward(nftStakingToken);
        rewardToken = new RewardToken(IERC721Receiver(address(stakeAndGetReward)));
        stakeAndGetReward.setRewardTokenContract(rewardToken);
    }

    function test_AddressShouldBeAbleToStakeNft() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        nftStakingToken.approve(address(stakeAndGetReward), mintedTokenId);

        // test execution
        bool sucess = stakeAndGetReward.stake(mintedTokenId);
        require(sucess, "Staking is not sucessful");
        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be owner of staked token."
        );
    }

    function test_StakeShouldFailIfOwnerIsNotMsSender() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.startPrank(user2);

        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user2, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");

        vm.startPrank(user1);
        // test execution
        vm.expectRevert(bytes("Sender must be owner of NFT which wants to stake."));
        stakeAndGetReward.stake(mintedTokenId);
    }

    function test_StakeShouldFailIfRewardTokenIsNotSet() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.startPrank(user1);

        NftStakingToken newNftStakingToken = new NftStakingToken("RareSkills NFT", "RNFT", 20);
        StakeAndGetReward newStakeAndGetReward = new StakeAndGetReward(newNftStakingToken);

        uint256 mintedTokenId = newNftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, newNftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");

        // test execution
        vm.expectRevert(bytes("RewardToken not set."));
        newStakeAndGetReward.stake(mintedTokenId);
    }

    function test_StakeShouldFailIfTokenAlreadyStaked() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        nftStakingToken.approve(address(stakeAndGetReward), mintedTokenId);
        stakeAndGetReward.stake(mintedTokenId);

        // test execution
        vm.expectRevert(bytes("Token must not be already staked."));
        stakeAndGetReward.stake(mintedTokenId);
    }

    function test_SetRewardTokenContractShouldFailIfAddressIsNotContract() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        NftStakingToken newNftStakingToken = new NftStakingToken("RareSkills NFT", "RNFT", 20);
        StakeAndGetReward newStakeAndGetReward = new StakeAndGetReward(newNftStakingToken);
        // test execution
        vm.expectRevert(bytes("RewardTokenContract must be contract not external account."));
        newStakeAndGetReward.setRewardTokenContract(IRewardToken(user2));
    }

    function test_SetRewardTokenContractShouldFailIfItNotSupportsInterfaceIERC1363() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        NftStakingToken newNftStakingToken = new NftStakingToken("RareSkills NFT", "RNFT", 20);
        StakeAndGetReward newStakeAndGetReward = new StakeAndGetReward(newNftStakingToken);
        // test execution
        vm.expectRevert(bytes("Contract must implement IERC1363 interafce."));
        newStakeAndGetReward.setRewardTokenContract(IRewardToken(address(newNftStakingToken)));
    }

    function test_SetRewardTokenContractShouldSucceedForValidContract() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        NftStakingToken newNftStakingToken = new NftStakingToken("RareSkills NFT", "RNFT", 20);
        StakeAndGetReward newStakeAndGetReward = new StakeAndGetReward(newNftStakingToken);
        RewardToken newRewardToken = new RewardToken(IERC721Receiver(address(stakeAndGetReward)));
        // test execution
        newStakeAndGetReward.setRewardTokenContract(newRewardToken);

        assertEq(address(newRewardToken), address(newStakeAndGetReward.rewardTokenContract()), "Reward token should be one that is set before.");
    }

    function test_SupportsInterfaceShouldReturnTrueForIERC721ReceiverInterface() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        bool doesSupport = stakeAndGetReward.supportsInterface(type(IERC721Receiver).interfaceId);
        assertTrue(doesSupport);
    }

    function test_SupportsInterfaceShouldReturnFalseForIERC1363Interface() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        bool doesSupport = stakeAndGetReward.supportsInterface(type(IERC1363).interfaceId);
        assertFalse(doesSupport);
    }

    function test_AddressShouldBeAbleToStakeNftAndCalculateRewards() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        assertEq(
            0.01 ether, address(nftStakingToken).balance, "NftStakingToken has to have receive amount for nft mint."
        );

        nftStakingToken.approve(address(stakeAndGetReward), mintedTokenId);
        bool sucess = stakeAndGetReward.stake(mintedTokenId);
        require(sucess, "Staking is not sucessful");
        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be owner of staked token."
        );

        vm.warp(3 days + 1);
        // test execution

        uint256 reward = stakeAndGetReward.calculateReward(mintedTokenId);
        assertEq(30 ether, reward, "Reward after 3 days should be 30 ether.");
    }

    function test_AddressShouldBeAbleToCollectReward() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        assertEq(
            0.01 ether, address(nftStakingToken).balance, "NftStakingToken has to have receive amount for nft mint."
        );

        nftStakingToken.approve(address(stakeAndGetReward), mintedTokenId);
        bool sucess = stakeAndGetReward.stake(mintedTokenId);
        require(sucess, "Staking is not sucessful");
        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be owner of staked token."
        );
        vm.warp(3 days + 1);

        // test execution
        uint256 reward = stakeAndGetReward.calculateReward(mintedTokenId);
        assertEq(30 ether, reward, "Reward after 3 days should be 30 ether.");

        bool collectRewardStatus = stakeAndGetReward.collectReward(mintedTokenId);
        require(collectRewardStatus, "CollectReward is not sucessful");
        assertEq(rewardToken.balanceOf(address(user1)), reward, "User has to be in possession collected reward.");

        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract still has to be owner of staked token as only reward was collected."
        );
        uint256 rewardAfterCollected = stakeAndGetReward.calculateReward(mintedTokenId);
        assertEq(0, rewardAfterCollected, "Reward after collected should be 0.");

        vm.warp(block.timestamp + 2 days);
        uint256 reward2 = stakeAndGetReward.calculateReward(mintedTokenId);
        assertEq(20 ether, reward2, "Reward after 2 days should be 20 ether.");

        bool collectRewardStatus2 = stakeAndGetReward.collectReward(mintedTokenId);
        require(collectRewardStatus2, "CollectReward is not sucessful");
        assertEq(
            rewardToken.balanceOf(address(user1)),
            reward + reward2,
            "User has to be in possession of totally collected reward."
        );

        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract still has to be owner of staked token as only reward was collected."
        );
        uint256 rewardAfterCollected2 = stakeAndGetReward.calculateReward(mintedTokenId);
        assertEq(0, rewardAfterCollected2, "Reward after collected should be 0.");
    }

    function test_AddressShouldBeAbleToUnstakeNFTAndCollectReward() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        assertEq(
            0.01 ether, address(nftStakingToken).balance, "NftStakingToken has to have receive amount for nft mint."
        );

        nftStakingToken.approve(address(stakeAndGetReward), mintedTokenId);
        bool sucess = stakeAndGetReward.stake(mintedTokenId);
        require(sucess, "Staking was not sucessful");
        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be owner of staked token."
        );
        vm.warp(3 days + 1);

        // test execution
        uint256 reward = stakeAndGetReward.calculateReward(mintedTokenId);
        assertEq(30 ether, reward, "Reward after 3 days should be 30 ether.");

        bool unstakeStatus = stakeAndGetReward.unstake(mintedTokenId);
        require(unstakeStatus, "Unstake was not sucessful");
        assertEq(
            rewardToken.balanceOf(address(user1)),
            reward,
            "User has to be in possession collected reward after unstake."
        );

        assertEq(
            address(user1),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be returned to user which staked it."
        );
    }

    function test_IfAddressWhichDidNotStakeNFTriesToUnstakeItErrorShouldBeThrown() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.startPrank(user1);

        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        assertEq(
            0.01 ether, address(nftStakingToken).balance, "NftStakingToken has to have receive amount for nft mint."
        );

        nftStakingToken.approve(address(stakeAndGetReward), mintedTokenId);
        bool sucess = stakeAndGetReward.stake(mintedTokenId);
        require(sucess, "Staking was not sucessful");
        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be owner of staked token."
        );
        vm.warp(3 days + 1);

        // test execution
        vm.startPrank(user2);
        vm.expectRevert(bytes("Only address who initaly staked NFT can un stake it."));
        stakeAndGetReward.unstake(mintedTokenId);
    }

    function test_IfAddressWhichDidNotStakeNFTriesToCollectRewardItErrorShouldBeThrown() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.startPrank(user1);

        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        assertEq(
            0.01 ether, address(nftStakingToken).balance, "NftStakingToken has to have receive amount for nft mint."
        );

        nftStakingToken.approve(address(stakeAndGetReward), mintedTokenId);
        bool sucess = stakeAndGetReward.stake(mintedTokenId);
        require(sucess, "Staking was not sucessful");
        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be owner of staked token."
        );
        vm.warp(3 days + 1);

        // test execution
        vm.startPrank(user2);
        vm.expectRevert(bytes("Only address who initaly staked NFT can collect reward."));
        stakeAndGetReward.collectReward(mintedTokenId);
    }

    function test_IfAddressSendsNFTToStakeAndRewardContractStakeShouldBeCreatedForThatAddress() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.startPrank(user1);

        // test execution
        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        assertEq(
            0.01 ether, address(nftStakingToken).balance, "NftStakingToken has to have receive amount for nft mint."
        );

        nftStakingToken.safeTransferFrom(user1, address(stakeAndGetReward), mintedTokenId);
        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be owner of staked token."
        );
    }

    function test_IfAddressSendsNFTToStakeAndRewardContractShouldBeAbleToCollectReward() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.startPrank(user1);

        // test execution
        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        assertEq(
            0.01 ether, address(nftStakingToken).balance, "NftStakingToken has to have receive amount for nft mint."
        );

        nftStakingToken.safeTransferFrom(user1, address(stakeAndGetReward), mintedTokenId);
        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be owner of staked token."
        );

        vm.warp(3 days + 1);
        uint256 reward = stakeAndGetReward.calculateReward(mintedTokenId);
        assertEq(30 ether, reward, "Reward after 3 days should be 30 ether.");
    }

    function test_IfAddressSendsNFTToStakeAndRewardContractShouldBeAbleToUnstakeIt() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        // test execution
        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        assertEq(
            0.01 ether, address(nftStakingToken).balance, "NftStakingToken has to have receive amount for nft mint."
        );

        nftStakingToken.safeTransferFrom(user1, address(stakeAndGetReward), mintedTokenId);
        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be owner of staked token."
        );

        vm.warp(3 days + 1);
        bool unstakeStatus = stakeAndGetReward.unstake(mintedTokenId);
        assertEq(true, unstakeStatus, "Unstake should be successful.");
        assertEq(
            30 ether,
            rewardToken.balanceOf(address(user1)),
            "User has to be in possession collected reward after unstake."
        );
    }

    function test_IfAddressSendsNFTToStakeAndRewardContractShouldBeAbleToUnstakeItIfThereIsNoReward() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        // test execution
        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        assertEq(
            0.01 ether, address(nftStakingToken).balance, "NftStakingToken has to have receive amount for nft mint."
        );

        nftStakingToken.safeTransferFrom(user1, address(stakeAndGetReward), mintedTokenId);
        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be owner of staked token."
        );

        bool unstakeStatus = stakeAndGetReward.unstake(mintedTokenId);
        assertEq(true, unstakeStatus, "Unstake should be successful.");
        assertEq(
            0,
            rewardToken.balanceOf(address(user1)),
            "User must not have any reward."
        );
    }

    function test_IfAddressSendsNFTToStakeAndRewardContractCollectRewardShouldFailIfThereIsNoReward() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        // test execution
        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        assertEq(user1, nftStakingToken.ownerOf(mintedTokenId), "User has to be owner of newly minted token.");
        assertEq(
            0.01 ether, address(nftStakingToken).balance, "NftStakingToken has to have receive amount for nft mint."
        );

        nftStakingToken.safeTransferFrom(user1, address(stakeAndGetReward), mintedTokenId);
        assertEq(
            address(stakeAndGetReward),
            nftStakingToken.ownerOf(mintedTokenId),
            "StakeAndGetReward contract has to be owner of staked token."
        );

        vm.expectRevert(bytes("reward must be > 0"));
        stakeAndGetReward.collectReward(mintedTokenId);
    }

    function test_calculateRewardShouldFailIfTokenIsNotStaked() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        // test execution
        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();

        vm.expectRevert(bytes("TokenId is not staked with this contract."));
        stakeAndGetReward.calculateReward(mintedTokenId);
    }

    function test_onERC721ReceivedShouldFailIfContractIsNotOwnerOfToken() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        // test execution
        uint256 mintedTokenId = nftStakingToken.mint{value: 0.01 ether}();
        
        vm.expectRevert(bytes("TokenId is not staked with this contract."));
        stakeAndGetReward.onERC721Received(user1, user2, mintedTokenId, '');
    }
}
