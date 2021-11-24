// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "hardhat/console.sol";


contract ArBot {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  
  struct Reserves {
    uint256 daiA;
    uint256 wethA;
    uint256 daiB;
    uint256 wethB;
    address lowerPool;
    address otherPool;
  }

  struct CallbackData {
    address debtPool;
    address targetPool;
    uint256 loan;
    uint256 daiOut;
  }

  receive() external payable {}

  // Redirect uniswap callback function to uniswapV2Call
  fallback(bytes calldata _input) external returns (bytes memory) {
    (address sender, uint256 amount0, uint256 amount1, bytes memory data) = abi.decode(_input[4:], (address, uint256, uint256, bytes));
    uniswapV2Call(sender, amount0, amount1, data);
  }

  // Flash Swap + Arbitrage
  function arbitrate(address _pool0, address _pool1) external {
    Reserves memory reserves = getReserves(_pool0, _pool1);

    uint256 loanAmount = _calcLoan(reserves);

    uint256 daiToReturn = getAmountIn(loanAmount, reserves.daiA, reserves.wethA);
    uint256 daiOut = getAmountOut(loanAmount, reserves.wethB, reserves.daiB);
    require(daiOut > daiToReturn, 'No profit');
    
    CallbackData memory cd;
    cd.debtPool = reserves.lowerPool;
    cd.targetPool = reserves.otherPool;
    cd.loan = loanAmount;
    cd.daiOut = daiOut;

    bytes memory data = abi.encode(cd);
    IUniswapV2Pair(reserves.lowerPool).swap(0, loanAmount, address(this), data);
  } 

  // Callback
  function uniswapV2Call(
    address sender,
    uint256 amount0,
    uint256 amount1,
    bytes memory data
  ) public {
    // TODO: Access control 
    require(sender == address(this), 'Not from this contract');

    uint256 loan = amount0 > 0 ? amount0 : amount1;
    CallbackData memory cd = abi.decode(data, (CallbackData));

    IERC20(WETH).safeTransfer(cd.targetPool, loan);

    IUniswapV2Pair(cd.targetPool).swap(cd.daiOut, 0, address(this), new bytes(0));

    IERC20(DAI).safeTransfer(cd.debtPool, cd.loan);
  }
    
  // Returns true if address of tokenA is smaller than address of tokenB
  function addressCompare(address tokenA, address tokenB) public pure returns (bool) {
    return tokenA < tokenB;
  }

  // Gets UniV2 reserves for DAI-WETH pools
  function getReserves(address _pool0, address _pool1) public view returns (Reserves memory reserves) {
    (uint256 dai1, uint256 weth1,) = IUniswapV2Pair(_pool0).getReserves();
    (uint256 dai2, uint256 weth2,) = IUniswapV2Pair(_pool1).getReserves();

    // Denomincated in WETH
    (uint256 priceDai1, uint256 priceDai2) = (dai1/weth1, dai2/weth2);

    console.log("Price DAI per weth");
    console.log("Pool0", priceDai1);
    console.log("Pool1", priceDai2);

    address lower = priceDai1 < priceDai2 ? _pool0 : _pool1;
    address other = lower == _pool1 ? _pool0 : _pool1;
    reserves = lower == _pool0 
      ? Reserves(dai1, weth1, dai2, weth2, lower, other)
      : Reserves(dai2, weth2, dai1, weth1, lower, other);
  }

  // Calculate profit that results from a trade between two pools
  function calculateProfit(address _pool0, address _pool1) public view returns (uint256 profit) {
    Reserves memory reserves = getReserves(_pool0, _pool1);

    uint256 loan = _calcLoan(reserves);

    console.log("loan amt:", loan.div(1e18));
    // (Decimal.D256 memory price0, Decimal.D256 memory price1) = (Decimal.from(dai1).div(weth1), Decimal.from(dai2).div(weth2));
    uint256 daiToReturn = getAmountIn(loan, reserves.daiA, reserves.wethA);
    uint256 daiOut = getAmountOut(loan, reserves.wethB, reserves.daiB);

    console.log("Profit? ", daiOut > daiToReturn);

    profit = daiOut > daiToReturn ? daiOut - daiToReturn : 0;
  }



  // Calculate the borrow amount that maximizes the profit
  function _calcLoan(Reserves memory reserves) internal view returns (uint256 toLoan) {
    uint256 min = _min(reserves);

    uint256 d;
    if (min > 1e24) {
      d = 1e20;
    } else if (min > 1e23) {
      d = 1e19;
    } else if (min > 1e22) {
      d = 1e18;
    } else if (min > 1e21) {
      d = 1e17;
    } else if (min > 1e20) {
      d = 1e16;
    } else if (min > 1e19) {
      d = 1e15;
    } else if (min > 1e18) {
      d = 1e14;
    } else if (min > 1e17) {
      d = 1e13;
    } else if (min > 1e16) {
      d = 1e12;
    } else if (min > 1e15) {
      d = 1e11;
    } else {
      d = 1e10;
    }

    console.log('daiA: ', reserves.daiA.div(1e18));
    console.log('wethA: ', reserves.wethA.div(1e18));
    console.log('daiB: ', reserves.daiB.div(1e18));
    console.log('wethB: ', reserves.wethB.div(1e18));

    (int256 a1, int256 b1, int256 a2, int256 b2) =
      (
        int256(reserves.daiA.div(d)), 
        int256(reserves.wethA.div(d)), 
        int256(reserves.daiB.div(d)), 
        int256(reserves.wethB.div(d))
      );

    (int256 x1, int256 x2) = _solveQuadratic(a1, a2, b1, b2);

    require((x1 > 0 && x1 < b1 && x1 < b2) || (x2 > 0 && x2 < b1 && x2 < b2), 'Wrong input order');
    return (x1 > 0 && x1 < b1 && x1 < b2) ? uint256(x1).mul(d) : uint256(x2).mul(d);
  }

  // Returns the roots of the equation if they exist, else throws
  function _solveQuadratic(int256 a1, int256 a2, int256 b1, int256 b2) internal pure returns (int256 , int256 ) {
    int256 a = a1 * b1 - a2 * b2;
    int256 b = 2 * b1 * b2 * (a1 + a2);
    int256 c = b1 * b2 * (a1 * b2 - a2 * b1);

    int256 dis = b**2 - 4*a*c;
    require(dis > 0, 'ArBot: no real solution');

    int256 sqrtDis = int256(_sqrt(uint256(dis)));

    return ((-b + sqrtDis) / (2 * a), (-b - sqrtDis) / (2 * a));
  }

  // Returns the min of the reserves
  function _min(Reserves memory reserves) internal pure returns (uint256 min) {
    uint256 m1 = reserves.daiA < reserves.daiB ? reserves.daiA : reserves.daiB;
    min = reserves.wethA < reserves.wethB ? reserves.wethA : reserves.wethB;
    min = min < m1 ? min : m1;
  }

  // Function from UniV2 Math library at: https://github.com/Uniswap/v2-core/blob/master/contracts/libraries/Math.sol
  function _sqrt(uint y) internal pure returns (uint z) {
    if (y > 3) {
      z = y;
      uint x = y / 2 + 1;
      while (x < z) {
        z = x;
        x = (y / x + x) / 2;
      }
    } else if (y != 0) {
      z = 1;
    }
  }

  // Function from UniV2 library at https://github.com/Uniswap/v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol
  function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
    require(amountIn > 0, 'ArBot: INSUFFICIENT_INPUT_AMOUNT');
    require(reserveIn > 0 && reserveOut > 0, 'ArBot: INSUFFICIENT_LIQUIDITY');
    uint amountInWithFee = amountIn.mul(997);
    uint numerator = amountInWithFee.mul(reserveOut);
    uint denominator = reserveIn.mul(1000).add(amountInWithFee);
    amountOut = numerator / denominator;
  }

  // Function from UniV2 library at https://github.com/Uniswap/v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol
  function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
    require(amountOut > 0, 'ArBot: INSUFFICIENT_OUTPUT_AMOUNT');
    require(reserveIn > 0 && reserveOut > 0, 'ArBot: INSUFFICIENT_LIQUIDITY');
    uint numerator = reserveIn.mul(amountOut).mul(1000);
    uint denominator = reserveOut.sub(amountOut).mul(997);
    amountIn = (numerator / denominator).add(1);
  }
}
