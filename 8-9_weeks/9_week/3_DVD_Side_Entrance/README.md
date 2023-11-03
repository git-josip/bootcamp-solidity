# Challenge #4 - Side Entrance
- https://www.damnvulnerabledefi.xyz/challenges/side-entrance/
  
```
A surprisingly simple pool allows anyone to deposit ETH, and withdraw it at any point in time.

It has 1000 ETH in balance already, and is offering free flash loans using the deposited ETH to promote their system.

Starting with 1 ETH in balance, pass the challenge by taking all ETH from the pool.
```

## Solution

Key is in using flash loan funds. 
```
function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;

        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        if (address(this).balance < balanceBefore)
            revert RepayFailed();
    }
```

We can see that we can take whole amount from contract balance and do something with it as long we return that amount to token balance. 

So plan is to take whole amount from contract (100 ether) and in callback function (IFlashLoanEtherReceiver) of our exploit contract to call `deposit` with same funds. Doing that we are returning balance to contract but we are also increaing our withdraw allowance to 100 ether, and once we execute it we will take all funds form contract.