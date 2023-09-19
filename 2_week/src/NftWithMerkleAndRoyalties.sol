// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

/**
 * @title Smart contract trio: NFT with merkle tree discount, ERC20 token, staking contract
 * @author Josip Medic
 * @notice Implementation of ERC721 NFT with NFT Royalty Standard. Discounted minting implemented using verification of Merkle Tree proofs
 */

contract NftWithMerkleAndRoyalties is ERC721, ERC2981 {
    using BitMaps for BitMaps.BitMap;

    /**
     * @dev Default _feeDenominator in ERC2981 is 10_000. This value is equivalent to 2.5% as requested.
     */
    uint256 public constant defaultFeeNumerator = 250;

    uint256 public mintPriceInWei = 0.01 ether;
    uint256 public discountedMintPriceInWei = 0.005 ether;
    uint256 public maxSupply;
    bytes32 public immutable whitelistUsersMerkleRoot;
    BitMaps.BitMap private mintedTokens;

    constructor(string memory name_, string memory symbol_, uint256 _maxSupply, bytes32 _whitelistUsersMerkleRoot)
        ERC721(name_, symbol_)
    {
        require(_maxSupply > 0, "MaxSupply must be bigger than 0");

        maxSupply = _maxSupply;
        whitelistUsersMerkleRoot = _whitelistUsersMerkleRoot;
    }

    function discountMint(uint256 discountMintPass, bytes32[] calldata merkleProof)
        external
        payable
        returns (uint256 tokenId)
    {
        require(
            MerkleProof.verify(
                merkleProof,
                whitelistUsersMerkleRoot,
                keccak256(bytes.concat(keccak256(abi.encode(_msgSender(), discountMintPass))))
            ),
            "Merkle proof for provided discountPass/address combination is invalid"
        );
        require(mintedTokens.get(discountMintPass) == false, "Discount Mint pass already used.");
        require(msg.value == discountedMintPriceInWei, "Invalid amount passed. Price is not matched.");
        uint256 currentMaxSupply = maxSupply;
        require(currentMaxSupply > 1, "All tokes are minted.");

        mintedTokens.set(discountMintPass);
        _safeMint(_msgSender(), currentMaxSupply);
        unchecked {
            maxSupply = currentMaxSupply - 1;
        }

        tokenId = currentMaxSupply;
    }

    function mint() external payable returns (uint256 tokenId) {
        require(msg.value == mintPriceInWei, "Invalid amount passed. Price is not matched.");
        uint256 currentMaxSupply = maxSupply;
        require(currentMaxSupply > 1, "All tokes are minted.");

        _safeMint(_msgSender(), currentMaxSupply);
        unchecked {
            maxSupply = currentMaxSupply - 1;
        }

        tokenId = currentMaxSupply;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
