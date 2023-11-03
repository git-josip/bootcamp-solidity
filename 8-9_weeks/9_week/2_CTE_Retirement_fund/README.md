# Retirement fund

In `collectPenalty()` method we can see there is posibility for underflow if we manage to bring contract balance more than initial 1 ether.
```
function collectPenalty() public {
        require(msg.sender == beneficiary);
        uint256 withdrawn = 0;
        unchecked {
            withdrawn += startBalance - address(this).balance;

            // an early withdrawal occurred
            require(withdrawn > 0);
        }

        // penalty is what's left
        (bool ok, ) = msg.sender.call{value: address(this).balance}("");
        require(ok, "Transfer to msg.sender failed");
    }
``` 

As there is no payable function to receive ether we can create attacker contract that can send ether to some address by executing `selfdestruct()`.
````Self destruct is a built-in function in Solidity that allows you to effectively remove a contract from the blockchain and send its remaining ether to a designated recipient```