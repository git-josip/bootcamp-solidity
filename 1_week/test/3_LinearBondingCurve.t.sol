// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Test, console2} from "forge-std/Test.sol";
import {LinearBondingCurve} from "../src/3_LinearBondingCurve.sol";
import {TokenWIthGodMode} from "../src/2_TokenWIthGodMode.sol";

contract DummyToken is TokenWIthGodMode {
    constructor() TokenWIthGodMode("Dummy Token", "DTT") {
        _mint(msg.sender, 1000);
    }
}

contract LinearBondingCurveTest is Test {
    uint256 public constant BASE_TOKEN_FEE = 0.005 ether;

    LinearBondingCurve public linearBondingCurve;

    address internal owner;
    address internal tradeUser1;
    address internal tradeUser2;

    function setUp() public {
        tradeUser1 = vm.addr(1);
        vm.label(tradeUser1, "tradeUser1");

        tradeUser2 = vm.addr(2);
        vm.label(tradeUser2, "tradeUser2");

        owner = vm.addr(8);
        vm.label(owner, "owner");

        vm.prank(owner);
        linearBondingCurve = new LinearBondingCurve("RareSkills LinearBondingCurve Token", "RLT", BASE_TOKEN_FEE);
    }

    function test_buyTokenShouldCompleteSuccessfulyIfValidAmountIsSentForNumberOfTokens() public {
        // setup
        vm.startPrank(tradeUser1);
        vm.deal(tradeUser1, 10 ether);

        // test execution
        assertEq(
            BASE_TOKEN_FEE,
            linearBondingCurve.getCurrentPrice(),
            "Current price needs to be equalt to BASE_TOKEN_FEE on start."
        );
        assertEq(0, linearBondingCurve.totalSupply(), "Total supply needs to be 0 on start");

        uint256 calculatedPriceForTokenBuy = linearBondingCurve.calculatePurchaseCost(1);
        assertEq(0.0055 ether, calculatedPriceForTokenBuy, "Price for buying 1 token on start is nont correct.");

        linearBondingCurve.buy{value: linearBondingCurve.calculatePurchaseCost(1)}(1);

        assertEq(
            calculatedPriceForTokenBuy,
            address(linearBondingCurve).balance,
            "linearBondingCurve contract balance needs to be increased for amount sent for purchase."
        );
        assertEq(
            10 ether - calculatedPriceForTokenBuy,
            address(tradeUser1).balance,
            "User ETH balance after purchase needs to be decreased by amount paid for purchase."
        );
        assertEq(1, linearBondingCurve.balanceOf(tradeUser1), "User balance after purchase needs to be 1.");
        assertEq(1, linearBondingCurve.totalSupply(), "Total supply increased by number of tokens minted.");
    }

    function test_sellTokensShouldCompleteSuccessfulyIfValidAmountOfTokensIsSent() public {
        // setup
        vm.startPrank(tradeUser1);
        vm.deal(tradeUser1, 10 ether);

        uint256 calculatedPriceForTokenBuy = linearBondingCurve.calculatePurchaseCost(1);
        linearBondingCurve.buy{value: calculatedPriceForTokenBuy}(1);

        // test execution
        uint256 calculatedRevenueForTokenSell = linearBondingCurve.calculateSaleReturn(1);
        assertEq(
            calculatedPriceForTokenBuy,
            calculatedRevenueForTokenSell,
            "Price for token buy before purchase and price for same amount of token sell should be the same."
        );
        linearBondingCurve.sell(1);

        assertEq(0, linearBondingCurve.balanceOf(tradeUser1), "User balance after selling tokens needs to be 0.");
        assertEq(0, linearBondingCurve.totalSupply(), "Total supply increased by number of tokens minted.");
    }

    function test_BuyTOkensMultipleTimesShouldAddToPreviousUserBalance() public {
        // setup
        vm.startPrank(tradeUser1);
        vm.deal(tradeUser1, 100 ether);

        uint256 numberOfTokensToBuy1 = 134;
        uint256 calculatedPriceForTokenBuy1 = linearBondingCurve.calculatePurchaseCost(numberOfTokensToBuy1);
        linearBondingCurve.buy{value: calculatedPriceForTokenBuy1}(numberOfTokensToBuy1);

        uint256 numberOfTokensToBuy2 = 116;
        uint256 calculatedPriceForTokenBuy2 = linearBondingCurve.calculatePurchaseCost(numberOfTokensToBuy2);
        linearBondingCurve.buy{value: calculatedPriceForTokenBuy2}(numberOfTokensToBuy2);

        // test execution
        assertEq(
            numberOfTokensToBuy1 + numberOfTokensToBuy2,
            linearBondingCurve.balanceOf(tradeUser1),
            "User balance after selling tokens needs to be summ of all previous purchases."
        );
        assertEq(
            100 ether - (calculatedPriceForTokenBuy1 + calculatedPriceForTokenBuy2),
            address(tradeUser1).balance,
            "User ETH balance after purchase needs to be decreased by amount paid for all purchase."
        );
        assertEq(
            numberOfTokensToBuy1 + numberOfTokensToBuy2,
            linearBondingCurve.totalSupply(),
            "Total supply increased by number of tokens minted."
        );
    }

    function test_IfUserSendsTokensDirectlyToCOntractUsingTransferAndCallTokenSellShouldBeExecuted() public {
        // setup
        vm.startPrank(tradeUser1);
        vm.deal(tradeUser1, 100 ether);

        uint256 numberOfTokensToBuy1 = 134;
        uint256 calculatedPriceForTokenBuy1 = linearBondingCurve.calculatePurchaseCost(numberOfTokensToBuy1);
        linearBondingCurve.buy{value: calculatedPriceForTokenBuy1}(numberOfTokensToBuy1);

        uint256 numberOfTokensToBuy2 = 116;
        uint256 calculatedPriceForTokenBuy2 = linearBondingCurve.calculatePurchaseCost(numberOfTokensToBuy2);
        linearBondingCurve.buy{value: calculatedPriceForTokenBuy2}(numberOfTokensToBuy2);
        assertEq(
            numberOfTokensToBuy1 + numberOfTokensToBuy2,
            linearBondingCurve.totalSupply(),
            "Total supply increased by number of tokens minted."
        );

        // test execution
        console.log("Curve token balance after buy %s", address(linearBondingCurve).balance);
        linearBondingCurve.transferAndCall(address(linearBondingCurve), numberOfTokensToBuy1);

        assertEq(
            numberOfTokensToBuy2,
            linearBondingCurve.balanceOf(tradeUser1),
            "User balance after selling tokens is not correct."
        );
        assertEq(
            numberOfTokensToBuy2, linearBondingCurve.totalSupply(), "Total supply increased by number of tokens minted."
        );
    }

    function test_IfBuyIsExecutedWithWrongMsgValueTransactionShouldFail() public {
        // setup
        vm.startPrank(tradeUser1);
        vm.deal(tradeUser1, 100 ether);

        uint256 numberOfTokensToBuy1 = 134;
        uint256 calculatedPriceForTokenBuy1 = linearBondingCurve.calculatePurchaseCost(numberOfTokensToBuy1);

        vm.expectRevert(bytes("Cost is higher than ETH sent"));
        linearBondingCurve.buy{value: calculatedPriceForTokenBuy1 + 1 gwei}(numberOfTokensToBuy1);
    }

    function test_IfSellIsExecutedWhenThereIsNoEnoughBalanceTransactionShouldFail() public {
        // setup
        vm.startPrank(tradeUser1);
        vm.deal(tradeUser1, 100 ether);

        vm.expectRevert(bytes("Insufficient token balance"));
        linearBondingCurve.sell(100);
    }

    function test_IfWrongTokenIsSentToCurveContractItShouldBeRejected() public {
        // setup
        vm.startPrank(tradeUser1);
        vm.deal(tradeUser1, 100 ether);

        DummyToken otherToken = new DummyToken();

        vm.expectRevert(bytes("acceptedToken is not message sender"));
        otherToken.transferAndCall(address(linearBondingCurve), 10);
    }
}
