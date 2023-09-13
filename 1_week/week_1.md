## ERC777 and ERC1363

## ERC777 summarry

This standard defines a new way to interact with a token contract while remaining backward compatible with ERC-20.

It defines advanced features to interact with tokens. Namely, operators to send tokens on behalf of another address—contract or regular account—and send/receive hooks to offer token holders more control over their tokens.

It takes advantage of ERC-1820 to find out whether and where to notify contracts and regular addresses when they receive tokens as well as to allow compatibility with already-deployed contracts.



## ERC1363 summarry

The ERC1363 is an ERC20 compatible token that can make a callback on the receiver contract to notify token transfers or token approvals.
It means that we can add a callback after transferring or approving tokens to be executed.

This is an implementation of the EIP-1363, that defines a token interface for EIP-20 tokens that supports executing recipient contract code after transfer or transferFrom, or spender contract code after approve in a single transaction.