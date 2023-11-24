## Ethernaut - Level 23 - DEX 2

https://ethernaut.openzeppelin.com/level/23


# Swap
| DEX Token1   |      DEX Token2   | USER Token1   |      USER Token2   |
|--------------|:-------------:|-------------------:|------------------:|
| 100 |  100 | 10 | 10 |
| 110 |   90 |  0 | 20 |   
| 86  |  110 | 24 | 0  |  
| 110 |  80  | 0  | 30 |   
| 69  |  110 | 41 | 0  |  
| 110 |  45  | 0  | 65 |  
| 0   |  90  | 110| 20 |


Each swap we swap all we have from token that we get in last swap, except in the las step, where we ned to calculate how mush we need to send of Token2 to drain all Token1 from DEX.

amount * 110 / 45 = 110 (Token1 dex balance)
amount = 45

We need to send in last step 45 Token2 to drain all Token1.


We have now token1 drained to 0. In order to drain token2 to zero we will use same techique but with some dummy token, as there is no restrictions like in DEX1 that in swap tokens needs to be token1 and token2.

## Hardhat
Run: 
- `npm install`
- `npx hardhat test --verbose`





