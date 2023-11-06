# Ethernaut: Level 15 - NaughtCoin

https://ethernaut.openzeppelin.com/level/15

```
NaughtCoin is an ERC20 token and you're already holding all of them. The catch is that you'll only be able to transfer them after a 10 year lockout period. Can you figure out how to get them out to another address so that you can transfer them freely? Complete this level by getting your token balance to 0.

  Things that might help

The ERC20 Spec
The OpenZeppelin codebase
```

## Solution

Hack is simple. We can see that only player can not execut transfer because of `lockTOkens` modifier, but if we approve someone else to transfer our tokens then that user/contract can transfer all tokens out.