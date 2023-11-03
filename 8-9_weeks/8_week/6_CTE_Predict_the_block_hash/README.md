# Predict the block hash

This one was hard for me. I tried a lot with some ideas, but ofcorse what ever idea I had it did not make sense, as block hash can be any from the past, since contract was deployed. 

I had to google it, and solution  is easy once you know details from solidity page about block hash: 

- https://docs.soliditylang.org/en/latest/units-and-global-variables.html

```
The block hashes are not available for all blocks for scalability reasons. You can only access the hashes of the most recent 256 blocks, all other values will be zero.
```