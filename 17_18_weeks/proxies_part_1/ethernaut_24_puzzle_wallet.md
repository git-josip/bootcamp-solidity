# Ethernaut 24 - Puzzle wallet

* first we are going to call `function proposeNewAdmin(address _newAdmin)` and with this we are setting `pendingAdmin`to address we want, but same slot is shared with `owner` that is used in `PuzzleWallet` . So basically with setting addmin we are going to become `owner`  in `PuzzleWallet` logic.
* as we are `owner` now we can whitelist our address by calling `function addToWhitelist(address addr) external` which has restriction that only owner can call it.
* as soon we are whitelisted we can interact with all other methods in `PuzzleWallet`logic. 
* we can send ETH from `PuzzleWallet` by calling `execute` method, but amount we will receive is one what is registred in `balances` mapping, which gets populated during `deposit` action
* we need to call `function multicall(bytes[] calldata data)` but somehow reues `msg.value` so it is counted 2 times. 
* there is a check that `msg.value` is already used for same function `deposit.selector` 
* that can be achived as multicall is called with `deposit.selector` and then again with `multicall.selector`, which will allow us to use msg,value two times.
* now as we have double balances than we deposited, we can drain contract by calling execute and get double amount