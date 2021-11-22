export const tokens = {
  WETH: '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2',
  DAI: '0x6b175474e89094c44da98b954eedeac495271d0f'
}

export const tokenName = {
  '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2': 'WETH',
  '0x6b175474e89094c44da98b954eedeac495271d0f': 'DAI'
}

export const exchangeName = {
  '0xa478c2975ab1ea89e8196811f51a7b7ade33eb11': 'UniswapV2',
  '0xc3d03e4f041fd4cd388c549ee2a29a9e5075882f': 'Sushiswap',
  '0x8faf958e36c6970497386118030e6297fff8d275': 'Shebaswap',
  '0x2ad95483ac838e2884563ad278e933fba96bc242': 'Sakeswap',
  '0x60a26d69263ef43e9a68964ba141263f19d71d51': 'Croswap'
}

export const exchanges = [
  '0xa478c2975ab1ea89e8196811f51a7b7ade33eb11',
  '0xc3d03e4f041fd4cd388c549ee2a29a9e5075882f',
  '0x8faf958e36c6970497386118030e6297fff8d275',
  '0x2ad95483ac838e2884563ad278e933fba96bc242',
  '0x60a26d69263ef43e9a68964ba141263f19d71d51'
]

export const allCombinations = (): string[][] => {
  return exchanges
    .map((exchange, i) =>
      exchanges
        .filter((_, j) => i < j)
        .map((otherExchange) => [exchange, otherExchange])
    )
    .flat()
}
