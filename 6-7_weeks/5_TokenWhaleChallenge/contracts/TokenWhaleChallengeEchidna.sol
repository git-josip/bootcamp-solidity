// SPDX-License Identifier:MIT

pragma solidity 0.7.0;

import "./TokenWhaleChallenge.sol";

contract TokenWhaleChallengeEchidna is TokenWhaleChallenge {
    TokenWhaleChallenge public token;

    constructor() public TokenWhaleChallenge(msg.sender) {}

    function echidna_test_balance() public view returns (bool) {
        return !isComplete();
    }

    function testTransfer(address, uint256) public view {
        // Pre conditions
        // actions
        // Check that isComplete function returns true or false as expected
        assert(!isComplete());
    }
}