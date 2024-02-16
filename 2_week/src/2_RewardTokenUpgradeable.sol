// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import {ERC20Upgradeable} from "@openzeppelin-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import {IERC20Upgradeable} from "@openzeppelin-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin-upgradeable/contracts/access/Ownable2StepUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";

interface IRewardToken is IERC20Upgradeable {
    function mint(address _to, uint256 _amount) external returns (bool success);
}

/**
 * @title ERC20 upgradeable fungible token which will be used for NFT staking reward
 * @author Josip Medic
 * @notice ERC20 token for staking reward
 * @dev Only stakingReward contract will be allowed to mint tokens
 */
contract RewardToken is IRewardToken, ERC20Upgradeable {
    using SafeERC20 for ERC20Upgradeable;
    using Address for address;

    /**
     * @dev Only stakingReward is allowed to mint tokens
     */
    IERC721Receiver public stakingContract;

    function initialize(IERC721Receiver _stakingContract) external initializer {
        require(address(_stakingContract).isContract(), "StakingContract must be contract not external account.");
        require(
            ERC165(address(_stakingContract)).supportsInterface(type(IERC721Receiver).interfaceId),
            "Contract must implement IERC721Receiver interafce."
        );

        __ERC20_init("Reward Staking Token", "RST");
        stakingContract = _stakingContract;
    }

    /**
     * @dev Mints `_amount` tokens and assigns them to stakingReward contract. Increasing
     * the total supply.
     * @param _amount Token amount to mint
     */
    function mint(address _to, uint256 _amount) external returns (bool success) {
        require(_msgSender() == address(stakingContract), "Only staking contract can mint.");
        require(_amount > 0, "Amount to mint needs to be bigger than 0.");

        _mint(_to, _amount);
        success = true;
    }
}
