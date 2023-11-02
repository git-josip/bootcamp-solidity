# TrailOfBits Excercise 1

Run Echidna:
```
docker run --platform=linux/amd64 --rm -it -v `pwd`:/src ghcr.io/crytic/echidna/echidna bash -c "solc-select install 0.7.0 && solc-select use  0.7.0 && echidna --contract TokenEchidna src/TokenEchidna.sol --config src/config.yaml"
```


## Issue

As solidity version in use is less than 0.8, and as there is no check in `transfer` method it is easily possible to do in uderflow or overflow and then balance can go much higher than limit of 10_000. 

# Fix

Check for user balance when transfering tokens so that no one can transfer more token than it has. 