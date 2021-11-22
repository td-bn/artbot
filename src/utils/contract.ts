import { Contract, ethers } from 'ethers';
import {abi, address as depAddress} from '../../deployments/localhost/ArBot.json'
import uniswapV2 from '@studydefi/money-legos/uniswapV2'

const provider = new ethers.providers.JsonRpcProvider()

export const getContractInstance = (): Contract => {
  const contract = new ethers.Contract(depAddress, abi, provider)
  return contract
}

export const getV2PairInstance = (address: string): Contract => {
  const abi = uniswapV2.pair.abi
  const contract = new ethers.Contract(address, abi, provider)
  return contract
}