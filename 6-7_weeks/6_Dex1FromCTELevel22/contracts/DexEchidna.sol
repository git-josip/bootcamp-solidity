// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Dex.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract DexEchidna {
    SwappableToken public token1;
    SwappableToken public token2;
    Dex dex;

    event BalanceToken1(uint256);
    event BalanceToken2(uint256);
    event SwapDex(string, uint256);

    constructor() {
        dex = new Dex();
        // as stated in ethernaut 10 tokens of each token get minted to the executor => (address(this)) is msg.sender
        token1 = new SwappableToken(address(dex), "Token1", "TONE", 110 ether);
        token2 = new SwappableToken(address(dex), "Token2", "TTWO", 110 ether);
        
        // set token addresses on dex
        dex.setTokens(address(token1), address(token2));
        
        // as stated in ethernaut dex starts with 100 tokens of each token
        token1.transfer(address(dex), 100 ether);
        token2.transfer(address(dex), 100 ether);
       
        dex.renounceOwnership();
        dex.approve(address(dex), type(uint256).max);
    }

    function testSwap(bool swapDirection, uint256 amount) public {
        uint256 balance1 = token1.balanceOf(address(this));
        emit BalanceToken1(balance1);
        uint256 balance2 = token2.balanceOf(address(this));
        emit BalanceToken2(balance2);

        if(swapDirection) {
            uint256 swapAmount = Math.max(amount % balance2, balance2 - (amount % balance2));
            emit SwapDex("2 to 1", swapAmount);
            dex.swap(address(token2), address(token1), swapAmount);
        }
        else {
            uint256 swapAmount = Math.max(amount % balance1, balance1 - (amount % balance1));
            emit SwapDex("1 to 2", swapAmount); 
            dex.swap(address(token1), address(token2), swapAmount);
        }
        
        assert(token1.balanceOf(address(dex)) >= 80 ether || token2.balanceOf(address(dex)) >= 80 ether);
    }
}