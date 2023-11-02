// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.7.0;

import "./Token.sol";

contract TokenEchidna is Token {
    function test_transfer(address to, uint256 value) public {
        // TODO: include `assert(condition)` statements that
        // detect a breaking invariant on a transfer.
        // Hint: you may use the following to wrap the original function.

        uint256 startingFromBalance = balances[msg.sender];
        uint256 startingToBalance = balances[to];

        super.transfer(to, value);

        assert(balances[msg.sender] <= startingFromBalance);
        assert(balances[to] >= startingToBalance);
    }
}