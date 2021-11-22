import { BigNumber } from "@ethersproject/bignumber";
import { Contract } from "@ethersproject/contracts";
import { expect } from "chai";
import { exchanges } from "../../utils/config";
import { getContractInstance } from "../../utils/contract"

describe('ArBot', () => {
  let instance: Contract
  before( async () => {
    instance = getContractInstance(); 
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
})
