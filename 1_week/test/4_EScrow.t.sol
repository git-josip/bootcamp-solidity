// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Test, console2} from "forge-std/Test.sol";
import {EScrow} from "../src/4_EScrow.sol";
import {TokenWIthGodMode} from "../src/2_TokenWIthGodMode.sol";
import {IERC1363} from "@payabletoken/contracts/token/ERC1363/ERC1363.sol";

struct Transaction {
    address seller;
    address buyer;
    IERC1363 token;
    uint256 amount;
    uint256 lockedUntil;
    bool withdrawExecuted;
}

contract EScrowTest is Test {
    EScrow public escrow;

    address internal owner;
    address internal user1;
    address internal user2;

    function setUp() public {
        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        owner = vm.addr(8);
        vm.label(owner, "owner");

        vm.prank(owner);
        escrow = new EScrow("RareSkills EScrow");
    }

    function test_BuyerShouldBeAbleToInitiateEscrow() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);
        TokenWIthGodMode transactionToken = new TokenWIthGodMode("TX Token", "TXT", 1000 * 10 ** 18);

        uint256 user1TokensAmount = 100 * 10 ** transactionToken.decimals();
        transactionToken.transfer(user1, user1TokensAmount);
        assertEq(user1TokensAmount, transactionToken.balanceOf(user1), "User1 needs to have transfered tokens.");

        // test execution
        uint256 transactionId = 18;

        uint256 priceToPayToSeller = 20 * 10 ** transactionToken.decimals();

        vm.startPrank(user1);

        bytes32 transactionIdEncoded = bytes32(transactionId);
        bytes32 sellerEncoded = bytes32(uint256(uint160(user2)));

        bytes memory customTransferData = new bytes(64);
        assembly {
            mstore(add(customTransferData, 32), transactionIdEncoded)
            mstore(add(customTransferData, 64), sellerEncoded)
        }

        uint256 currentTime = block.timestamp;
        transactionToken.transferAndCall(address(escrow), priceToPayToSeller, customTransferData);

        (address seller, address buyer, IERC1363 token, uint256 amount, uint256 lockedUntil, bool withdrawExecuted) =
            escrow.lockedTransactions(transactionId);

        assertEq(user1, buyer, "Seller shoud be user1");
        assertEq(user2, seller, "Seller shoud be user2");
        assertEq(address(transactionToken), address(token), "Transaction token needs to be one we setup at start.");
        assertEq(amount, priceToPayToSeller, "Locked token amount needs to be same as priceToPayToSeller");
        assertEq(currentTime + 3 days, lockedUntil, "Locked until needs to be 3 days from block timestamp");
        assertEq(false, withdrawExecuted, "Withdrawal must not be executed.");
    }

    function test_SellerShouldBeAbleToFulfillTransactionEScrowTxOnceLockPeriodHasPassed() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);
        TokenWIthGodMode transactionToken = new TokenWIthGodMode("TX Token", "TXT", 1000 * 10 ** 18);

        uint256 user1TokensAmount = 100 * 10 ** transactionToken.decimals();
        transactionToken.transfer(user1, user1TokensAmount);
        assertEq(user1TokensAmount, transactionToken.balanceOf(user1), "User1 needs to have transfered tokens.");

        // test execution
        uint256 transactionId = 18;

        uint256 priceToPayToSeller = 20 * 10 ** transactionToken.decimals();

        vm.startPrank(user1);

        bytes32 transactionIdEncoded = bytes32(transactionId);
        bytes32 sellerEncoded = bytes32(uint256(uint160(user2)));

        bytes memory customTransferData = new bytes(64);
        assembly {
            mstore(add(customTransferData, 32), transactionIdEncoded)
            mstore(add(customTransferData, 64), sellerEncoded)
        }

        uint256 currentTime = block.timestamp;
        transactionToken.transferAndCall(address(escrow), priceToPayToSeller, customTransferData);

        (address seller, address buyer, IERC1363 token, uint256 amount, uint256 lockedUntil, bool withdrawExecuted) =
            escrow.lockedTransactions(transactionId);

        assertEq(user1, buyer, "Seller shoud be user1");
        assertEq(user2, seller, "Seller shoud be user2");
        assertEq(address(transactionToken), address(token), "Transaction token needs to be one we setup at start.");
        assertEq(amount, priceToPayToSeller, "Locked token amount needs to be same as priceToPayToSeller");
        assertEq(currentTime + 3 days, lockedUntil, "Locked until needs to be 3 days from block timestamp");
        assertEq(false, withdrawExecuted, "Withdrawal must not be executed.");

        vm.warp(currentTime + 4 days);

        vm.startPrank(user2);
        escrow.withdraw(transactionId);
        assertEq(priceToPayToSeller, transactionToken.balanceOf(user2), "Seller shoud receive tokens");
    }

    function test_WithdrawShouldFailIfLockTimeHasNotExpired() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);
        TokenWIthGodMode transactionToken = new TokenWIthGodMode("TX Token", "TXT", 1000 * 10 ** 18);

        uint256 user1TokensAmount = 100 * 10 ** transactionToken.decimals();
        transactionToken.transfer(user1, user1TokensAmount);
        assertEq(user1TokensAmount, transactionToken.balanceOf(user1), "User1 needs to have transfered tokens.");

        // test execution
        uint256 transactionId = 18;

        uint256 priceToPayToSeller = 20 * 10 ** transactionToken.decimals();

        vm.startPrank(user1);

        bytes32 transactionIdEncoded = bytes32(transactionId);
        bytes32 sellerEncoded = bytes32(uint256(uint160(user2)));

        bytes memory customTransferData = new bytes(64);
        assembly {
            mstore(add(customTransferData, 32), transactionIdEncoded)
            mstore(add(customTransferData, 64), sellerEncoded)
        }

        uint256 currentTime = block.timestamp;
        transactionToken.transferAndCall(address(escrow), priceToPayToSeller, customTransferData);

        (address seller, address buyer, IERC1363 token, uint256 amount, uint256 lockedUntil, bool withdrawExecuted) =
            escrow.lockedTransactions(transactionId);

        assertEq(user1, buyer, "Seller shoud be user1");
        assertEq(user2, seller, "Seller shoud be user2");
        assertEq(address(transactionToken), address(token), "Transaction token needs to be one we setup at start.");
        assertEq(amount, priceToPayToSeller, "Locked token amount needs to be same as priceToPayToSeller");
        assertEq(currentTime + 3 days, lockedUntil, "Locked until needs to be 3 days from block timestamp");
        assertEq(false, withdrawExecuted, "Withdrawal must not be executed.");

        vm.warp(currentTime + 2 days);

        vm.startPrank(user2);
        vm.expectRevert(bytes("This escrow still locked"));
        escrow.withdraw(transactionId);
    }

    function test_WithdrawShouldFailIfCallerIsNotSeller() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);
        TokenWIthGodMode transactionToken = new TokenWIthGodMode("TX Token", "TXT", 1000 * 10 ** 18);

        uint256 user1TokensAmount = 100 * 10 ** transactionToken.decimals();
        transactionToken.transfer(user1, user1TokensAmount);
        assertEq(user1TokensAmount, transactionToken.balanceOf(user1), "User1 needs to have transfered tokens.");

        // test execution
        uint256 transactionId = 18;

        uint256 priceToPayToSeller = 20 * 10 ** transactionToken.decimals();

        vm.startPrank(user1);

        bytes32 transactionIdEncoded = bytes32(transactionId);
        bytes32 sellerEncoded = bytes32(uint256(uint160(user2)));

        bytes memory customTransferData = new bytes(64);
        assembly {
            mstore(add(customTransferData, 32), transactionIdEncoded)
            mstore(add(customTransferData, 64), sellerEncoded)
        }

        uint256 currentTime = block.timestamp;
        transactionToken.transferAndCall(address(escrow), priceToPayToSeller, customTransferData);

        (address seller, address buyer, IERC1363 token, uint256 amount, uint256 lockedUntil, bool withdrawExecuted) =
            escrow.lockedTransactions(transactionId);

        assertEq(user1, buyer, "Seller shoud be user1");
        assertEq(user2, seller, "Seller shoud be user2");
        assertEq(address(transactionToken), address(token), "Transaction token needs to be one we setup at start.");
        assertEq(amount, priceToPayToSeller, "Locked token amount needs to be same as priceToPayToSeller");
        assertEq(currentTime + 3 days, lockedUntil, "Locked until needs to be 3 days from block timestamp");
        assertEq(false, withdrawExecuted, "Withdrawal must not be executed.");

        vm.warp(currentTime + 4 days);

        vm.startPrank(user1);
        vm.expectRevert(bytes("Only seller can invoke withdraw"));
        escrow.withdraw(transactionId);
    }

    function test_WithdrawShouldFailIfWeTryToExecuteItAgain() public {
        // setup
        vm.startPrank(owner);
        vm.deal(owner, 10 ether);
        TokenWIthGodMode transactionToken = new TokenWIthGodMode("TX Token", "TXT", 1000 * 10 ** 18);

        uint256 user1TokensAmount = 100 * 10 ** transactionToken.decimals();
        transactionToken.transfer(user1, user1TokensAmount);
        assertEq(user1TokensAmount, transactionToken.balanceOf(user1), "User1 needs to have transfered tokens.");

        // test execution
        uint256 transactionId = 18;

        uint256 priceToPayToSeller = 20 * 10 ** transactionToken.decimals();

        vm.startPrank(user1);

        bytes32 transactionIdEncoded = bytes32(transactionId);
        bytes32 sellerEncoded = bytes32(uint256(uint160(user2)));

        bytes memory customTransferData = new bytes(64);
        assembly {
            mstore(add(customTransferData, 32), transactionIdEncoded)
            mstore(add(customTransferData, 64), sellerEncoded)
        }

        uint256 currentTime = block.timestamp;
        transactionToken.transferAndCall(address(escrow), priceToPayToSeller, customTransferData);

        (address seller, address buyer, IERC1363 token, uint256 amount, uint256 lockedUntil, bool withdrawExecuted) =
            escrow.lockedTransactions(transactionId);

        assertEq(user1, buyer, "Seller shoud be user1");
        assertEq(user2, seller, "Seller shoud be user2");
        assertEq(address(transactionToken), address(token), "Transaction token needs to be one we setup at start.");
        assertEq(amount, priceToPayToSeller, "Locked token amount needs to be same as priceToPayToSeller");
        assertEq(currentTime + 3 days, lockedUntil, "Locked until needs to be 3 days from block timestamp");
        assertEq(false, withdrawExecuted, "Withdrawal must not be executed.");

        vm.warp(currentTime + 4 days);

        vm.startPrank(user2);
        escrow.withdraw(transactionId);
        assertEq(priceToPayToSeller, transactionToken.balanceOf(user2), "Seller shoud receive tokens");

        vm.expectRevert(bytes("Withdrawn is already executed"));
        escrow.withdraw(transactionId);
    }
}
