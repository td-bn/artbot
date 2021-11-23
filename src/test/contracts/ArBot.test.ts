import { BigNumber } from "@ethersproject/bignumber"
import { Contract } from "@ethersproject/contracts"
import { expect } from "chai"
import { allCombinations, exchanges } from "../../utils/config"
import { getContractInstance } from "../../utils/contract"

describe('ArBot', () => {
  let instance: Contract
  before( async () => {
    instance = getContractInstance()
  }) 

  describe('getReserves', () => {
    it('should get reserve data', async () => {
      const reserves = await instance.getReserves(exchanges[0], exchanges[1]) 
      expect(!reserves.dai1.gt(BigNumber.from(0)))
      expect(!reserves.weth1.gt(BigNumber.from(0)))
      expect(!reserves.dai2.gt(BigNumber.from(0)))
      expect(!reserves.weth2.gt(BigNumber.from(0)))
    })
  })
  
  describe('getProfit', () => {
    it('should get the expected profit from opportunity', async () => {
      const pairs = allCombinations().entries()
      for (const pair of pairs) {
        const [e1, e2] = pair[1]
        const profit = instance.calculateProfit(e1, e2)
      }
    })
  })
})
