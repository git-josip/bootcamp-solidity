// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC165} from "openzeppelin/utils/introspection/ERC165.sol";
import {IERC3156FlashBorrower} from "./interfaces/IERC3156FlashBorrower.sol";
import {IERC3156FlashLender} from "./interfaces/IERC3156FlashLender.sol";
import {IUniswapV2Factory} from "./interfaces/IUniswapV2Factory.sol";
import {UD60x18, ud, MAX_WHOLE_UD60x18} from "@prb-math/UD60x18.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract PermanentTokenLock {}

contract UniswapV2Pair is ERC20, ERC165, IERC3156FlashLender, ReentrancyGuard {
    using SafeERC20 for ERC20;
    using Address for address;

    string public constant NAME = "Uniswap V2";
    string public constant SYMBOL = "UNI-V2";
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;

    mapping(address => bool) public supportedTokens;
    uint256 public fee; //  1 == 0.01 %.

    address public factory;
    address public token0;
    address public token1;
    PermanentTokenLock public immutable permanentTokenLockContract;

    UD60x18 private reserve0;
    UD60x18 private reserve1;
    uint32 private blockTimestampLast;

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    /**
     * @param _fee The percentage of the flash loan `amount` that needs to be repaid, in addition to `amount`.
     */
    constructor(uint256 _fee) ERC20(NAME, SYMBOL) {
        require(
            ERC165(address(msg.sender)).supportsInterface(type(IUniswapV2Factory).interfaceId),
            "Creator must implement IUniswapV2Factory interface."
        );

        factory = msg.sender;
        fee = _fee;
        permanentTokenLockContract = new PermanentTokenLock();
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1, uint256 _flashLoanFee) external {
        require(msg.sender == factory, "UniswapV2: FORBIDDEN"); // sufficient check
        require(_token0.isContract(), "UniswapV2: token0 address must be contract"); // sufficient check
        require(_token1.isContract(), "UniswapV2: token1 address must be contract"); // sufficient check

        token0 = _token0;
        supportedTokens[_token0] = true;
        token1 = _token1;
        supportedTokens[_token1] = true;
        fee = _flashLoanFee;
    }

    function getReserves() public view returns (UD60x18 _reserve0, UD60x18 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(UD60x18 reserve0, UD60x18 reserve1);

    // update reserves and, on the first call per block, price accumulators
    function _update(uint256 balance0, uint256 balance1, uint256 _reserve0, uint256 _reserve1) private {
        require(
            UD60x18.wrap(balance0) <= MAX_WHOLE_UD60x18 && UD60x18.wrap(balance1) <= MAX_WHOLE_UD60x18,
            "UniswapV2: OVERFLOW"
        );

        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            UD60x18 ud160X18Reserve0 = UD60x18.wrap(_reserve0);
            UD60x18 ud160X18Reserve1 = UD60x18.wrap(_reserve1);

            price0CumulativeLast += ud160X18Reserve1.div(ud160X18Reserve0).unwrap() * timeElapsed;
            price1CumulativeLast += ud160X18Reserve0.div(ud160X18Reserve1).unwrap() * timeElapsed;
        }
        reserve0 = UD60x18.wrap(balance0);
        reserve1 = UD60x18.wrap(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint256 _reserve0, uint256 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(_reserve0 * _reserve1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply() * uint256(rootK - rootKLast);
                    uint256 denominator = rootK * 5 + rootKLast;
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external nonReentrant returns (uint256 liquidity) {
        (UD60x18 _reserve0, UD60x18 _reserve1,) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0.unwrap();
        uint256 amount1 = balance1 - _reserve1.unwrap();

        bool feeOn = _mintFee(_reserve0.unwrap(), _reserve1.unwrap());
        uint256 _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(permanentTokenLockContract), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity =
                Math.min((amount0 * _totalSupply) / _reserve0.unwrap(), (amount1 * _totalSupply) / _reserve1.unwrap());
        }
        require(liquidity > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0.unwrap(), _reserve1.unwrap());
        if (feeOn) kLast = reserve0.unwrap() * reserve1.unwrap(); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        (UD60x18 _reserve0, UD60x18 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf(address(this));

        bool feeOn = _mintFee(_reserve0.unwrap(), _reserve1.unwrap());
        uint256 _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = (liquidity * balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = (liquidity * balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED");
        _burn(address(this), liquidity);

        ERC20(_token0).safeTransfer(to, amount0);
        ERC20(_token1).safeTransfer(to, amount1);

        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0.unwrap(), _reserve1.unwrap());
        if (feeOn) kLast = reserve0.unwrap() * reserve1.unwrap(); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata /*data*/ ) external nonReentrant {
        require(amount0Out > 0 || amount1Out > 0, "UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT");
        (UD60x18 _reserve0, UD60x18 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0.unwrap() && amount1Out < _reserve1.unwrap(), "UniswapV2: INSUFFICIENT_LIQUIDITY");
        require(!(amount0Out > 0 && amount1Out > 0), "out1 and out2 can not be > 0 at same time.");

        uint256 balance0;
        uint256 balance1;
        {
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "UniswapV2: INVALID_TO");
            if (amount0Out > 0) ERC20(_token0).safeTransfer(to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) ERC20(_token1).safeTransfer(to, amount1Out); // optimistically transfer tokens
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint256 amount0In =
            balance0 > _reserve0.unwrap() - amount0Out ? balance0 - (_reserve0.unwrap() - amount0Out) : 0;
        uint256 amount1In =
            balance1 > _reserve1.unwrap() - amount1Out ? balance1 - (_reserve1.unwrap() - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, "UniswapV2: INSUFFICIENT_INPUT_AMOUNT");
        {
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint256 balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
            uint256 balance1Adjusted = (balance1 * 1000) - (amount1In * 3);
            require(
                balance0Adjusted * balance1Adjusted >= _reserve0.unwrap() * _reserve1.unwrap() * 1000 ** 2,
                "UniswapV2: K"
            );
        }

        _update(balance0, balance1, _reserve0.unwrap(), _reserve1.unwrap());
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap2(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata /*data*/ )
        external
        nonReentrant
    {
        require(amount0Out > 0 || amount1Out > 0, "UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT");
        (UD60x18 _reserve0, UD60x18 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0.unwrap() && amount1Out < _reserve1.unwrap(), "UniswapV2: INSUFFICIENT_LIQUIDITY");
        require(!(amount0Out > 0 && amount1Out > 0), "out1 and out2 can not be > 0 at same time.");

        uint256 _amount0Out = amount0Out;
        uint256 _amount1Out = amount1Out;
        uint256 balance0;
        uint256 balance1;
        {
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "UniswapV2: INVALID_TO");
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint256 amount0In =
            balance0 > _reserve0.unwrap() - _amount0Out ? balance0 - (_reserve0.unwrap() - _amount0Out) : 0;
        uint256 amount1In =
            balance1 > _reserve1.unwrap() - _amount1Out ? balance1 - (_reserve1.unwrap() - _amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, "UniswapV2: INSUFFICIENT_INPUT_AMOUNT");

        uint256 requiredAmountIn;
        uint256 tokenAmountToTransfer;
        address tokenToTransfer;
        if (_amount0Out > 0) {
            requiredAmountIn = calculateAmountIn(_amount0Out, _reserve1, _reserve0);
            require(amount1In == requiredAmountIn, "UniswapV2: INSUFFICIENT_INPUT_AMOUNT transffered.");
            tokenToTransfer = token0;
            tokenAmountToTransfer = _amount0Out;
        }
        if (_amount1Out > 0) {
            requiredAmountIn = calculateAmountIn(_amount1Out, _reserve0, _reserve1);
            require(amount0In == requiredAmountIn, "UniswapV2: INSUFFICIENT_INPUT_AMOUNT transffered.");
            tokenToTransfer = token1;
            tokenAmountToTransfer = _amount1Out;
        }

        {
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint256 balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
            uint256 balance1Adjusted = (balance1 * 1000) - (amount1In * 3);
            require(
                balance0Adjusted * balance1Adjusted >= _reserve0.unwrap() * _reserve1.unwrap() * 1000 ** 2,
                "UniswapV2: K"
            );
        }

        _update(balance0, balance1, _reserve0.unwrap(), _reserve1.unwrap());
        ERC20(tokenToTransfer).safeTransfer(to, tokenAmountToTransfer);
        emit Swap(msg.sender, amount0In, amount1In, _amount0Out, _amount1Out, to);
    }

    // force balances to match reserves
    function skim(address to) external nonReentrant {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings

        ERC20(_token0).safeTransfer(to, IERC20(_token0).balanceOf(address(this)) - reserve0.unwrap());
        ERC20(_token1).safeTransfer(to, IERC20(_token1).balanceOf(address(this)) - reserve1.unwrap());
    }

    // force reserves to match balances
    function sync() external nonReentrant {
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            reserve0.unwrap(),
            reserve1.unwrap()
        );
    }

    /**
     * @dev Loan `amount` tokens to `receiver`, and takes it back plus a `flashFee` after the callback.
     * @param receiver The contract receiving the tokens, needs to implement the `onFlashLoan(address user, uint256 amount, uint256 fee, bytes calldata)` interface.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param data A data parameter to be passed on to the `receiver` for any custom use.
     */
    function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data)
        external
        override
        nonReentrant
        returns (bool)
    {
        require(
            ERC165(address(receiver)).supportsInterface(type(IERC3156FlashBorrower).interfaceId),
            "Receiver must implement IERC3156FlashBorrower interafce."
        );
        require(supportedTokens[token], "FlashLender: Unsupported currency");

        uint256 calculatedLoanFee = _flashFee(token, amount);

        ERC20(token).safeTransfer(address(receiver), amount);

        require(
            receiver.onFlashLoan(msg.sender, token, amount, calculatedLoanFee, data) == CALLBACK_SUCCESS,
            "FlashLender: Callback failed"
        );

        ERC20(token).safeTransferFrom(address(receiver), address(this), amount + calculatedLoanFee);

        return true;
    }

    /**
     * @dev The fee to be charged for a given loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function flashFee(address token, uint256 amount) external view override returns (uint256) {
        require(supportedTokens[token], "FlashLender: Unsupported currency");
        return _flashFee(token, amount);
    }

    /**
     * @dev The fee to be charged for a given loan. Internal function with no checks.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function _flashFee(address, /*token*/ uint256 /*amount*/ ) internal pure returns (uint256) {
        return 0;
    }

    /**
     * @dev The amount of currency available to be lent.
     * @param token The loan currency.
     * @return The amount of `token` that can be borrowed.
     */
    function maxFlashLoan(address token) external view override returns (uint256) {
        return supportedTokens[token] ? IERC20(token).balanceOf(address(this)) : 0;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IERC3156FlashLender).interfaceId || super.supportsInterface(interfaceId);
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
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
}
