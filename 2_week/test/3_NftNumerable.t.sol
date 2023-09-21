// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {NftNumerable} from "../src/3_NftNumerable.sol";
import {NftNumerableHelper} from "../src/3_NftNumerableHelper.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NftNumerableTest is Test {
    NftNumerable public nftNumerable;
    NftNumerableHelper public nftNumerableHelper;

    address internal owner;
    address internal user1;

    function setUp() public {
        owner = vm.addr(100);
        vm.label(owner, "owner");

        user1 = vm.addr(1);
        vm.label(user1, "user1");

        vm.prank(owner);
        nftNumerable = new NftNumerable("RareSkills NFT", "RNFT");
        nftNumerableHelper = new NftNumerableHelper(nftNumerable);
    }

    function test_FunctionIsPrimeShoudCalculate1_000_000t_PRimeNumberAsPrime() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        uint256 prime_1_000_000th = 15_485_863;

        bool isPrime = nftNumerableHelper.isPrime(prime_1_000_000th);

        assertTrue(isPrime, "1_000_000th has to be checkd as prime number");
    }

    function test_FunctionPrimeNumberTokenIdsForOwnerShouldReturnCorretNumberOfPrimeTokenIds() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        for (uint256 i = 0; i < nftNumerable.MAX_SUPPLY(); i++) {
            nftNumerable.mint{value: 0.01 ether}();
        }

        uint256 primeTokenIds = nftNumerableHelper.primeNumberTokenIdsForOwner(user1);

        // prime numbers from 1 to 20: 2, 3, 5, 7, 11, 13, 17 and 19
        assertEq(8, primeTokenIds, "There are 8 prime numebrs from 1 to 20.");
    }
}
