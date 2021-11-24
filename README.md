# [WIP] Simple UniV2 MEV extraction PoC

* checks for arb oppotunities
* simulate execution of opportunities


## How to run
1. `hh node` forks off the latest block in the mainnet, you can specify a block in the config or command line
2. `hh test` to run tests on WIP contract
3. `hh run src/bot/index.ts` will check for opportunities

## In progress/ TODO
* listen on mainnet -> note block number -> fork at block number to simulate execution
* arbitrage strategies? flashswap, flashloans etc
* Add math explantions in README

## Learning Outcomes
* Uniswap v2 pair creation
* UniV2 FlashSwaps
* Price Curves and a bit of the maths behind them
* create vs create2 OPCODE (deployer-address, nonce) vs (deployer-address, bytecode, salt)

## Possible Improvements
* listen on mainnet -> note block number -> fork at block number to simulate execution
* make generic token compare that works for all possible pairs of token on UniswapV2 pairs.
  Currently we know that address(DAI) < address(WETH). This may **not** be the case for all
  possible pairs.
