# 04 Damn Vulnerable DeFi - 2- NaiveReceiver

https://www.damnvulnerabledefi.xyz/challenges/naive-receiver/


A way to remove funds from `FlashLoanReceiver` user contract is to call pool with contract address and with amount less than poll balance, as on each transaction borrower pays `1 ETH` fee.  
THere is no validation that `msg.sender` is borrower.
