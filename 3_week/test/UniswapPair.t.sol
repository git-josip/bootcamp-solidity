// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {UD60x18} from "@prb-math/UD60x18.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Token1 is ERC20 {
    using SafeERC20 for ERC20;

    constructor() ERC20("TOKEN2", "TK1") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract Token2 is ERC20 {
    using SafeERC20 for ERC20;

    constructor() ERC20("TOKEN1", "TK2") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract UniswapTest is Test {
    using SafeERC20 for ERC20;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Sync(UD60x18 reserve0, UD60x18 reserve1);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    UniswapV2Factory public uniswapV2Factory;
    Token1 public token1;
    Token2 public token2;

    address internal owner;
    address internal user1;
    address internal user2;

    function calculateAmountIn(uint256 amountOut, UD60x18 reserveIn, UD60x18 reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn.unwrap() > 0 && reserveOut.unwrap() > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        // UD60x18
        UD60x18 amountOutAsUD60x18 = UD60x18.wrap(amountOut);
        UD60x18 numerator = reserveIn.mul(amountOutAsUD60x18).mul(UD60x18.wrap(1000));
        UD60x18 denominator = reserveOut.sub(amountOutAsUD60x18).mul(UD60x18.wrap(997));
        amountIn = ((numerator.div(denominator)).add(UD60x18.wrap(1))).unwrap();
    }

    function setUp() public {
        user1 = vm.addr(1);
        vm.label(user1, "user1");

        user2 = vm.addr(2);
        vm.label(user2, "user2");

        owner = vm.addr(99);
        vm.label(owner, "owner");

        vm.prank(owner);
        uniswapV2Factory = new UniswapV2Factory(owner);
        token1 = new Token1();
        token2 = new Token2();

        token1.mint(user1, 10_000 ether);
        token1.mint(user2, 10_000 ether);

        token2.mint(user1, 10_000 ether);
        token2.mint(user2, 10_000 ether);
    }

    function test_FactoryShouldBeAbleToInitializePair() public {
        // setup
        vm.startPrank(user1);
        vm.deal(user1, 10 ether);

        uniswapV2Factory.createPair(address(token1), address(token2));
    }

    function test_UserShouldBeAbleToAddLiquidity() public {
        // setup
        vm.startPrank(user1);
        vm.deal(user1, 10 ether);

        address uniswapV2PairAddress = uniswapV2Factory.createPair(address(token1), address(token2));
        UniswapV2Pair uniswapV2Pair = UniswapV2Pair(uniswapV2PairAddress);

        uint256 token1Amount = 1 ether;
        uint256 token2Amount = 4 ether;
        ERC20(token1).safeTransfer(uniswapV2PairAddress, token1Amount);
        ERC20(token2).safeTransfer(uniswapV2PairAddress, token2Amount);

        // test execution
        uint256 expectedLiquidity = 2 ether;

        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Transfer(
            address(0), address(uniswapV2Pair.permanentTokenLockContract()), uniswapV2Pair.MINIMUM_LIQUIDITY()
        );
        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Transfer(address(0), user1, expectedLiquidity - uniswapV2Pair.MINIMUM_LIQUIDITY());
        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Sync(UD60x18.wrap(token2Amount), UD60x18.wrap(token1Amount));
        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Mint(user1, token2Amount, token1Amount);

        uniswapV2Pair.mint(user1);

        assertEq(expectedLiquidity, uniswapV2Pair.totalSupply());
    }
}
