// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {IERC1363Receiver, IERC1363} from "@payabletoken/contracts/token/ERC1363/ERC1363.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

struct Transaction {
    address seller;
    address buyer;
    IERC1363 token;
    uint256 amount;
    uint256 lockedUntil;
    bool withdrawExecuted;
}

/**
 * @title EScrow transaction time lock mechanism implementation.
 * @author Josip Medic
 * @notice This contract implements ESCrow solution where a buyer can put an arbitrary ERC20 token into a contract
 * and a seller can withdraw it 3 days later.
 */
contract EScrow is Ownable2Step, IERC1363Receiver, IERC165, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;

    event Withdrawed(address indexed seller, uint256 tx_id, uint256 amount);
    event Deposited(address indexed buyer, address indexed seller, uint256 tx_id, uint256 amount);

    string public name;
    mapping(uint256 => Transaction) public lockedTransactions; // balances for seller

    constructor(string memory _name) ReentrancyGuard() {
        name = _name;
    }

    /**
     * @notice Handle the receipt of ERC1363 tokens.
     * After token is transffered to EScrow, then transaction fullfilment is created.
     * @dev Only transaction seller can execute this method.
     * @param _tx_id id of transaction for which EScrow fullfilment is created
     */
    function withdraw(uint256 _tx_id) external nonReentrant returns (bool) {
        Transaction memory transaction = lockedTransactions[_tx_id];

        require(transaction.seller == _msgSender(), "Only seller can invoke withdraw");
        require(transaction.lockedUntil > 0 && transaction.lockedUntil < block.timestamp, "This escrow still locked");
        require(transaction.withdrawExecuted == false, "Withdrawn is already executed");

        assert(transaction.token.balanceOf(address(this)) >= transaction.amount);

        lockedTransactions[_tx_id].withdrawExecuted = true;

        transaction.token.transfer(transaction.seller, transaction.amount);

        emit Withdrawed(msg.sender, _tx_id, transaction.amount);

        return true;
    }

    /**
     * @notice Handle the receipt of ERC1363 tokens.
     * After token is transffered to EScrow, then transaction fullfilment is created.
     * @dev See {IERC1363Receiver-onTransferReceived}.
     */
    function onTransferReceived(address, /*spender*/ address sender, uint256 amount, bytes calldata data)
        public
        override
        nonReentrant
        returns (bytes4)
    {
        require(_msgSender().isContract(), "msg.sender needs to be contract");
        require(
            IERC1363(_msgSender()).supportsInterface(type(IERC1363).interfaceId),
            "Contract needs to support IERC1363 interface."
        );
        require(IERC1363(_msgSender()).balanceOf(address(this)) >= amount, "Not enough tokens transfered");

        uint256 txId = uint256(abi.decode(data[:32], (bytes32)));
        address seller = address(uint160(uint256(abi.decode(data[32:], (bytes32)))));

        lockedTransactions[txId].seller = seller;
        lockedTransactions[txId].buyer = sender;
        lockedTransactions[txId].token = IERC1363(_msgSender());
        lockedTransactions[txId].amount = amount;
        lockedTransactions[txId].lockedUntil = block.timestamp + 3 days;
        lockedTransactions[txId].withdrawExecuted = false;

        emit Deposited(sender, seller, txId, amount);

        return IERC1363Receiver.onTransferReceived.selector;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return interfaceId == type(IERC1363Receiver).interfaceId;
    }

    /**
     * @notice rescue any token accidentally sent to this contract
     */
    function emergencyWithdrawToken(IERC20 token) external onlyOwner {
        require(token.balanceOf(address(this)) > 0, "EScrow does not have any balance on this token.");

        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }
}
