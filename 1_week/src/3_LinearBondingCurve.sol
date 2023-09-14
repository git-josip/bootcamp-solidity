// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {TokenWIthGodMode} from "./2_TokenWIthGodMode.sol";
import {IERC1363Receiver, IERC1363} from "@payabletoken/contracts/token/ERC1363/ERC1363.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Simple LinearBondingCurve implemntation
 * @author Josip Medic
 * @notice This contract implements a basic linear bonding curve with a constant price increment.
 *  Users can buy and sell tokens, and the price increases or decreases linearly with each transaction.
 */
contract LinearBondingCurve is TokenWIthGodMode, IERC1363Receiver {
    uint256 public baseTokenPrice; // Initial token price in wei
    uint256 public constant PRICE_INCREMENT_PER_TOKEN = 1_000_000 wei; // Price increment per token in wei

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event TokensSold(address indexed seller, uint256 amount, uint256 revenue);
    event TokensReceived(address indexed operator, address indexed sender, uint256 amount, bytes data);

    IERC1363 private _acceptedToken;

    constructor(string memory name, string memory symbol, uint256 _baseTokenPrice) TokenWIthGodMode(name, symbol) {
        baseTokenPrice = _baseTokenPrice;
        _acceptedToken = IERC1363(address(this));
    }

    function buy(uint256 _ethAmount) external payable {
        require(_ethAmount > 0, "Amount must be greater than zero");

        uint256 cost = calculatePurchaseReturn(_ethAmount);
        require(msg.value >= cost, "Insufficient funds");

        _mint(msg.sender, _ethAmount);

        emit TokensPurchased(msg.sender, _ethAmount, cost);

        // Refund any excess funds
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
    }

    function sell(uint256 _tokenAmount) public {
        require(_tokenAmount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= _tokenAmount, "Insufficient token balance");

        uint256 revenue = calculateSaleReturn(_tokenAmount);

        _burn(address(this), _tokenAmount);

        emit TokensSold(msg.sender, _tokenAmount, revenue);

        payable(msg.sender).transfer(revenue);
    }

    function calculatePurchaseReturn(uint256 _ethAmount) public view returns (uint256 cost) {
        require(_ethAmount > 0, "Amount must be greater than zero");

        uint256 currentTotalSupply = totalSupply();
        uint256 priceBeforeBuy = getPriceForSupply(currentTotalSupply);
        uint256 priceAfterBuy = getPriceForSupply(currentTotalSupply + _ethAmount);

        cost = _ethAmount * (priceBeforeBuy + priceAfterBuy) / 2;
    }

    function calculateSaleReturn(uint256 _tokenAmount) public view returns (uint256 revenue) {
        require(_tokenAmount > 0, "Amount must be greater than zero");

        uint256 currentTotalSupply = totalSupply();
        uint256 priceBeforeSell = getPriceForSupply(currentTotalSupply);
        uint256 priceAfterSell = getPriceForSupply(currentTotalSupply - _tokenAmount);

        revenue = _tokenAmount * (priceBeforeSell + priceAfterSell) / 2;
    }

    function getPriceForSupply(uint256 _supply) public view returns (uint256 priceBasedOnSupply) {
        priceBasedOnSupply = baseTokenPrice + (_supply * PRICE_INCREMENT_PER_TOKEN);
    }

    function onTransferReceived(address spender, address sender, uint256 amount, bytes memory data)
        public
        override
        returns (bytes4)
    {
        require(_msgSender() == address(_acceptedToken), "acceptedToken is not message sender");

        emit TokensReceived(spender, sender, amount, data);

        this.sell(amount);

        return IERC1363Receiver.onTransferReceived.selector;
    }

    // Fallback function to accept ether
    receive() external payable {}
}
