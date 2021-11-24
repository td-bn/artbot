import { Contract, ethers, Signer } from 'ethers';
import {abi, address as depAddress} from '../../deployments/localhost/ArBot.json'
import uniswapV2 from '@studydefi/money-legos/uniswapV2'
import ERC20 from '@studydefi/money-legos/erc20/abi/ERC20.json'
import { tokens } from './config';

const provider = new ethers.providers.JsonRpcProvider()

export const getSigner = (): Signer => provider.getSigner()

export const getContractInstance = (): Contract => {
  const contract = new ethers.Contract(depAddress, abi, provider)
  return contract
}

export const getV2PairInstance = (address: string): Contract => {
  const abi = uniswapV2.pair.abi
  const contract = new ethers.Contract(address, abi, provider)
  return contract
}

export const getDaiInstance = (): Contract => {
  return new ethers.Contract(tokens.DAI, ERC20, provider)
}