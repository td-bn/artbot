import { BigNumber } from "ethers"

export const display = (profit: BigNumber): string => {
  const num = profit.toString()
  const E = num.length - 18
  if (E > 0) {
    return num.substring(0, E) + "." + num.substring(E, 3)   
  } else {
      return "0." + num.substring(0, 2)   
  }
} 
