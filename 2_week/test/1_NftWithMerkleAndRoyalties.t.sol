// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Test, console2} from "forge-std/Test.sol";
import {NftWithMerkleAndRoyalties} from "../src/1_NftWithMerkleAndRoyalties.sol";
import {Merkle} from "@murky/Merkle.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TokenWithSanctionsTest is Test {
    NftWithMerkleAndRoyalties public nftWithMerkleAndRoyalties;

    address internal owner;

    Merkle internal merkleTree;
    bytes32 internal merkleRoot;
    bytes32[] internal merkleData;

    function getDiscountPassAndUserAtIndex(uint256 i) private pure returns (address user, uint256 discountPass) {
        require(i < 100);

        user = vm.addr(i + 1);
        discountPass = i + 10;
    }

    function setUp() public {
        owner = vm.addr(100);
        vm.label(owner, "owner");

        // MerkleTree setup
        merkleTree = new Merkle();
        merkleData = new bytes32[](100);
        for (uint256 i = 0; i < 100; i++) {
            (address user, uint256 discountPass) = getDiscountPassAndUserAtIndex(i);
            vm.label(user, string.concat("user", Strings.toString(i + 1)));
            merkleData[i] = keccak256(bytes.concat(keccak256(abi.encode(user, discountPass))));
        }
        merkleRoot = merkleTree.getRoot(merkleData);

        vm.prank(owner);
        nftWithMerkleAndRoyalties = new NftWithMerkleAndRoyalties("RareSkills NFT", "RNFT", 20, merkleRoot);
    }

    function test_WhitelistedUserCanMintTokensOnDicountPrice() public {
        // test execution
        for (uint256 i = 0; i < 20; i++) {
            (address user, uint256 discountPass) = getDiscountPassAndUserAtIndex(i);
            vm.startPrank(user);
            vm.deal(user, 10 ether);

            uint256 tokenId = nftWithMerkleAndRoyalties.preSaleMint{value: 0.005 ether}(
                discountPass, merkleTree.getProof(merkleData, i)
            );

            assertEq(user, nftWithMerkleAndRoyalties.ownerOf(tokenId), "User has to mbe owner of newly minted token.");
        }
    }

    function test_NonWhitelistedUserCanBuyTokenForNormalPrice() public {
        // test execution
        address nonWhitelistedUser = vm.addr(500);
        vm.startPrank(nonWhitelistedUser);
        vm.deal(nonWhitelistedUser, 10 ether);

        uint256 tokenId = nftWithMerkleAndRoyalties.mint{value: 0.01 ether}();
        assertEq(
            nonWhitelistedUser,
            nftWithMerkleAndRoyalties.ownerOf(tokenId),
            "User has to mbe owner of newly minted token."
        );
    }

    function test_PresaleMintShouldFailIfInvalidPassIsProvided() public {
        // setup
        (address user,) = getDiscountPassAndUserAtIndex(10);
        vm.startPrank(user);
        vm.deal(user, 10 ether);

        // test execution
        bytes32[] memory merkleProof = merkleTree.getProof(merkleData, 10);
        vm.expectRevert(bytes("Merkle proof for provided discountPass/address combination is invalid"));
        nftWithMerkleAndRoyalties.preSaleMint{value: 0.005 ether}(111, merkleProof);
    }

    function test_PresaleMintShouldFailIfInvalidProofIsProvided() public {
        // setup
        (address user, uint256 discountPass) = getDiscountPassAndUserAtIndex(10);
        vm.startPrank(user);
        vm.deal(user, 10 ether);

        // test execution
        bytes32[] memory merkleProof = merkleTree.getProof(merkleData, 88);
        vm.expectRevert(bytes("Merkle proof for provided discountPass/address combination is invalid"));
        nftWithMerkleAndRoyalties.preSaleMint{value: 0.005 ether}(discountPass, merkleProof);
    }

    function test_PresaleMintShouldFailIfAmountNotMatchingPriceIsSent() public {
        // setup
        (address user, uint256 discountPass) = getDiscountPassAndUserAtIndex(50);
        vm.startPrank(user);
        vm.deal(user, 10 ether);

        // test execution
        bytes32[] memory merkleProof = merkleTree.getProof(merkleData, 50);
        vm.expectRevert(bytes("Invalid amount passed. Price is not matched."));
        nftWithMerkleAndRoyalties.preSaleMint{value: 0.006 ether}(discountPass, merkleProof);
    }

    function test_NormalMintShouldFailIfAmountNotMatchingPriceIsSent() public {
        // test execution
        address nonWhitelistedUser = vm.addr(500);
        vm.startPrank(nonWhitelistedUser);
        vm.deal(nonWhitelistedUser, 10 ether);

        vm.expectRevert(bytes("Invalid amount passed. Price is not matched."));
        nftWithMerkleAndRoyalties.mint{value: 0.006 ether}();
    }

    function test_PresaleMintShouldFailIfAlredyUsedPassIsProvided() public {
        // setup
        (address user, uint256 discountPass) = getDiscountPassAndUserAtIndex(10);
        vm.startPrank(user);
        vm.deal(user, 10 ether);

        // test execution
        bytes32[] memory merkleProof = merkleTree.getProof(merkleData, 10);
        nftWithMerkleAndRoyalties.preSaleMint{value: 0.005 ether}(discountPass, merkleProof);

        vm.expectRevert(bytes("Discount Mint pass already used."));
        nftWithMerkleAndRoyalties.preSaleMint{value: 0.005 ether}(discountPass, merkleProof);
    }

    function test_PresaleMintShouldFailIfMaxTOkenSuplpyIsReached() public {
        // setup
        for (uint256 i = 0; i < 20; i++) {
            (address user, uint256 discountPass) = getDiscountPassAndUserAtIndex(i);
            vm.startPrank(user);
            vm.deal(user, 10 ether);

            uint256 tokenId = nftWithMerkleAndRoyalties.preSaleMint{value: 0.005 ether}(
                discountPass, merkleTree.getProof(merkleData, i)
            );
            assertEq(user, nftWithMerkleAndRoyalties.ownerOf(tokenId), "User has to mbe owner of newly minted token.");
        }

        (address otherUser, uint256 otherPass) = getDiscountPassAndUserAtIndex(50);
        vm.startPrank(otherUser);
        vm.deal(otherUser, 10 ether);

        // test execution
        bytes32[] memory merkleProof = merkleTree.getProof(merkleData, 50);
        vm.expectRevert(bytes("All tokes are minted."));
        nftWithMerkleAndRoyalties.preSaleMint{value: 0.005 ether}(otherPass, merkleProof);
    }

    function test_MintShouldFailIfMaxTOkenSuplpyIsReached() public {
        // setup
        for (uint256 i = 0; i < 20; i++) {
            (address user, uint256 discountPass) = getDiscountPassAndUserAtIndex(i);
            vm.startPrank(user);
            vm.deal(user, 10 ether);

            uint256 tokenId = nftWithMerkleAndRoyalties.preSaleMint{value: 0.005 ether}(
                discountPass, merkleTree.getProof(merkleData, i)
            );
            assertEq(user, nftWithMerkleAndRoyalties.ownerOf(tokenId), "User has to mbe owner of newly minted token.");
        }

        address otherUser = vm.addr(50);
        vm.startPrank(otherUser);
        vm.deal(otherUser, 10 ether);

        // test execution
        vm.expectRevert(bytes("All tokes are minted."));
        nftWithMerkleAndRoyalties.mint{value: 0.01 ether}();
    }

    function test_RoyaltyInfoReturnedShouldBe_2_5_Percent() public {
        // setup
        (address user, uint256 discountPass) = getDiscountPassAndUserAtIndex(10);
        vm.startPrank(user);
        vm.deal(user, 10 ether);

        // test execution
        bytes32[] memory merkleProof = merkleTree.getProof(merkleData, 10);
        uint256 tokenId = nftWithMerkleAndRoyalties.preSaleMint{value: 0.005 ether}(discountPass, merkleProof);

        (address addresToPayRoyalty, uint256 royaltyAmount) = nftWithMerkleAndRoyalties.royaltyInfo(tokenId, 10 ether);

        assertEq(owner, addresToPayRoyalty, "Creator of NFT should be one to receive royalty payments.");
        assertEq(0.25 ether, royaltyAmount, "Royalty amount should be 2.5% of sale price.");
    }
}
