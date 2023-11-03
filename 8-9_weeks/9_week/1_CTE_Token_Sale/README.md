# Token Sale

I have used value 415992086870360064, as that is value of wei I need to send to buy huge amount of tokens. That is less than 1 ether, 0.415 ETH.

Par of code where total is calculated can go in overflow as is in unchecked:
```
 function buy(uint256 numTokens) public payable returns (uint256) {
        uint256 total = 0;
        unchecked {
            total += numTokens * PRICE_PER_TOKEN;
        }
        require(msg.value == total);

        balanceOf[msg.sender] += numTokens;
        return (total);
    }
``` 

In thi smethod number of tokens is multiplied by 1 ether, so in order to achieve overflow for some amount of ether, I have first divided by 1 ether and then just added 1. This resultd I need to send 415992086870360064 of wei in roder to aquired huge amount of tokens = (type(uint256).max / (1 ether)) + 1

