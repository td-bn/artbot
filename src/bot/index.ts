import logger from '../utils/log'
import { allCombinations } from '../utils/config'
import { getContractInstance } from '../utils/contract';
import { Contract } from '@ethersproject/contracts';
import { verifyPairs } from './tokens';

async function main() {
  logger.error('Hello, World!')

  const pairs = allCombinations().entries()
  for (const pair of pairs) {
    logger.debug(pair)
  }

  const contract: Contract = getContractInstance();
  logger.info(`Contract deployed at: ${contract.address}`);

  await verifyPairs();
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
