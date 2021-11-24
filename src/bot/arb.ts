import { ethers, BigNumber } from 'ethers'
import { getContractInstance, getDaiInstance, getSigner } from '../utils/contract';
import logger from '../utils/log';

export const tryArbitrage = async (pool1: string, pool2: string) => {
  const instance = getContractInstance()
  const profit: BigNumber = await instance.calculateProfit(pool1, pool2)
  return profit
  // return profit.div(ethers.constants.WeiPerEther)
}

export const executeOpportunity = async (e1: string, e2: string) => {
  const instance = getContractInstance()
  const signer = getSigner()
  try {
    await instance.connect(signer).arbitrate(e1, e2)
    logger.info(`DAI balance after trade: ${await daiBalance(instance.address)}`)
  } catch (err) {
    logger.error('Error while trying to exec arbitrage')
    logger.error(err)
  }
}

export const daiBalance = async (address: string) => {
  const daiInstance = getDaiInstance()
  const balance = await daiInstance.balanceOf(address)
  return balance
}