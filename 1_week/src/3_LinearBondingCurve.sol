// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {ERC1363} from "@payabletoken/contracts/token/ERC1363/ERC1363.sol";
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
contract LinearBondingCurve is ERC1363, Ownable, IERC1363Receiver {
    uint256 public baseTokenPriceInWei;
    uint256 public constant PRICE_INCREMENT_PER_TOKEN = 0.001 ether; // Price increment per token in wei

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event TokensSold(address indexed seller, uint256 amount, uint256 revenue);
    event TokensReceived(address indexed operator, address indexed sender, uint256 amount, bytes data);

    IERC1363 private acceptedToken;

    constructor(string memory name, string memory symbol, uint256 _baseTokenPriceInWei) ERC20(name, symbol) {
        require(_baseTokenPriceInWei > 0, "_baseTokenPrice must be greater than zero");

        baseTokenPriceInWei = _baseTokenPriceInWei;
        acceptedToken = IERC1363(address(this));
    }

    /**
     * @notice Executes token purchase based on sent ETH
     * @dev ETH value sent needs to be equal to amount which function calculatePurchaseCost returns
     * @param _tokenAmount amount of tokens to purchase
     */
    function buy(uint256 _tokenAmount) external payable {
        require(_tokenAmount > 0, "Amount must be greater than zero");

        uint256 cost = calculatePurchaseCost(_tokenAmount);
        require(msg.value == cost, "Cost is higher than ETH sent");

        _mint(_msgSender(), _tokenAmount);

        emit TokensPurchased(msg.sender, cost, cost);
    }

    /**
     * @notice Executes token sell based on amount of tokens sent to be sold
     * @dev Amount if tokens needs to be less than or equal to user token balance
     * @param _tokenAmount amount of tokens to sell
     */
    function sell(uint256 _tokenAmount) external {
        require(_tokenAmount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= _tokenAmount, "Insufficient token balance");

        uint256 revenue = calculateSaleReturn(_tokenAmount);

        _burn(_msgSender(), _tokenAmount);

        emit TokensSold(_msgSender(), _tokenAmount, revenue);

        payable(_msgSender()).transfer(revenue);
    }

    /**
     * @notice Executes caluclation how much of ETH is needed to purchase provided amount of tokens
     * @param _tokenAmount amount of tokens to purchase
     */
    function calculatePurchaseCost(uint256 _tokenAmount) public view returns (uint256 cost) {
        require(_tokenAmount > 0, "Amount must be greater than zero");

        uint256 currentTotalSupply = totalSupply();
        uint256 priceBeforeBuy = getPriceForSupply(currentTotalSupply);
        uint256 priceAfterBuy = getPriceForSupply(currentTotalSupply + _tokenAmount);

        cost = (_tokenAmount * (priceBeforeBuy + priceAfterBuy) / 2) / 10 ** decimals();
    }

    /**
     * @notice Executes caluclation how much of ETH we will receive if we sell provided amount of tokens
     * @param _tokenAmount amount of tokens to sell
     */
    function calculateSaleReturn(uint256 _tokenAmount) public view returns (uint256 revenue) {
        require(_tokenAmount > 0, "Amount must be greater than zero");

        uint256 currentTotalSupply = totalSupply();
        uint256 priceBeforeSell = getPriceForSupply(currentTotalSupply);
        uint256 priceAfterSell = getPriceForSupply(currentTotalSupply - _tokenAmount);

        revenue = (_tokenAmount * (priceBeforeSell + priceAfterSell) / 2) / 10 ** decimals();
    }

    /**
     * @notice Returns current price based on total number of minted tokens
     */
    function getCurrentPrice() public view returns (uint256 currentPrice) {
        currentPrice = getPriceForSupply(totalSupply());
    }

    /**
     * @notice Returns current price based on provided number of token supply.
     * @dev calculated price for given token suplpy is divided by 10 ** decimals(), to get price pre minimal unit of our token
     * @param _supply Provided custom tokens supply
     */
    function getPriceForSupply(uint256 _supply) public view returns (uint256 priceBasedOnSupply) {
        priceBasedOnSupply = baseTokenPriceInWei + (_supply * PRICE_INCREMENT_PER_TOKEN) / 10 ** decimals();
    }

    /**
     * @notice Handle the receipt of ERC1363 tokens.
     * @dev See {IERC1363Receiver-onTransferReceived}.
     */
    function onTransferReceived(address spender, address sender, uint256 amount, bytes memory data)
        public
        override
        returns (bytes4)
    {
        require(_msgSender() == address(acceptedToken), "Not supported token is sent");

        emit TokensReceived(spender, sender, amount, data);

        uint256 revenue = calculateSaleReturn(amount);
        _burn(address(this), amount);
        payable(sender).transfer(revenue);

        return IERC1363Receiver.onTransferReceived.selector;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1363Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}
