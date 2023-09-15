// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {IERC1363Receiver, IERC1363} from "@payabletoken/contracts/token/ERC1363/ERC1363.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

struct Transaction {
    address seller;
    address buyer;
    IERC1363 token;
    uint256 amount;
    uint256 lockedUntil;
    bool withdrawExecuted;
}

contract EScrow is Ownable, IERC1363Receiver, IERC165, ReentrancyGuard {
    string public name;
    mapping(uint256 => Transaction) public lockedTransactions; // balances for seller

    constructor(string memory _name) ReentrancyGuard() {
        name = _name;
    }

    function getTransaction(uint256 _tx_id) external view returns (Transaction memory) {
        return lockedTransactions[_tx_id];
    }

    function withdraw(uint256 _tx_id) external nonReentrant returns (bool) {
        Transaction storage transaction = lockedTransactions[_tx_id];

        require(transaction.seller == _msgSender(), "Only seller can invoke withdraw");
        require(transaction.lockedUntil > 0 && transaction.lockedUntil < block.timestamp, "This escrow still locked");
        require(transaction.withdrawExecuted == false, "Withdrawn is already executed");

        assert(transaction.token.balanceOf(address(this)) >= transaction.amount);

        transaction.withdrawExecuted = true;

        transaction.token.transfer(transaction.seller, transaction.amount);

        return true;
    }

    /**
     * @notice Handle the receipt of ERC1363 tokens.
     * @dev See {IERC1363Receiver-onTransferReceived}.
     */
    function onTransferReceived(address, /*spender*/ address sender, uint256 amount, bytes calldata data)
        public
        override
        returns (bytes4)
    {
        uint256 txId = uint256(abi.decode(data[:32], (bytes32)));
        address seller = address(uint160(uint256(abi.decode(data[32:], (bytes32)))));

        lockedTransactions[txId].seller = seller;
        lockedTransactions[txId].buyer = sender;
        lockedTransactions[txId].token = IERC1363(_msgSender());
        lockedTransactions[txId].amount = amount;
        lockedTransactions[txId].lockedUntil = block.timestamp + 3 days;
        lockedTransactions[txId].withdrawExecuted = false;

        return IERC1363Receiver.onTransferReceived.selector;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1363Receiver).interfaceId;
    }
}
