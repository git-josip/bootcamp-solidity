// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable2Step} from "openzeppelin/access/Ownable2Step.sol";
import {Ownable} from "openzeppelin/access/Ownable2Step.sol";

/**
 * @title ERC721Enumerable non fungible token
 * @author Josip Medic
 * @notice ERC721Enumerable NFT
 */
contract NftNumerable is Ownable2Step, ERC721Enumerable {
    uint256 public constant mintPriceInWei = 0.01 ether;
    uint256 public constant MAX_SUPPLY = 20;
    uint256 currentTokenId = 1;

    constructor(string memory _name, string memory _symbol) Ownable() ERC721(_name, _symbol) {}

    /**
     * @notice Mint NFT.
     * @dev When max supply limit is reached no more tokens can be minted
     */
    function mint() public payable returns (uint256 mintedTokenId) {
        require(msg.value == mintPriceInWei, "Invalid amount passed. Price is not matched.");
        uint256 tokenId = currentTokenId;
        require(tokenId - 1 < MAX_SUPPLY, "All tokes are minted.");

        unchecked {
            currentTokenId = tokenId + 1;
        }
        _safeMint(_msgSender(), tokenId);

        mintedTokenId = tokenId;
    }

    function withdrawEther() external onlyOwner {
        (bool sent,) = payable(owner()).call{value: address(this).balance}("");
        require(sent, "Failed to withdraw Ether");
    }
}
