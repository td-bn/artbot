// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IUniswapV2Pair.sol";
import "hardhat/console.sol";

library SafeMath {
  function add(uint x, uint y) internal pure returns (uint z) {
      require((z = x + y) >= x, 'ds-math-add-overflow');
  }

  function sub(uint x, uint y) internal pure returns (uint z) {
      require((z = x - y) <= x, 'ds-math-sub-underflow');
  }

  function mul(uint x, uint y) internal pure returns (uint z) {
      require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
  }
}

contract ArBot {
  using SafeMath for uint256;

  struct Reserves {
    uint256 dai1;
    uint256 weth1;
    uint256 dai2;
    uint256 weth2;
    address lowerPool;
    address otherPool;
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

    address lower = priceDai1 < priceDai2 ? _pool0 : _pool1;
    address other = lower == _pool1 ? _pool0 : _pool1;
    reserves = Reserves(dai1, weth1, dai2, weth2, lower, other);
  }

  // Calculate profit that results from a trade between two pools
  function calculateProfit(address _pool0, address _pool1) public view returns (uint256 profit) {
    Reserves memory reserves = getReserves(_pool0, _pool1);

    uint256 loan = _calcLoan(reserves);

    // TODO Complete

  }

  // Calculate the borrow amount that maximizes the profit
  function _calcLoan(Reserves memory reserves) internal pure returns (uint256 toLoan) {
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

    (int256 a1, int256 a2, int256 b1, int256 b2) =
      (int256(reserves.dai1 / d), int256(reserves.weth1 / d), int256(reserves.dai2 / d), int256(reserves.weth2 / d));

    (int256 x1, int256 x2) = _solveQuadratic(a1, a2, b1, b2);
    return (x1 > 0 && x1 < b1 && x1 < b2) ? uint256(x1) * d : uint256(x2) * d;
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
    uint256 m1 = reserves.dai1 < reserves.dai2 ? reserves.dai1 : reserves.dai2;
    min = reserves.weth1 < reserves.weth2 ? reserves.weth1 : reserves.weth2;
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