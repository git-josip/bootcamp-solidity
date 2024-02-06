# LooksRare TokenDistributor Optimization Report

## Summary

It handles the distribution of LOOKS token. It auto-adjusts block rewards over a set number of periods.

## Scope

The code under review can be found in `src` folder. Contract reviewed is [LookRareTokenDistributor.sol](src%2FLookRareTokenDistributor.sol)

## Tools Used
- Vscode
- Foundry

## Gas Optimizations

## [G-01] Optimize storage variables
Gas optimization here was focused on optimizing storage variables.

### Initial storage variables:
```solidity
    // Accumulated tokens per share
    uint256 public accTokenPerShare;
    // ---------------------------------------- ^ slot i
    
    // Current phase for rewards
    uint256 public currentPhase;
    // ---------------------------------------- ^ slot i + 1
    // Block number when rewards end
    uint256 public endBlock;
    
    // Block number of the last update
    uint256 public lastRewardBlock;
    // ---------------------------------------- ^ slot i + 2
    
    // Tokens distributed per block for other purposes (team + treasury + trading rewards)
    uint256 public rewardPerBlockForOthers;
    // ---------------------------------------- ^ slot i + 3
    
    // Tokens distributed per block for staking
    uint256 public rewardPerBlockForStaking;
    // ---------------------------------------- ^ slot i + 4
    
    // Total amount staked
    uint256 public totalAmountStaked;
    // ---------------------------------------- ^ slot i + 5
```

So initially we are using 9 slots to store current variables.

### Optimized storage variables:
```solidity
    // Block number when rewards end
    uint32 public endBlock;
    // ---------------------------------------- ^ slot i
    
    // Block number of the last update
    uint32 public lastRewardBlock;
    // ---------------------------------------- ^ slot i
    
    // Tokens distributed per block for other purposes (team + treasury + trading rewards)
    uint256 public rewardPerBlockForOthers;
    // ---------------------------------------- ^ slot i + 1
    
    // Accumulated tokens per share
    uint256 public accTokenPerShare;
    // ---------------------------------------- ^ slot i + 2
    
    // Tokens distributed per block for staking
    uint256 public rewardPerBlockForStaking;
    // ---------------------------------------- ^ slot i + 3
    
    // Total amount staked
    uint256 public totalAmountStaked;
```

- all `timestamp` types were adjusted to have `uint32` type, 
  - max value is `4294967296`, when converted to date it is on `Sunday, February 7, 2106 6:28:16 AM`

### [G-02] Reuse mapping access
Reusing access to mapping. On multiple places mapping was accessed on multiple lines in function and that can be extracted into memory variable. 
- `StakingPeriod memory stakingPeriodCurrPhase = stakingPeriod[adjustedCurrentPhase];`
```solidity
function calculatePendingRewards(address user) external view returns (uint256) {
    UserInfo memory userInfoDetails = userInfo[user];
    if ((block.number > lastRewardBlock) && (totalAmountStaked != 0)) {
        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);

        uint256 tokenRewardForStaking = multiplier * rewardPerBlockForStaking;

        uint256 adjustedEndBlock = endBlock;
        uint256 adjustedCurrentPhase = currentPhase;

        // Check whether to adjust multipliers and reward per block
        while ((block.number > adjustedEndBlock) && (adjustedCurrentPhase < (NUMBER_PERIODS - 1))) {
            // Update current phase
            ++adjustedCurrentPhase;

            StakingPeriod memory stakingPeriodCurrPhase = stakingPeriod[adjustedCurrentPhase];
            // Update rewards per block
            uint256 adjustedRewardPerBlockForStaking = stakingPeriodCurrPhase.rewardPerBlockForStaking;

            // Calculate adjusted block number
            uint256 previousEndBlock = adjustedEndBlock;

            // Update end block
            adjustedEndBlock = previousEndBlock + stakingPeriodCurrPhase.periodLengthInBlock;

            // Calculate new multiplier
            uint256 newMultiplier = (block.number <= adjustedEndBlock)
                ? (block.number - previousEndBlock)
                : stakingPeriodCurrPhase.periodLengthInBlock;

            ...
}
```


- `UserInfo memory userInfoDetails = userInfo[msg.sender];`
```solidity
function deposit(uint256 amount) external nonReentrant {
    require(amount > 0, "Deposit: Amount must be > 0");

    // Update pool information
    _updatePool();

    // Transfer LOOKS tokens to this contract
    looksRareToken.safeTransferFrom(msg.sender, address(this), amount);

    uint256 pendingRewards;

    UserInfo memory userInfoDetails = userInfo[msg.sender];

    // If not new deposit, calculate pending rewards (for auto-compounding)
    if (userInfoDetails.amount > 0) {
        pendingRewards =
            ((userInfoDetails.amount * accTokenPerShare) / PRECISION_FACTOR) -
            userInfoDetails.rewardDebt;
    }

    // Adjust user information
    userInfo[msg.sender].amount += (amount + pendingRewards);
    userInfo[msg.sender].rewardDebt = (userInfoDetails.amount * accTokenPerShare) / PRECISION_FACTOR;

    // Increase totalAmountStaked
    totalAmountStaked += (amount + pendingRewards);

    emit Deposit(msg.sender, amount, pendingRewards);
}
```

### [G-03] Increment uint using `++i`

Increment uint field using `++i` instead `i++`

The reason behind this is in way ++i and i++ are evaluated by the compiler.

i++ returns i(its old value) before incrementing i to a new value. This means that 2 values are stored on the stack for
usage whether you wish to use it or not. ++i on the other hand, evaluates the ++ operation on i (i.e it increments i)
then returns i (its incremented value) which means that only one item needs to be stored on the stack.


## Gas report

### Original

![03_looksrare_token_distributor_original.png](images%2F03_looksrare_token_distributor_original.png)

### Optimized

![03_looksrare_token_distributor_optimization.png](images%2F03_looksrare_token_distributor_optimization.png)