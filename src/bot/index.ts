import logger from '../utils/log';
import { allCombinations, exchangeName } from '../utils/config'
import { tryArbitrage, executeOpportunity } from './arb';
import { BigNumber } from '@ethersproject/bignumber';
import { constants, ethers } from 'ethers';
import { display } from '../utils/common';

async function main() {
  const pairs = allCombinations().entries()
  for (const pair of pairs) {
    const [e1, e2] = pair[1]
    try {
      const profit = await tryArbitrage(e1, e2)
      logger.info(`${exchangeName[e1]}-${exchangeName[e2]} profit: ${display(profit)}`)
      // if (profit > BigNumber.from(0)) {
      //   logger.info('Trying to execute opportunity between ${e1} and ${e2}')
      //   await executeOpportunity(e1, e2)
      // }
    } catch (error) {
      logger.error(error)
    }
  }
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
