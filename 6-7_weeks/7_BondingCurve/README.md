## LinearBondingCurve from Week1

Run Echidna:
```
docker run --platform=linux/amd64 --rm -it -v `pwd`:/src ghcr.io/crytic/echidna/echidna bash -c "solc-select install 0.8.21 && solc-select use  0.8.21 && echidna --contract LinearBondingCurveEchidna src/contracts/LinearBondingCurveEchidna.sol --config src/config.yaml"
```

- test_buy_should_be_sucessful
- test_after_buy_price_increase
- test_sell_is_executed_if_tokens_are_sent_to_linearBondingCurve
- test_sell_is_executed_successfuly
- test_after_sell_price_decrease