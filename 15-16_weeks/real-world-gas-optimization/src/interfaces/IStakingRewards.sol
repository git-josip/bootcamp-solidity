pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// https://docs.synthetix.io/contracts/source/interfaces/istakingrewards
interface IStakingRewards {
    // Views

    function balanceOf(address account) external view returns (uint128);

    function earned(address account) external view returns (uint128);

    function getRewardForDuration() external view returns (uint256);

    function lastTimeRewardApplicable() external view returns (uint64);

    function rewardPerToken() external view returns (uint128);

    function rewardsDistribution() external view returns (address);

    function rewardsToken() external view returns (IERC20);

    function totalSupply() external view returns (uint256);

    // Mutative

    function exit() external;

    function getReward() external;

    function stake(uint128 amount) external;

    function withdraw(uint128 amount) external;
}