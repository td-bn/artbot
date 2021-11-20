import logger from '../utils/log'
import { allCombinations } from '../utils/config'

async function main() {
  logger.error('Hello, World!')
  const pairs = allCombinations().entries()
  for (const pair of pairs) {
    logger.debug(pair)
  }
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
