pragma solidity ^0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Inheritance
import "./interfaces/IStakingRewards.sol";
import "./Pausable.sol";

    struct UserState {
        uint256 userRewardPerTokenPaid;
        uint128 reward;
        uint128 balance;
    }

// https://docs.synthetix.io/contracts/source/contracts/stakingrewards
contract StakingRewards is IStakingRewards, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    address public rewardsDistribution;
    uint64 public periodFinish;
    uint64 public lastUpdateTime;
    // ---------------------------------------- ^ slot i
    uint128 public rewardPerTokenStored;
    uint64 public rewardsDuration = 7 days;
    // ---------------------------------------- ^ slot i + 1
    uint256 public rewardRate;
    // ---------------------------------------- ^ slot i + 2
    uint256 private _totalSupply;
    // ---------------------------------------- ^ slot i + 3
    mapping(address => UserState) public userStates;
    // ---------------------------------------- ^ slot i + 4

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _rewardsDistribution,
        address _rewardsToken,
        address _stakingToken
    ) payable {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        rewardsDistribution = _rewardsDistribution;
    }

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }

    function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
        rewardsDistribution = _rewardsDistribution;
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint128) {
        return userStates[account].balance;
    }

    function lastTimeRewardApplicable() public view returns (uint64) {
        return uint64(block.timestamp < periodFinish ? block.timestamp : periodFinish);
    }

    function rewardPerToken() public view returns (uint128) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return uint128(rewardPerTokenStored + ((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18) / _totalSupply);
    }

    function earned(address account) public view returns (uint128) {
        UserState memory userState = userStates[account];
        return uint128(userState.balance * (rewardPerToken() - userState.userRewardPerTokenPaid)/1e18) + userState.reward;
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate * rewardsDuration;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint128 amount) external nonReentrant notPaused updateReward(msg.sender) {
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        UserState storage userState = userStates[msg.sender];
        unchecked {
            _totalSupply = _totalSupply + amount;
            userState.balance = userState.balance + amount;
        }

        emit Staked(msg.sender, amount);
    }

    function withdraw(uint128 amount) public nonReentrant updateReward(msg.sender) {
        UserState storage userState = userStates[msg.sender];

        uint128 currentBalance = userState.balance;
        require(amount <= currentBalance);

        unchecked {
            _totalSupply = _totalSupply - amount;
            userState.balance = currentBalance - amount;
        }

        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        UserState storage userState = userStates[msg.sender];
        uint256 reward = userState.reward;
        if (reward > 0) {
            userState.reward = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external {
        withdraw(userStates[msg.sender].balance);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint256 reward) external onlyRewardsDistribution updateReward(address(0)) {
        uint256 currentTimestamp = block.timestamp;

        if (currentTimestamp >= periodFinish) {
            rewardRate = reward / rewardsDuration;
        } else {
            uint256 leftover;
            unchecked {
                uint256 remaining = periodFinish - currentTimestamp;
                leftover = remaining * rewardRate;
            }
            
            rewardRate = reward + (leftover / rewardsDuration);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint balance = rewardsToken.balanceOf(address(this));
        require(rewardRate <= balance / rewardsDuration, "Provided reward too high");

        lastUpdateTime = uint64(currentTimestamp);
        periodFinish = uint64(currentTimestamp + rewardsDuration);
        emit RewardAdded(reward);
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(stakingToken), "Cannot withdraw the staking token");
        IERC20(tokenAddress).safeTransfer(owner, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint32 _rewardsDuration) external onlyOwner {
        require(
            block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        UserState storage userState = userStates[account];
        if (account != address(0)) {
            userState.reward = earned(account);
            userState.userRewardPerTokenPaid = rewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);
}