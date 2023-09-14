// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Test, console2} from "forge-std/Test.sol";
import {LinearBondingCurve} from "../src/3_LinearBondingCurve.sol";

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
        vm.startPrank(tradeUser1);
        vm.deal(tradeUser1, 10 ether);

        assertEq(
            BASE_TOKEN_FEE,
            linearBondingCurve.getCurrentPrice(),
            "Current price needs to be equalt to BASE_TOKEN_FEE on start."
        );
        assertEq(0, linearBondingCurve.totalSupply(), "Total supply needs to be 0 on start");

        uint256 calculatedPriceForTokenBuy = linearBondingCurve.calculatePurchaseReturn(1);
        assertEq(0.0055 ether, calculatedPriceForTokenBuy, "Price for buying 1 token on start is nont correct.");
        linearBondingCurve.buy{value: linearBondingCurve.calculatePurchaseReturn(1)}(1);

        console.log("Current eth balance of contract: %s", address(linearBondingCurve).balance);
        console.log("Current totalSupply: %s", linearBondingCurve.totalSupply());

        assertEq(1, linearBondingCurve.balanceOf(tradeUser1), "User balance after purchase needs to be 1.");
        assertEq(1, linearBondingCurve.totalSupply(), "Total supply increased by number of tokens minted.");

        console.log("Current balance tradeUser1: %s", linearBondingCurve.balanceOf(tradeUser1));
        console.log("Current balance tradeUser2: %s", linearBondingCurve.balanceOf(tradeUser2));
        console.log("Current balance owner: %s", linearBondingCurve.balanceOf(owner));

        uint256 calculatedPriceForTokenSell = linearBondingCurve.calculateSaleReturn(1);
        assertEq(
            calculatedPriceForTokenBuy,
            calculatedPriceForTokenSell,
            "Price for token buy before purchase and price for same amount of token sell should be the same."
        );
        linearBondingCurve.sell(1);

        assertEq(0, linearBondingCurve.balanceOf(tradeUser1), "User balance after selling tokens needs to be 0.");
        assertEq(0, linearBondingCurve.totalSupply(), "Total supply increased by number of tokens minted.");
    }
}
