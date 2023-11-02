# TrailOfBits Excercise 2

Run Echidna:
```
docker run --platform=linux/amd64 --rm -it -v `pwd`:/src ghcr.io/crytic/echidna/echidna bash -c "solc-select install 0.8.0 && solc-select use  0.8.0 && echidna --contract TokenEchidna src/TokenEchidna.sol --config src/config.yaml"
```


## Issue

Anyone can call `Owner()` method which changes owner.

# Fix

`onlyOnwer()` modifier needs to be added to `Owner()` method.