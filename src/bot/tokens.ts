import { getContractInstance, getV2PairInstance } from '../utils/contract';
import logger from '../utils/log';
import { exchanges, tokens } from '../utils/config';

const assert = (condition: boolean, message: string) => {
  if (!condition)
    logger.error('Assert failed: ' + (message || ''))
}

export const compareAddresses = async (token1: string, token2: string) => {
  const contract = getContractInstance()
  const less = await contract.addressCompare(token1, token2)
  return less ? [token1, token2] : [token2, token1]
}

export const verifyPairs = async () => {
  for (const V2Address of exchanges) {
    const V2Pair = getV2PairInstance(V2Address)
    let token0: string = await V2Pair.token0()
    let token1: string = await V2Pair.token1()
    token0 = token0.toLowerCase()
    token1 = token1.toLowerCase()

    assert( token0 == tokens.DAI && token1 == tokens.WETH, "Token mismatch")
  }
}