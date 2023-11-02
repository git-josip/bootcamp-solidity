// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LinearBondingCurve.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract LinearBondingCurveEchidna {
    LinearBondingCurve linearBondingCurve;
    uint256 constant BASE_PRICE_IN_WEI = 0.003 ether;

    event BalanceToken1(uint256);
    event BalanceToken2(uint256);
    event SwapDex(string, uint256);

    constructor() {
        linearBondingCurve = new LinearBondingCurve("LinearBondingCurve", "LBC", BASE_PRICE_IN_WEI);
    }

    function test_buy_should_be_sucessful(uint256 _amount) public {
        uint256 amount = _amount == 0 ? 1 ether : _amount;

        uint256 startingBalance = linearBondingCurve.balanceOf(address(this));
        uint256 startingEtherBalance = address(this).balance;
        uint256 startingContractEtherBalance = address(linearBondingCurve).balance;

        uint256 purchaseCost = linearBondingCurve.calculatePurchaseCost(amount);
        linearBondingCurve.buy{value: purchaseCost}(amount);

        assert(linearBondingCurve.balanceOf(address(this)) == startingBalance + amount);
        assert(address(this).balance == startingEtherBalance - purchaseCost);
        assert(address(linearBondingCurve).balance == startingContractEtherBalance + purchaseCost);
    }

    function test_after_buy_price_increase(uint256 _amount) public {
        uint256 amount = _amount < 10 ** linearBondingCurve.decimals() ? 1 ether : _amount;

        uint256 startPurchaseCost = linearBondingCurve.calculatePurchaseCost(amount);

        test_buy_should_be_sucessful(amount);

        uint256 endPurchaseCost = linearBondingCurve.calculatePurchaseCost(amount);

        assert(endPurchaseCost > startPurchaseCost);
    }

    function test_sell_is_executed_if_tokens_are_sent_to_linearBondingCurve(uint256 amount) public {
        // first buy tokens
        test_buy_should_be_sucessful(amount);

        uint256 startingTokenBalance = linearBondingCurve.balanceOf(address(this));
        uint256 startingEtherBalance = address(this).balance;
        uint256 startingContractEtherBalance = address(linearBondingCurve).balance;
        uint256 purchaseCost = linearBondingCurve.calculatePurchaseCost(amount);

        linearBondingCurve.transferFromAndCall(
            address(this),
            address(linearBondingCurve),
            amount
        );
        
        assert(linearBondingCurve.balanceOf(address(this)) == startingTokenBalance - amount);
        assert(address(this).balance == startingEtherBalance + purchaseCost);
        assert(address(linearBondingCurve).balance == startingContractEtherBalance - purchaseCost);
    }

    function test_sell_is_executed_successfuly(uint256 amount) public {
        // first buy tokens
        test_buy_should_be_sucessful(amount);

        uint256 startingTokenBalance = linearBondingCurve.balanceOf(address(this));
        uint256 startingEtherBalance = address(this).balance;
        uint256 startingContractEtherBalance = address(linearBondingCurve).balance;
        uint256 purchaseCost = linearBondingCurve.calculatePurchaseCost(amount);

        linearBondingCurve.sell(amount);
        
        assert(linearBondingCurve.balanceOf(address(this)) == startingTokenBalance - amount);
        assert(address(this).balance == startingEtherBalance + purchaseCost);
        assert(address(linearBondingCurve).balance == startingContractEtherBalance - purchaseCost);
    }

    function test_after_sell_price_decrease(uint256 _amount) public {
        uint256 amount = _amount < 10 ** linearBondingCurve.decimals() ? 1 ether : _amount;

        test_buy_should_be_sucessful(amount);
        uint256 startPurchaseCost = linearBondingCurve.calculatePurchaseCost(amount);

        test_sell_is_executed_successfuly(amount);

        uint256 endPurchaseCost = linearBondingCurve.calculatePurchaseCost(amount);

        assert(endPurchaseCost < startPurchaseCost);
    }
}