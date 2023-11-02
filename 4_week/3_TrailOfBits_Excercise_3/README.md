# TrailOfBits Excercise 2

Run Echidna:
```
docker run --platform=linux/amd64 --rm -it -v `pwd`:/src ghcr.io/crytic/echidna/echidna bash -c "solc-select install 0.8.0 && solc-select use  0.8.0 && echidna --contract TokenEchidna src/TokenEchidna.sol --config src/config.yaml"
```


## Issue

Issue is in `mint(0)` function. 
```
function mint(uint256 value) public onlyOwner {
        require(int256(value) + totalMinted < totalMintable);
        totalMinted += int256(value);

        balances[msg.sender] += value;
    }
```

We are converting uint256 to int256. 
Max value for `uint256 = 2^256 -1` and max value for `int256 = 2^255 - 1`. So if we send value more than `2^255 - 1` conversion
`int256(value)` will go to negative number, and then require section is is always true, as negative number is less than 0.

# Fix

We can use `uint256` type instead of `int256`