// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {UD60x18} from "@prb-math/UD60x18.sol";
import {IERC3156FlashLender} from "../src/interfaces/IERC3156FlashLender.sol";
import {IERC3156FlashBorrower} from "../src/interfaces/IERC3156FlashBorrower.sol";
import {ERC165} from "openzeppelin/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface TestTokenERC20 is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract TokenA is ERC20, TestTokenERC20 {
    constructor() ERC20("TOKEN_A", "TKA") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract TokenB is ERC20 {
    constructor() ERC20("TOKEN_B", "TKB") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract TestFlashBorrower is IERC3156FlashBorrower, ERC165 {
    IERC3156FlashLender lender;

    uint256 public borrowCounter;

    constructor(IERC3156FlashLender lender_) {
        lender = lender_;
    }

    /// @dev ERC-3156 Flash loan callback
    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data)
        external
        override
        returns (bytes32)
    {
        require(msg.sender == address(lender), "FlashBorrower: Untrusted lender");
        require(initiator == address(this), "FlashBorrower: Untrusted loan initiator");

        borrowCounter = borrowCounter + 1;

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    /// @dev Initiate a flash loan
    function flashBorrow(address token, uint256 amount) public {
        uint256 _allowance = IERC20(token).allowance(address(this), address(lender));
        uint256 _fee = lender.flashFee(token, amount);
        uint256 _repayment = amount + _fee;
        IERC20(token).approve(address(lender), _allowance + _repayment);
        lender.flashLoan(this, token, amount, bytes("0x"));
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IERC3156FlashBorrower).interfaceId;
    }
}

contract UniswapV2PairTest is Test {
    using SafeERC20 for TestTokenERC20;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Sync(UD60x18 reserve0, UD60x18 reserve1);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);

    UniswapV2Factory public uniswapV2Factory;
    TestTokenERC20 public token0;
    TestTokenERC20 public token1;
    UniswapV2Pair uniswapV2Pair;
    address uniswapV2PairAddress;

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

        TokenA tokenA = new TokenA();
        TokenB tokenB = new TokenB();

        address tokenAAddress = address(tokenA);
        address tokenBAddress = address(tokenB);
        uniswapV2PairAddress = uniswapV2Factory.createPair(tokenAAddress, tokenBAddress);
        uniswapV2Pair = UniswapV2Pair(uniswapV2PairAddress);
        (token0, token1) = tokenAAddress < tokenBAddress
            ? (TestTokenERC20(tokenAAddress), TestTokenERC20(tokenBAddress))
            : (TestTokenERC20(tokenBAddress), TestTokenERC20(tokenAAddress));

        token0.mint(user1, 10_000 ether);
        token0.mint(user2, 10_000 ether);

        token1.mint(user1, 10_000 ether);
        token1.mint(user2, 10_000 ether);
    }

    function test_UserShouldBeAbleToAddLiquidity() public {
        // setup
        vm.startPrank(user1);
        vm.deal(user1, 10 ether);

        uint256 token0Amount = 1 ether;
        uint256 token1Amount = 4 ether;
        TestTokenERC20(token0).safeTransfer(uniswapV2PairAddress, token0Amount);
        TestTokenERC20(token1).safeTransfer(uniswapV2PairAddress, token1Amount);

        // test execution
        uint256 expectedLiquidity = 2 ether;

        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Transfer(
            address(0), address(uniswapV2Pair.permanentTokenLockContract()), uniswapV2Pair.MINIMUM_LIQUIDITY()
        );
        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Transfer(address(0), user1, expectedLiquidity - uniswapV2Pair.MINIMUM_LIQUIDITY());
        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Sync(UD60x18.wrap(token0Amount), UD60x18.wrap(token1Amount));
        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Mint(user1, token0Amount, token1Amount);

        uniswapV2Pair.mint(user1);

        assertEq(expectedLiquidity, uniswapV2Pair.totalSupply());
    }

    function test_SwapTokenShouldSucceed() public {
        // setup
        vm.startPrank(user1);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        addLiquidity(5 ether, 10 ether);
        uint256 user2Token1BalanceStart = ERC20(address(token1)).balanceOf(user2);

        // test execution
        uint256 expectedOutputAmount = 2 ether;

        (UD60x18 _reserve0, UD60x18 _reserve1,) = uniswapV2Pair.getReserves(); // gas savings
        uint256 expectedAmountIn = calculateAmountIn(expectedOutputAmount, _reserve0, _reserve1);
        TestTokenERC20(token0).safeTransfer(uniswapV2PairAddress, expectedAmountIn);

        vm.startPrank(user2);
        uniswapV2Pair.swap(0, expectedOutputAmount, user2, bytes("0x"));

        assertEq(
            ERC20(address(token1)).balanceOf(user2),
            user2Token1BalanceStart + expectedOutputAmount,
            "User 2 has invalid token1 balance after swap."
        );
    }

    function test_UserShouldBeAbleToBurnLiquidity() public {
        // setup
        vm.startPrank(user1);
        vm.deal(user1, 10 ether);

        uint256 token0Amount = 3 ether;
        uint256 token1Amount = 3 ether;
        TestTokenERC20(token0).safeTransfer(uniswapV2PairAddress, token0Amount);
        TestTokenERC20(token1).safeTransfer(uniswapV2PairAddress, token1Amount);

        uint256 expectedLiquidity = 3 ether;

        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Transfer(
            address(0), address(uniswapV2Pair.permanentTokenLockContract()), uniswapV2Pair.MINIMUM_LIQUIDITY()
        );
        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Transfer(address(0), user1, expectedLiquidity - uniswapV2Pair.MINIMUM_LIQUIDITY());
        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Sync(UD60x18.wrap(token0Amount), UD60x18.wrap(token1Amount));
        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Mint(user1, token0Amount, token1Amount);

        uniswapV2Pair.mint(user1);
        assertEq(expectedLiquidity, uniswapV2Pair.totalSupply());

        // execute burn
        ERC20(uniswapV2PairAddress).transfer(
            uniswapV2PairAddress, expectedLiquidity - uniswapV2Pair.MINIMUM_LIQUIDITY()
        );

        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Transfer(uniswapV2PairAddress, address(0), expectedLiquidity - uniswapV2Pair.MINIMUM_LIQUIDITY());
        vm.expectEmit(true, true, false, true, address(token0));
        emit Transfer(uniswapV2PairAddress, user1, token0Amount - uniswapV2Pair.MINIMUM_LIQUIDITY());
        vm.expectEmit(true, true, false, true, address(token1));
        emit Transfer(uniswapV2PairAddress, user1, token1Amount - uniswapV2Pair.MINIMUM_LIQUIDITY());
        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Sync(UD60x18.wrap(1000), UD60x18.wrap(1000));
        vm.expectEmit(true, true, false, true, uniswapV2PairAddress);
        emit Burn(
            user1,
            token0Amount - uniswapV2Pair.MINIMUM_LIQUIDITY(),
            token1Amount - uniswapV2Pair.MINIMUM_LIQUIDITY(),
            user1
        );

        uniswapV2Pair.burn(user1);

        // check balances after burn
        assertEq(0, ERC20(uniswapV2PairAddress).balanceOf(user1));
        assertEq(uniswapV2Pair.MINIMUM_LIQUIDITY(), ERC20(uniswapV2PairAddress).totalSupply());
        assertEq(1000, ERC20(address(token0)).balanceOf(uniswapV2PairAddress));
        assertEq(1000, ERC20(address(token1)).balanceOf(uniswapV2PairAddress));
        assertEq(
            ERC20(address(token0)).balanceOf(user1),
            ERC20(address(token0)).totalSupply() - 1000 - ERC20(address(token0)).balanceOf(user2)
        );
        assertEq(
            ERC20(address(token1)).balanceOf(user1),
            ERC20(address(token1)).totalSupply() - 1000 - ERC20(address(token1)).balanceOf(user2)
        );
    }

    function test_CheckCUmulativeLastCalculation() public {
        // setup
        vm.startPrank(user1);
        vm.deal(user1, 10 ether);

        uint256 token0Amount = 3 ether;
        uint256 token1Amount = 3 ether;
        TestTokenERC20(token0).safeTransfer(uniswapV2PairAddress, token0Amount);
        TestTokenERC20(token1).safeTransfer(uniswapV2PairAddress, token1Amount);

        uint256 expectedLiquidity = 3 ether;
        uniswapV2Pair.mint(user1);
        assertEq(expectedLiquidity, uniswapV2Pair.totalSupply());

        (UD60x18 _reserve0, UD60x18 _reserve1, uint256 blockTimestamp0) = uniswapV2Pair.getReserves();
        vm.warp(blockTimestamp0 + 1);
        uniswapV2Pair.sync();
        (,, uint256 blockTimestamp1) = uniswapV2Pair.getReserves();
        assertEq(blockTimestamp1, blockTimestamp0 + 1);
        assertEq(uniswapV2Pair.price0CumulativeLast(), _reserve1.div(_reserve0).unwrap() * 1);
        assertEq(uniswapV2Pair.price1CumulativeLast(), _reserve0.div(_reserve1).unwrap() * 1);

        // check after swap
        uint256 expectedAmountIn = calculateAmountIn(1 ether, _reserve0, _reserve1);
        ERC20(address(token0)).transfer(uniswapV2PairAddress, expectedAmountIn);
        vm.warp(blockTimestamp0 + 10);
        uniswapV2Pair.swap(0, 1 ether, user1, bytes("0x"));

        (,, uint256 blockTimestamp2) = uniswapV2Pair.getReserves();
        assertEq(blockTimestamp2, blockTimestamp0 + 10);
        assertEq(uniswapV2Pair.price0CumulativeLast(), _reserve1.div(_reserve0).unwrap() * 10);
        assertEq(uniswapV2Pair.price1CumulativeLast(), _reserve0.div(_reserve1).unwrap() * 10);
    }

    function test_FeeOffShouldNotSendFee() public {
        // setup
        vm.startPrank(user1);
        vm.deal(user1, 10 ether);

        addLiquidity(1000 ether, 1000 ether);
        // test execution
        uint256 swapAmount = 1 ether;
        uint256 expectedOutputAmount = 996006981039903216;
        token1.transfer(uniswapV2PairAddress, swapAmount);
        uniswapV2Pair.swap(expectedOutputAmount, 0, user1, bytes("0x"));

        uint256 expectedLiquidity = 1000 ether;
        uniswapV2Pair.transfer(uniswapV2PairAddress, expectedLiquidity - uniswapV2Pair.MINIMUM_LIQUIDITY());
        uniswapV2Pair.burn(user1);

        assertEq(
            uniswapV2Pair.totalSupply(),
            uniswapV2Pair.MINIMUM_LIQUIDITY(),
            "Total supply should only be minimum liqudity."
        );
    }

    function test_FeeOnShouldSendFee() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        vm.startPrank(owner);
        uniswapV2Factory.setFeeTo(owner);

        vm.startPrank(user1);
        addLiquidity(1000 ether, 1000 ether);
        // test execution
        uint256 swapAmount = 1 ether;
        uint256 expectedOutputAmount = 996006981039903216;
        token1.transfer(uniswapV2PairAddress, swapAmount);
        uniswapV2Pair.swap(expectedOutputAmount, 0, user1, bytes("0x"));

        uint256 expectedLiquidity = 1000 ether;
        uniswapV2Pair.transfer(uniswapV2PairAddress, expectedLiquidity - uniswapV2Pair.MINIMUM_LIQUIDITY());
        uniswapV2Pair.burn(user1);

        assertEq(uniswapV2Pair.totalSupply(), uniswapV2Pair.MINIMUM_LIQUIDITY() + 249750499251388);
        assertEq(uniswapV2Pair.balanceOf(owner), 249750499251388);
    }

    function test_FlashBorrowerToBorrowMoney() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        addLiquidity(1000 ether, 1000 ether);
        TestFlashBorrower flashBorrower = new TestFlashBorrower(IERC3156FlashLender(uniswapV2PairAddress));

        // test execution
        assertEq(0, flashBorrower.borrowCounter(), "Counter must be 0 on start prior lending.");

        flashBorrower.flashBorrow(address(token0), 200 ether);

        assertEq(1, flashBorrower.borrowCounter(), "Counter must be 1 after lending.");
    }

    function test_FlashBorrowerToBorrowMoneyShouldFailIfAMountIsMoreThanMaximum() public {
        // setup
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);

        addLiquidity(1000 ether, 1000 ether);
        TestFlashBorrower flashBorrower = new TestFlashBorrower(IERC3156FlashLender(uniswapV2PairAddress));

        // test execution
        assertEq(0, flashBorrower.borrowCounter(), "Counter must be 0 on start prior lending.");

        vm.expectRevert(bytes("ERC20: transfer amount exceeds balance"));
        flashBorrower.flashBorrow(address(token0), 2000 ether);
    }

    // helper
    function addLiquidity(uint256 token0Amount, uint256 token1Amount) private {
        TestTokenERC20(token0).safeTransfer(address(uniswapV2Pair), token0Amount);
        TestTokenERC20(token1).safeTransfer(address(uniswapV2Pair), token1Amount);
        uniswapV2Pair.mint(user1);
    }
}
