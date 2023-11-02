// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {NftNumerable} from "./3_NftNumerable.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title ERC721Enumerable non fungible token
 * @author Josip Medic
 * @notice ERC721Enumerable NFT
 */
contract NftNumerableHelper {
    using Address for address;

    uint256 private constant EXP_MOD_BASE = 2;

    IERC721Enumerable private nftCollectionContract;

    constructor(IERC721Enumerable _nftCollectionContract) {
        require(address(_nftCollectionContract).isContract(), "NftCollection must be contract not external account.");
        require(
            ERC165(address(_nftCollectionContract)).supportsInterface(type(IERC721Enumerable).interfaceId),
            "Contract must implement IERC721Enumerable interafce"
        );

        nftCollectionContract = _nftCollectionContract;
    }

    /**
     * @dev Returns sum of owners tokenIds which are prime numbers
     */
    function primeNumberTokenIdsForOwner(address owner) external view returns (uint256 result) {
        require(address(owner) != address(0), "Address must not be address(0).");

        uint256 numberOfTokens = nftCollectionContract.balanceOf(owner);
        result = 0;

        for (uint256 i = 0; i < numberOfTokens; ++i) {
            uint256 tokenId = nftCollectionContract.tokenOfOwnerByIndex(owner, i);

            if (isPrime(tokenId)) {
                result++;
            }
        }
    }

    /**
     * @dev Fermat's little theorem states that if p is a prime number,
     * then for any integer a, the number a*p − a is an integer multiple of p.
     * In the notation of modular arithmetic, this is expressed as:
     *  a ^ p = a (mod n)
     */
    function isPrime(uint256 n) public view returns (bool result) {
        if (n < 2) {
            return false;
        }
        if (n == 2) {
            return true;
        }

        result = expmod(EXP_MOD_BASE, n, n) == EXP_MOD_BASE;
    }

    /**
     * @dev Use precompile expmod to calculate modular exponentiation
     */
    function expmod(uint256 base, uint256 exponent, uint256 modulus) internal view returns (uint256 result) {
        assembly {
            // define pointer
            let p := mload(0x40)
            // store data assembly-favouring ways
            mstore(p, 0x20) // Length of Base
            mstore(add(p, 0x20), 0x20) // Length of Exponent
            mstore(add(p, 0x40), 0x20) // Length of Modulus
            mstore(add(p, 0x60), base) // Base
            mstore(add(p, 0x80), exponent) // Exponent
            mstore(add(p, 0xa0), modulus) // Modulus
            if iszero(staticcall(sub(gas(), 2000), 0x05, p, 0xc0, p, 0x20)) { revert(0, 0) }

            result := mload(p)
        }
    }
}
