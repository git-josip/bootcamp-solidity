# Token Whale

- addres A has balance of 1000 tokens.
- address A approved address B to allowance of some number
- then address B calls `transferFrom(A, A, 10)` using amount less than 1000, which is maximum A can send.
- as `transferFrom` is calling internally `_transfer` which is then updating balance of `msg.sender` and sender in this case is `B` and address `B` does not have balance, underflow happens.
- which is resulting `B` has now huge aount of tokens and can send that tokens to anyone.