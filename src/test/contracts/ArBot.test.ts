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
      expect(!reserves.daiA.gt(BigNumber.from(0)))
      expect(!reserves.wethA.gt(BigNumber.from(0)))
      expect(!reserves.daiB.gt(BigNumber.from(0)))
      expect(!reserves.wethB.gt(BigNumber.from(0)))
    })
  })
  
  describe('getProfit', () => {
    it('should get the expected profit from opportunity', async () => {
      const pairs = allCombinations().entries()
      for (const pair of pairs) {
        const [e1, e2] = pair[1]
        const profit = await instance.calculateProfit(e1, e2)
        expect(profit.gt(-1));
      }
    })
  })
})
