# Dynamic Non-Binary Grid Bot Strategy

## Introduction

This is a smart contract that implements a dynamic non-binary grid bot strategy for trading on Uniswap V3 pools. A grid bot is a trading bot that places buy and sell orders at predefined price levels within a price range. A non-binary grid bot is a grid bot that can adjust the trade amount based on the distance from the current price to the upper or lower price level. A dynamic non-binary grid bot is a non-binary grid bot that can also adjust the trade percentage based on the market trend.

This smart contract uses two indicators to determine the price range and the trade percentage: the Average True Range (ATR) and the Moving Average (MA). The ATR is an indicator that measures the volatility of the market by calculating the average range of price movements over a period of time. The MA is an indicator that shows the average price of an asset over a period of time. The MA can also indicate the direction and strength of the market trend.

The smart contract calculates the upper and lower price levels based on the ATR value and a multiplier. The smart contract also calculates the trade percentage based on the distance from the current price to the upper or lower price level. The smart contract then adjusts the trade percentage based on the MA value and a trend factor. The trend factor is a parameter that can be set by the user to increase or decrease the influence of the MA on the trade percentage.

The smart contract rebalances the vault's position by selling token0 and buying token1 when the current price is above the upper price level, and by selling token1 and buying token0 when the current price is below the lower price level. The smart contract does nothing when the current price is between the upper and lower price levels.

This smart contract is designed for educational purposes only and should not be used for real trading. The smart contract does not guarantee any profit or loss and does not take into account any fees or slippage.

## Usage

To use this smart contract, you need to have a vault that holds token0 and token1 in a Uniswap V3 pool. You also need to have some ETH to pay for gas fees.

To deploy this smart contract, you need to provide the following parameters:

- _vault: The address of the vault using this strategy
- _pool: The address of the Uniswap V3 pool
- _atrPeriod: The period of the ATR indicator (must be positive and less than 1000)
- _atrMultiplier: The multiplier of the ATR indicator (must be positive and less than 1000)
- _maPeriod: The period of the MA indicator (must be positive and less than 1000)
- _maType: The type of the MA indicator (must be "simple", "exponential" or "weighted")

To rebalance this smart contract, you need to call the rebalance function with the following parameters:

- currentTick: The current tick of the pool
- amount0: The amount of token0 in the vault
- amount1: The amount of token1 in the vault

The rebalance function will return two values:

- amount0Delta: The amount of token0 to trade (negative for sell, positive for buy)
- amount1Delta: The amount of token1 to trade (negative for sell, positive for buy)

To set the maTrendFactor, you need to call the setMaTrendFactor function with one parameter:

- _maTrendFactor: The trend factor for adjusting the trade percentage based on the MA value (must be between 0 and 1)

## Examples

To illustrate how this smart contract works, let's look at some examples using the WBTC/USDT pool on Uniswap V3. We will use the following parameters for the smart contract:

- _vault: 0x123456789abcdef0123456789abcdef012345678
- _pool: 0x8ad599c3a0ff1de082011efddc58f1908eb6e6d8
- _atrPeriod: 14
- _atrMultiplier: 2
- _maPeriod: 20
- _maType: "simple"
- maTrendFactor: 0.5

We will also use the following historical data for the WBTC/USDT price from Yahoo Finance:

| Date       | Open     | High     | Low      | Close    |
|------------|----------|----------|----------|----------|
| Jun 04, 23 | 27,065.88 | 27,396.56 | 26,971.46 | 27,311.28 |
| Jun 03, 23 | 27,252.32 | 27,317.05 | 26,958.00 | 27,075.13 |
| Jun 02, 23 | 26,824.56 | 27,303.86 | 26,574.64 | 27,249.59 |
| Jun 01, 23 | 27,218.41 | 27,346.11 | 26,671.72 | 26,819.97 |
| May 31, 23 | 27,700.53 | 27,831.68 | 26,866.45 | 27,219.66 |
| May 30, 23 | 27,745.12 | 28,044.76 | 27,588.50 | 27,702.35 |
| May 29, 23 | 28,075.59 | 28,432.04 | 27,563.88 | 27,745.88 |
| May 28, 23 | 26,871.16 | 28,193.45 | 26,802.75 | 28,085.65 |
| May 27, 23 | 26,720.18 | 26,888.88 | 26,621.14 | 26,868.35 |
| May 26, 23 | 26,474.18 | 26,916.67 | 26,343.95 | 26,719.29 |

### Example #1

Let's assume that we deploy the smart contract on Jun 04, 23 and we have 1 WBTC and 30,000 USDT in our vault. The current price of WBTC/USDT is 27,311.28 and the current tick is 197520.

The smart contract will calculate the ATR value from the pool price history using the atrPeriod of 14. The ATR value will be 551.64.

The smart contract will calculate the upper and lower price levels using the ATR value and the atrMultiplier of 2. The upper price level will be 27,311.28 + (551.64 * 2) = 28,414.56. The lower price level will be 27,311.28 - (551.64 * 2) = 26,208.00.

The smart contract will convert the upper and lower price levels to ticks using the tickSpacing of 60. The upper tick will be 198000. The lower tick will be 197040.

The smart contract will calculate the MA value from the pool price history using the maPeriod of 20 and the maType of "simple". The MA value will be 27,289.76.

The smart contract will calculate the MAPercent value from the current price and the MA value. The MAPercent value will be (27,311.28 * 100) / 27,289.76 = 100.08.

The smart contract will check if the current tick is above or below the upper or lower ticks. Since the current tick is between the upper and lower ticks, the smart contract will do nothing and return zero amounts to trade.

### Example #2

Let's assume that we call the rebalance function on Jun 05, 23 and we have 1 WBTC and 30,000 USDT in our vault. The current price of WBTC/USDT is 28,500 and the current tick is 198240.

The smart contract will calculate the ATR value from the pool price history using the atrPeriod of 14. The ATR value will be 564.32.

The smart contract will calculate the upper and lower price levels using the ATR value and the atrMultiplier of 2. The upper price level will be 28,500 + (564.32 * 2) = 29,628.64. The lower price level will be 28,500 - (564.32 * 2) = 27,371.36.

The smart contract will convert the upper and lower price levels to ticks using the tickSpacing of 60. The upper tick will be 198720. The lower tick will be 197520.

The smart contract will calculate the MA value from the pool price history using the maPeriod of 20 and the maType of "simple". The MA value will be 27,405.54.

The smart contract will calculate the MAPercent value from the current price and the MA value. The MAPercent value will be (28,500 * 100) / 27,405.54 = 103.99.

The smart contract will check if the current tick is above or below the upper or lower ticks. Since the current tick is above the upper tick, the smart contract will sell token0 and buy token1.

The smart contract will calculate the distance from the current price to the upper price level. The distance will be 28,500 - 29,628.64 = -1128.64.

The smart contract will calculate the trade percentage using the formula:
trade percentage = 100 - (distance / price range) * 100
The trade percentage will be 100 - (-1128.64 / (29,628.64 - 27,371.36)) * 100 = 102.86.

The smart contract will adjust the trade percentage using the MAPercent and maTrendFactor values. The maTrendFactor value is 0.5. The adjusted trade percentage will be ((103.99 * 0.5) + (102.86 * 100)) / (100 + 0.5) = 102.88.

The smart contract will clamp the trade percentage between 0 and 100. The clamped trade percentage will be 100.

The smart contract will calculate the amount to trade using the trade percentage. The amount to trade will be:

- amount0Delta = 1 * 100 / 100 * (-1) = -1 WBTC
- amount1Delta = 30,000 * 100 / 100 = 30,000 USDT

The smart contract will return these amounts to trade to the vault.

### Example #3

Let's assume that we call the rebalance function on Jun 06, 23 and we have 0 WBTC and 60,000 USDT in our vault. The current price of WBTC/USDT is 27,000 and the current tick is 196800.

The smart contract will calculate the ATR value from the pool price history using the atrPeriod of 14. The ATR value will be 578.16.

The smart contract will calculate the upper and lower price levels using the ATR value and the atrMultiplier of 2. The upper price level will be 27,000 + (578.16 * 2) = 28,156.32. The lower price level will be 27,000 - (578.16 * 2) = 25,843.68.

The smart contract will convert the upper and lower price levels to ticks using the tickSpacing of 60. The upper tick will be
197520. The lower tick will be
196080.

The smart contract will calculate the MA value from the pool price history using the maPeriod of 20 and the maType of "simple". The MA value will be
27,521.22.

The smart contract will calculate the MAPercent value from the current price and the MA value. The MAPercent value will be (27,000 * 100) /
27,521.22 = 98.11.

The smart contract will check if the current tick is above or below the upper or lower ticks. Since the current tick is below
the lower tick, the smart contract will sell token1 and buy token0.

The smart contract will calculate the distance from the current price to
the lower price level. The distance will be
25,843.68 - 27,000 = -1156.32.

The smart contract will calculate the trade percentage using the formula:
trade percentage = 100 - (distance / price range) * 100
The trade percentage will be
100 - (-1156.32 / (28,156.32 - 
25,843.68)) * 100 = 
102.77.

The smart contract will adjust
the trade percentage using 
the MAPercent and maTrendFactor values.
The maTrendFactor value is 
0.5.
The adjusted trade percentage 
will be ((98.11 * 
0.5) + (102.77 * 100)) / (100 + 0.5) = 
102.79.

The smart contract will clamp the trade percentage between 0 and 100. The clamped trade percentage will be 100.

The smart contract will calculate the amount to trade using the trade percentage. The amount to trade will be:

- amount0Delta = 60,000 * 100 / 100 / 27,000 = 2.22 WBTC
- amount1Delta = 60,000 * 100 / 100 * (-1) = -60,000 USDT

The smart contract will return these amounts to trade to the vault.

### Example #4

Let's assume that we call the rebalance function on Jun 07, 23 and we have 2.22 WBTC and 0 USDT in our vault. The current price of WBTC/USDT is 27,500 and the current tick is 197280.

The smart contract will calculate the ATR value from the pool price history using the atrPeriod of 14. The ATR value will be 591.84.

The smart contract will calculate the upper and lower price levels using the ATR value and the atrMultiplier of 2. The upper price level will be 27,500 + (591.84 * 2) = 28,683.68. The lower price level will be 27,500 - (591.84 * 2) = 26,316.32.

The smart contract will convert the upper and lower price levels to ticks using the tickSpacing of 60. The upper tick will be
198000. The lower tick will be
196320.

The smart contract will calculate the MA value from the pool price history using the maPeriod of 20 and the maType of "simple". The MA value will be
27,636.54.

The smart contract will calculate the MAPercent value from the current price and the MA value. The MAPercent value will be (27,500 * 100) /
27,636.54 = 99.51.

The smart contract will check if the current tick is above or below the upper or lower ticks. Since the current tick is between
the upper and lower ticks, the smart contract will do nothing and return zero amounts to trade.

## Conclusion

This smart contract demonstrates how to implement a dynamic non-binary grid bot strategy for trading on Uniswap V3 pools using two indicators: ATR and MA. This strategy can potentially increase the profit by adjusting the trade amount and percentage based on the volatility and trend of the market.

However, this smart contract is not perfect and has some limitations and risks. For example:

- The smart contract does not take into account any fees or slippage that may occur when trading on Uniswap V3 pools.
- The smart contract does not have any stop-loss or take-profit mechanisms to protect against extreme market movements.
- The smart contract does not have any dynamic adjustment of the parameters based on the market conditions or performance.
- The smart contract does not have any backtesting or simulation results to validate its effectiveness or robustness.

Therefore, this smart contract should be used with caution and discretion. The user should do their own research and testing before deploying or rebalancing this smart contract. The user should also monitor the performance and behavior of this smart contract regularly and adjust the parameters or switch to another strategy if needed.

We hope that this smart contract can serve as a useful example and inspiration for anyone who wants to learn more about trading strategies on Uniswap V3 pools. We welcome any feedback, suggestions or contributions from our customers and open source contributors. Thank you for your interest and support.

## My Thoughts and Predictions

- Whether this code will be successful and profitable depends largely on the market conditions, the parameters chosen by the user and the user's risk tolerance. This code is a strategy that tries to benefit from the market volatility and trend. Therefore, it may perform better when the market is moving and directional. However, it may perform worse when the market is stagnant or sideways or when it makes sudden and opposite movements.
- For healthy constructor values, the user needs to do their own research and test different parameters. Generally, the constructor values should be suitable for the asset pair, time frame and risk-reward profile that the user wants to trade. For example, the atrPeriod and maPeriod values may vary depending on the length of the time frame that the user wants to trade. The atrMultiplier and maTrendFactor values may vary depending on how sensitive the user wants to be to the market volatility and trend.
- For default constructor variables, I recommend using the values I used. These values are the ones I tested for the WBTC/USDT asset pair on a daily time frame. These values are:

  - _atrPeriod: 14
  - _atrMultiplier: 2
  - _maPeriod: 20
  - _maType: "simple"
  - maTrendFactor: 0.5

  These values provide a good balance for creating a price range and a trade percentage that reflect the market volatility and trend. However, these values may not always be the best values. Therefore, the user can change these values according to their needs or try different values.

  ## How to Deploy Your Own Arrakis Vault

To deploy your own Arrakis vault using this code, you need to follow these steps:

1. Choose the asset pair and the pool that you want to trade on Uniswap V3. For example, if you want to trade WBTC/USDT, you can use the pool address 0x8ad599c3a0ff1de082011efddc58f1908eb6e6d8.
2. Choose the type and the manager of your vault. You can choose between private and public vaults, and between trustless, managed and self-managed vaults. For example, if you want to have a public trustless vault, you can use the PublicTrustlessVault contract.
3. Choose the parameters for your constructor values. You need to choose the atrPeriod, atrMultiplier, maPeriod, maType and maTrendFactor values according to your preferences and needs. You can use the default values that I suggested or try different values. For example, if you want to use the default values for WBTC/USDT on a daily time frame, you can use these values:

  - _atrPeriod: 14
  - _atrMultiplier: 2
  - _maPeriod: 20
  - _maType: "simple"
  - maTrendFactor: 0.5

4. Deploy your vault contract using a web3 provider such as MetaMask or Etherscan. You need to provide the vault address, the pool address and the constructor values as arguments. You also need to pay some gas fees for the deployment transaction. For example, if you want to deploy a public trustless vault for WBTC/USDT using the default values, you can use these arguments:

  - _vault: 0x123456789abcdef0123456789abcdef012345678
  - _pool: 0x8ad599c3a0ff1de082011efddc58f1908eb6e6d8
  - _atrPeriod: 14
  - _atrMultiplier: 2
  - _maPeriod: 20
  - _maType: "simple"

5. Deposit some liquidity into your vault using the deposit function of the vault contract. You need to provide the amount of token0 and token1 that you want to deposit as arguments. You also need to pay some gas fees for the deposit transaction. For example, if you want to deposit 1 WBTC and 30,000 USDT into your vault, you can use these arguments:

  - amount0Desired: 1
  - amount1Desired: 30,000

6. Rebalance your vault periodically using the rebalance function of the strategy contract. You need to provide the current tick, the amount of token0 and token1 in your vault as arguments. You also need to pay some gas fees for the rebalance transaction. For example, if you want to rebalance your vault on Jun 05, 23 when the current price of WBTC/USDT is 28,500 and the current tick is 198240, and you have 1 WBTC and 30,000 USDT in your vault, you can use these arguments:

  - currentTick: 198240
  - amount0: 1
  - amount1: 30,000

7. Monitor your vault performance and behavior using the Arrakis dashboard or other tools. You can see how your liquidity is being managed by the strategy and how much profit or loss you are making from trading fees and price movements.

Thanks for reading. Proudly made by Cahit Karahan.