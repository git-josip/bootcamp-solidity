# Ethernaut 13 -  GateKeeper One

## gateOne()

```
modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }
```

In order to pass getOne we need to call gatekeepr from another contract so msg.sender is different than tx.origin.

## gateTwo()

```
 modifier gateTwo() {
    require(gasleft() % 8191 == 0);
    _;
  }
```

This one either you can look into remix debug or we can do it in foreach and try different values. 
Smallest value I got was `{gas: 24841}`

## gateThree()
bytes8 key = bytes8(uint64(uint160(tx.origin))) & 0x0000000F0000FFFF;

```
modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;
  }
```

- `uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)`

Here we can see that bytes8 downscaled to bytes4 needs to be equal than bytes2. And we can see that it needs to consist of `tx.origin`
To achieve this we need to apply bitmasking of last 4 bytes in that way that uing32 and uint16 are the same.
We can do it by using `0x0000FFFF`. As `0xFFFF` and `0x0000FFFF` are same numbers.

- `uint32(uint64(_gateKey)) != uint64(_gateKey)`

To achieve this we need to make sure uint32 and uint64 (bytes4 and bytes8) are different. TO achive this we need in bit masking make that at least one bit is not 0 in bit masking 
for range more than bytes8. So we can apply `0x0000000F0000FFFF`.

- `uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)`

This one is same as first equality we covered.