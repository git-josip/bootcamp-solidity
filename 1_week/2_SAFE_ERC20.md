## Safe ERC20

Wrappers around ERC20 operations that throw on failure (when the token contract returns false). Tokens that return no value (and instead revert or throw on failure) are also supported, non-reverting calls are assumed to be successful. 

It is a wrapper around the interface that eliminates the need to handle boolean return values