# Third Web Staking ERC721 Optimization Report

## Summary

A token holder contract that can release its token balance gradually like a typical vesting scheme, with a cliff and vesting period. Optionally revocable by the 
owner.

## Scope

The code under review can be found in `src` folder. Contract reviewed is [ThirdWebStaking721.sol](src%2FThirdWebStaking721.sol)

## Tools Used
- Vscode
- Foundry

## Gas Optimizations

### [G-01] `isIndexed` mapping is used to determinate if tokenId is indexed 
Originally mapping `mapping(uint256 => bool) public isIndexed` is used which for each token takes full storage slot to save this information.  

Instead of mapping `BitMaps.BitMap` is being used. 

BitMaps pack 256 booleans across each bit of a single 256-bit slot of `uint256` type.
Hence, booleans corresponding to 256 _sequential_ indices would only consume a single slot,
unlike the regular `bool` which would consume an entire slot for a single value.

This results in gas savings in two ways:
 - Setting a zero value to non-zero only once every 256 times
 - Accessing the same warm slot for every 256 _sequential_ indices
 
### [G-02] Using unchecked block to increment index in for-loop iteration

Using `unchecked` block in for loop iterations so overflow/underflow 
is not checked during index incrementation so gas is saved when those checks are not applied.
```solidity
 for (uint256 i = 0; i < indexedTokenCount;) {
    ...

    unchecked {
        ++i;
    }
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

![04_thirdweb_staking721_original.png](images%2F04_thirdweb_staking721_original.png)

### Optimized

![04_thirdweb_staking721_optimization.png](images%2F04_thirdweb_staking721_optimization.png)