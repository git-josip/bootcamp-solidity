// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {IERC721Receiver} from "openzeppelin/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {Ownable2Step} from "openzeppelin/access/Ownable2Step.sol";
import {Ownable} from "openzeppelin/access/Ownable2Step.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC165} from "openzeppelin/utils/introspection/ERC165.sol";
import {IRewardToken} from "./2_RewardToken.sol";
import {IERC1363} from "@payabletoken/contracts/token/ERC1363/IERC1363.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title ERC721 non fungible token which will be used for staking
 * @author Josip Medic
 * @notice ERC721 token for staking
 */
contract StakeAndGetReward is IERC721Receiver, ERC165, Ownable2Step {
    using Address for address;

    event TokenStaked(address indexed owner, uint256 indexed tokenId);
    event TokenUnStaked(address indexed owner, uint256 indexed tokenId, uint256 reward);
    event RewardCollected(address indexed owner, uint256 indexed tokenId, uint256 reward);

    struct NftDeposit {
        address owner;
        uint256 stakedAt;
    }

    uint256 private constant STAKE_REWARD_PER_DAY = 10 ether;
    IRewardToken public rewardTokenContract;
    IERC721 public nftStakeTokenContract;

    mapping(uint256 => NftDeposit) public nftDeposits;

    constructor(IERC721 _nftStakeTokenContract) Ownable() {
        require(
            address(_nftStakeTokenContract).isContract(), "NftStakeTokenContract must be contract not external account."
        );
        require(
            ERC165(address(_nftStakeTokenContract)).supportsInterface(type(IERC721).interfaceId),
            "Contract must implement IERC721 interafce."
        );

        nftStakeTokenContract = _nftStakeTokenContract;
    }

    /**
     * @notice AStake NFT and earn IRewardToken tokens
     * @param _tokenId id of minted NFT
     */
    function stake(uint256 _tokenId) external returns (bool sucess) {
        require(
            nftStakeTokenContract.ownerOf(_tokenId) == _msgSender(), "Sender must be owner of NFT which wants to stake."
        );
        require(nftDeposits[_tokenId].owner == address(0), "Token must not be already staked.");
        require(address(rewardTokenContract) != address(0), "RewardToken not set.");

        nftStakeTokenContract.safeTransferFrom(_msgSender(), address(this), _tokenId);
        sucess = true;
        emit TokenStaked(_msgSender(), _tokenId);
    }

    /**
     * @notice Address which originally staked NFT can unstake it and collect reward
     * @param _tokenId id of staked token
     */
    function unstake(uint256 _tokenId) external returns (bool sucess) {
        NftDeposit memory nftDeposit = nftDeposits[_tokenId];
        require(nftDeposit.owner == _msgSender(), "Only address who initaly staked NFT can un stake it.");
        uint256 rewardAmount = calculateReward(_tokenId);

        delete nftDeposits[_tokenId];
        if (rewardAmount > 0) {
            rewardTokenContract.mint(_msgSender(), rewardAmount);
        }
        nftStakeTokenContract.safeTransferFrom(address(this), _msgSender(), _tokenId);

        sucess = true;
        emit TokenUnStaked(_msgSender(), _tokenId, rewardAmount);
    }

    /**
     * @notice Address which originally staked NFT can collect reward and resumt staking
     * @param _tokenId id of staked token
     */
    function collectReward(uint256 _tokenId) external returns (bool sucess) {
        NftDeposit storage nftDeposit = nftDeposits[_tokenId];
        require(nftDeposit.owner == _msgSender(), "Only address who initaly staked NFT can collect reward.");
        uint256 rewardAmount = calculateReward(_tokenId);

        nftDeposit.stakedAt = block.timestamp;
        if (rewardAmount > 0) {
            rewardTokenContract.mint(_msgSender(), rewardAmount);
        }

        sucess = true;
        emit RewardCollected(_msgSender(), _tokenId, rewardAmount);
    }

    function onERC721Received(address, /*operator*/ address from, uint256 tokenId, bytes calldata /*data*/ )
        external
        override
        returns (bytes4)
    {
        require(
            nftStakeTokenContract.ownerOf(tokenId) == address(this),
            "StakeAndReward contract needs to be owner after transfer."
        );

        NftDeposit memory nftDeposit = NftDeposit({owner: from, stakedAt: block.timestamp});

        nftDeposits[tokenId] = nftDeposit;
        emit TokenStaked(_msgSender(), tokenId);

        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @notice Calculates reward for staking
     * @param _tokenId id of staked token
     */
    function calculateReward(uint256 _tokenId) public view returns (uint256 rewardAmount) {
        NftDeposit memory nftDeposit = nftDeposits[_tokenId];
        require(nftDeposit.stakedAt > 0, "TokenId is not staked with this contract.");

        uint256 timePassed = block.timestamp - nftDeposit.stakedAt;

        rewardAmount = (10 ether * timePassed) / 1 days;
    }

    /**
     * @notice Set rewardToken contract
     * @param _rewardTokenContract address of IRewardToken
     */
    function setRewardTokenContract(IRewardToken _rewardTokenContract) external onlyOwner {
        require(
            address(_rewardTokenContract).isContract(), "RewardTokenContract must be contract not external account."
        );
        require(
            ERC165(address(_rewardTokenContract)).supportsInterface(type(IERC1363).interfaceId),
            "Contract must implement IERC1363 interafce."
        );

        rewardTokenContract = _rewardTokenContract;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IERC721Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}
