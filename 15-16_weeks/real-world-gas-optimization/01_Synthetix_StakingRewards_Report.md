# TraderJoe Token Vesting Optimization Report

## Summary

A contract to earn rewards through staking.

## Scope

The code under review can be found in `src` folder. Contract reviewed is [StakingRewards.sol](src/StakingRewards.sol)

## Tools Used
- Vscode
- Foundry

## Gas Optimizations

## [G-01] Optimze storage variables
Gas optimization here was focused on optimizing storage variables. 

### Initial storage variables:
```solidity
    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    // ---------------------------------------- ^ slot i
    uint256 public periodFinish = 0;
    // ---------------------------------------- ^ slot i + 1
    uint256 public rewardRate = 0;
    // ---------------------------------------- ^ slot i + 2
    uint256 public rewardsDuration = 7 days;
    // ---------------------------------------- ^ slot i + 3
    uint256 public lastUpdateTime;
    // ---------------------------------------- ^ slot i + 4
    uint256 public rewardPerTokenStored;
    // ---------------------------------------- ^ slot i + 5
    
    mapping(address => uint256) public userRewardPerTokenPaid;
    // ---------------------------------------- ^ slot i + 6
    mapping(address => uint256) public rewards;
    // ---------------------------------------- ^ slot i + 7
    
    uint256 private _totalSupply;
    // ---------------------------------------- ^ slot i + 8
    mapping(address => uint256) private _balances;
    // ---------------------------------------- ^ slot i + 9
```

So initially we are using 9 slots to store current variables.

### Optimized storage variables:
```solidity
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
```

- all `timestamp` types were adjusted to have `uint64` type, 
  - max value is `18446744073709551616`, when converted to date it is on `Sunday, July 21, 2554 11:34:33.709 PM`
- most of the token balance, reward fields are now `uint128` 
  - uin128 supports up to `340282366920938463463374607431768211456`, 
    - divided by `1e18` this is `340282366920938487808` tokens, which is suitable for any normal vesting usage
- also variables are ordered in a way to fits in fewer slots

## Gas report

### Original

![01_syntetix_staking_rewards_original.png](images%2F01_syntetix_staking_rewards_original.png)

### Optimized

![01_syntetix_staking_rewards_optimization.png](images%2F01_syntetix_staking_rewards_optimization.png)