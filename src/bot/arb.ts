import { ethers, BigNumber } from 'ethers'
import { getContractInstance } from '../utils/contract'

export const tryArbitrage = async (pool1: string, pool2: string) => {
  const instance = getContractInstance()
  const profit: BigNumber = await instance.calculateProfit(pool1, pool2)
  return profit
  // return profit.div(ethers.constants.WeiPerEther)
}