// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
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
    uint96 public constant defaultFeeNumerator = 250;

    uint256 public mintPriceInWei = 0.01 ether;
    uint256 public discountedMintPriceInWei = 0.005 ether;
    uint256 public immutable maxSupply;
    uint256 currentTokenId = 1;
    bytes32 public immutable whitelistUsersMerkleRoot;
    BitMaps.BitMap private mintedTokens;

    constructor(string memory name_, string memory symbol_, uint256 _maxSupply, bytes32 _whitelistUsersMerkleRoot)
        ERC721(name_, symbol_)
    {
        require(_maxSupply > 0, "MaxSupply must be bigger than 0");

        maxSupply = _maxSupply + 1;
        whitelistUsersMerkleRoot = _whitelistUsersMerkleRoot;

        /**
         * @dev To lower gas we will initliaze on contract creation first bitMap bucket as we know that our
         * presale mint passes will be in first bitmap bucket as we are ones that are definig it.
         */
        BitMaps.setTo(mintedTokens, 255, true);
        _setDefaultRoyalty(_msgSender(), defaultFeeNumerator);
    }

    /**
     * @notice Executes discount NFT mint if user is whitelisted to mint at discounted price
     * @dev ETH value sent needs to match token discountedPrice
     * @param _mintPass pass which has been provided to user
     * @param _merkleProof minimal MerleProof need to construct MerkleRoot using provided pass and sender adress
     */
    function preSaleMint(uint256 _mintPass, bytes32[] calldata _merkleProof)
        external
        payable
        returns (uint256 mintedTokenId)
    {
        require(
            MerkleProof.verify(
                _merkleProof,
                whitelistUsersMerkleRoot,
                keccak256(bytes.concat(keccak256(abi.encode(_msgSender(), _mintPass))))
            ),
            "Merkle proof for provided discountPass/address combination is invalid"
        );
        require(BitMaps.get(mintedTokens, _mintPass) == false, "Discount Mint pass already used.");
        require(msg.value == discountedMintPriceInWei, "Invalid amount passed. Price is not matched.");
        uint256 tokenId = currentTokenId;
        require(tokenId < maxSupply, "All tokes are minted.");

        BitMaps.setTo(mintedTokens, _mintPass, true);
        unchecked {
            currentTokenId = tokenId + 1;
        }
        _safeMint(_msgSender(), tokenId);

        mintedTokenId = tokenId;
    }

    /**
     * @notice Executes regular NFT mint at regular price
     * @dev ETH value sent needs to match token price
     */
    function mint() external payable returns (uint256 mintedTokenId) {
        require(msg.value == mintPriceInWei, "Invalid amount passed. Price is not matched.");
        uint256 tokenId = currentTokenId;
        require(tokenId < maxSupply, "All tokes are minted.");

        unchecked {
            currentTokenId = tokenId + 1;
        }
        _safeMint(_msgSender(), tokenId);

        mintedTokenId = tokenId;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
