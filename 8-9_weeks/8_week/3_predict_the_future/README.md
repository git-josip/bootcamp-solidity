# Predict The Future

We know formula for calculating answer:
```
uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        ) % 10;
```

And we can see it it happening in the future as there is require statement `require(block.number > settlementBlockNumber);`, so 
we can not calculate answer and submit it in the same transaction, same block.
Actually needs to be at least 2 blocks ahead of `lockGuess` call.

## Solution

Answer will be number from 0~9, as calculation is divided by 10 (`%10`). 
We can first lock our guess, pick a number from 0~9, 
and then each block try to calculate answer and see is that our number.
After we can just settle, as block is ahead from when we locked it.