## Learning Outcomes
* Uniswap v2 pair creation
* create vs create2 OPCODE (deployer-address, nonce) vs (deployer-address, bytecode, salt)

## Possible Improvements
* make generic token compare that works for all possible pairs of token on UniswapV2 pairs.
  Currently we know that address(DAI) < address(WETH). This may **not** be the case for all
  possible pairs.