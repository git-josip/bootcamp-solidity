# Guess The Secret Number

As we know secret hash of number we can iterate trough all possible values and calculate the hash and compare it with known value.

```
function Exploiter() public view returns (uint8) {
        uint8 n;

        for (uint8 i = 0; i < type(uint8).max; i++) {
            bytes32 maybeNumberHash = keccak256(abi.encodePacked(i));
            if(maybeNumberHash == answerHash) {
                n = i;
            }
        }
        return n;
    }
```