// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {Ownable2Step} from "openzeppelin/access/Ownable2Step.sol";
import {Ownable} from "openzeppelin/access/Ownable2Step.sol";

/**
 * @title ERC721 non fungible token which will be used for staking
 * @author Josip Medic
 * @notice ERC721 token for staking
 */
contract NftStakingToken is Ownable2Step, ERC721 {
    uint256 public constant mintPriceInWei = 0.01 ether;
    uint256 public immutable maxSupply;
    uint256 currentTokenId = 1;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) Ownable() ERC721(_name, _symbol) {
        maxSupply = _maxSupply;
    }

    /**
     * @notice Mint NFT
     */
    function mint() public payable returns (uint256 mintedTokenId) {
        require(msg.value == mintPriceInWei, "Invalid amount passed. Price is not matched.");
        uint256 tokenId = currentTokenId;
        require(tokenId < maxSupply, "All tokes are minted.");

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
