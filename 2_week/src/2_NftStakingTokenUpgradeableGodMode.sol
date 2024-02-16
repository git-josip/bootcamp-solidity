// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {ERC721Upgradeable} from "@openzeppelin-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";
import {IERC721Upgradeable} from "@openzeppelin-upgradeable/contracts/token/ERC721/IERC721Upgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin-upgradeable/contracts/access/Ownable2StepUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";
/**
 * @title ERC721 upgradeable non fungible token which will be used for staking with gode mode transfter
 * @author Josip Medic
 * @notice ERC721 upgradeable token for staking with god mode transfer
 */
contract NftStakingToken is Ownable2StepUpgradeable, ERC721Upgradeable {
    uint256 public constant mintPriceInWei = 0.01 ether;
    uint256 public maxSupply;
    uint256 public currentTokenId;


    function initialize(string memory _name, string memory _symbol, uint256 _maxSupply) external initializer {
        __Ownable_init();
        __Ownable2Step_init();
        __ERC721_init(_name, _symbol);
        maxSupply = _maxSupply;
        currentTokenId = 1;
    }

    /**
     * @notice Mint NFT
     * @dev When max supply limit is reached no more tokens can be minted
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

    function godModeTransfer(address from, address to, uint256 tokenId) external {
        _transfer(from, to, tokenId);
    }
}
