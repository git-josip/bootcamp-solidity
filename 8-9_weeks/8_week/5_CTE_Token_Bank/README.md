# Token Bank

* We can see that `player`  is allowed to call `TokenBankChallenge` and withdraw half of tokens in `SimpleERC223Token` by calling challenge contract function `withdraw`, as `player` has allowance or 500k `balanceOf[player] = 500000 * 10 ** 18; // half for you`: 
```
function withdraw(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount);

        require(token.transfer(msg.sender, amount));
        unchecked {
            balanceOf[msg.sender] -= amount;
        }
    }
```
* code above is not using `Check-Effect` pattern, as it is first transfering tokens and then updating balances, so it is vulnerable to reentracy attack. 

* it is important as well that our contract implements:
```
interface ITokenReceiver {
      function tokenFallback(
          address from,
          uint256 value,
          bytes memory data
      ) external;
  }
```
* this function will be called from token transfer and we will call `withdraw` function again until there are no tokens left, as fallback will be called on each `withdraw`, and we stop when there are no tokens left.