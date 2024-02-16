# Ethernaut 25 - Motorbike

* this contract is using UUPS (Universal upgradeable proxy standard) which means contract upgrade logic will be in the implementation contract and not the proxy contract.
* we can see `initialize` function is being called from Proxy contract during creation, but that is happening only in proxy contract storage context
* we can still call `initialize` function on implementation contract nd become `upgrader` which then can upgrade implemnation logic to our malicous contract which will call selfdestruct