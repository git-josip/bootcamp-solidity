// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {ERC1363} from "@payabletoken/contracts/token/ERC1363/ERC1363.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface IRewardToken {
    function mint(address _to, uint256 _amount) external returns (bool success);
}

/**
 * @title ERC1363 fungible token which will be used for NFT staking reward
 * @author Josip Medic
 * @notice ERC20 token for staking reward
 * @dev Only stakingReward contract will be allowed to mint tokens
 */
contract RewardToken is ERC1363, IRewardToken {
    using SafeERC20 for ERC20;
    using Address for address;

    /**
     * @dev Only stakingReward is allowed to mint tokens
     */
    IERC721Receiver public stakingContract;

    constructor(IERC721Receiver _stakingContract) ERC20("Reward Staking Token", "RST") {
        require(address(_stakingContract).isContract(), "StakingContract must be contract not external account.");
        require(
            ERC165(address(_stakingContract)).supportsInterface(type(IERC721Receiver).interfaceId),
            "Contract must implement IERC721Receiver interafce."
        );

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
