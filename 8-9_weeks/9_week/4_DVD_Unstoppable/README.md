# Challenge #1 - Unstoppable

- https://www.damnvulnerabledefi.xyz/challenges/unstoppable/

```
There’s a tokenized vault with a million DVT tokens deposited. It’s offering flash loans for free, until the grace period ends.

To pass the challenge, make the vault stop offering flash loans.

You start with 10 DVT tokens in balance.
```

## Solution

If we transfer asset token without using `depoist` function to `UnstoppableVault` contract flash loan will fail, because this assert will fail in `flashLoan` function:

```
uint256 balanceBefore = totalAssets();
if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance(); // enforce ERC4626 requirement
```

as `totalAssets()` are claculate as `asset.balanceOf(address(this))` which causes this value to be different than `convertToShares` 
which is calculated as: 
```
   function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
    }
```


