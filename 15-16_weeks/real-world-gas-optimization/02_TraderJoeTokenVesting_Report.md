# TraderJoe Token Vesting Optimization Report

## Summary

A token holder contract that can release its token balance gradually like a typical vesting scheme, with a cliff and vesting period. Optionally revocable by the 
owner.

## Scope

The code under review can be found in `src` folder. Contract reviewed is [TraderJoeTokenVesting.sol](src%2FTraderJoeTokenVesting.sol)

## Tools Used
- Vscode
- Foundry

## Gas Optimizations

### [G-01] `_released` mapping(address => uint256) has been replaced   
Originally `mapping(address => uint256) _released` has been used to store amount released per token address and `mapping(address => bool) private _revoked` to store if token 
support has been revoked. 

We have introduced new struct `TokenState(uint128 released; uint16 index)` which will be used to store _released data in struct with index on the same slot.

`released` type has been changed from `uint256` to `uint128` .  
`uint128` supports number up to 340282366920938463463374607431768211456, and if divided by 1e18 this is 340282366920938487808 tokens, which is
340282366920 billions tokens.
 
### [G-02] BitMap was introduced to store revoked info about token

In order to achieve this we need to have token index sequentially generated and also need to 

`BitMaps.BitMap private tokenRevocation` storage variable has been introduced where revoked token info is saved. In order to support this we
have added `addToken` method where `owner` adds token definition to contract and then index is assigned.

BitMaps pack 256 booleans across each bit of a single 256-bit slot of uint256 type. Hence, booleans corresponding to 256 sequential indices would only consume a single slot, unlike the regular bool which would consume an entire slot for a single value.

This results in gas savings in two ways:

- Setting a zero value to non-zero only once every 256 times 
- Accessing the same warm slot for every 256 sequential indices


## Gas report

### Original

![02_trader_joe_token_vesting_original.png](images%2F02_trader_joe_token_vesting_original.png)

### Optimized Without Bitmap

![02_trader_joe_token_vesting_optimization_NO_BITMAP.png](images%2F02_trader_joe_token_vesting_optimization_NO_BITMAP.png)

### Optimized

![02_trader_joe_token_vesting_optimization.png](images%2F02_trader_joe_token_vesting_optimization.png)