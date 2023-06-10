// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the Arrakis Strategy interface
import "@arrakis/arrakis-contracts/contracts/interfaces/IStrategy.sol";

// Import the Uniswap V3 library
import "@uniswap/v3-periphery/contracts/libraries/PoolVariables.sol";

// Import the ATR library
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Define the strategy contract
contract DynamicNonBinaryGridBotStrategy is IStrategy {
    // Use the SafeMath library for uint256 operations
    using SafeMath for uint256;

    // Define the state variables
    address public immutable override vault; // The address of the vault using this strategy
    address public immutable override pool; // The address of the Uniswap V3 pool
    int24 public immutable tickSpacing; // The tick spacing of the pool
    uint256 public atrPeriod; // The period of the ATR indicator
    uint256 public atrMultiplier; // The multiplier of the ATR indicator
    uint256 public maPeriod; // The period of the moving average indicator
    string public maType; // The type of the moving average indicator (simple, exponential, weighted etc.)
    uint256 public maTrendFactor; // The trend factor for adjusting the trade percentage based on the moving average

    // Define the constructor
    constructor(
        address _vault, // The address of the vault
        address _pool, // The address of the pool
        uint256 _atrPeriod, // The period of the ATR indicator
        uint256 _atrMultiplier, // The multiplier of the ATR indicator
        uint256 _maPeriod, // The period of the moving average indicator
        string memory _maType // The type of the moving average indicator
    ) {
        // Check that the vault and pool addresses are not zero
        require(_vault != address(0), "Invalid vault address");
        require(_pool != address(0), "Invalid pool address");

        // Check that the atrPeriod and atrMultiplier are positive and not too small or too large
        require(_atrPeriod > 0 && _atrPeriod < 1000, "Invalid atrPeriod");
        require(_atrMultiplier > 0 && _atrMultiplier < 1000, "Invalid atrMultiplier");

        // Check that the maPeriod is positive and not too small or too large
        require(_maPeriod > 0 && _maPeriod < 1000, "Invalid maPeriod");

        // Check that the maType is valid (simple, exponential, weighted etc.)
        require(
            keccak256(bytes(_maType)) == keccak256(bytes("simple")) ||
                keccak256(bytes(_maType)) == keccak256(bytes("exponential")) ||
                keccak256(bytes(_maType)) == keccak256(bytes("weighted")),
            "Invalid maType"
        );

        // Set the state variables
        vault = _vault;
        pool = _pool;
        atrPeriod = _atrPeriod;
        atrMultiplier = _atrMultiplier;
        maPeriod = _maPeriod;
        maType = _maType;
        maTrendFactor = 0; // Initialize the maTrendFactor to zero

        // Get the tick spacing of the pool
        tickSpacing = PoolVariables(_pool).tickSpacing();
    }

    // Define a function to set the maTrendFactor by the user
    function setMaTrendFactor(uint256 _maTrendFactor) external {
        // Check that only the vault can call this function
        require(msg.sender == vault, "Unauthorized caller");

        // Check that the maTrendFactor is between 0 and 1
        require(_maTrendFactor >= 0 && _maTrendFactor <= 1, "Invalid maTrendFactor");

        // Set the state variable
        maTrendFactor = _maTrendFactor;
    }

    // Define the rebalance function
    function rebalance(
        int24 currentTick, // The current tick of the pool
        uint256 amount0, // The amount of token0 in the vault
        uint256 amount1 // The amount of token1 in the vault
    ) external override returns (uint256 amount0Delta, uint256 amount1Delta) {
        // Check that only the vault can call this function
        require(msg.sender == vault, "Unauthorized caller");

        // Calculate the current price from the current tick
        uint160 sqrtPriceX96 = PoolVariables(pool).getSqrtRatioAtTick(
            currentTick
        );
        uint256 currentPrice = PoolVariables(pool).getPriceAtSqrtRatio(
            sqrtPriceX96
        );

        // Calculate the ATR value from the pool price history
        uint256 atrValue = calculateATR(currentPrice);

        // Calculate the upper and lower price levels based on the ATR value and multiplier
        uint256 upperPrice = currentPrice.add(atrValue.mul(atrMultiplier));
        uint256 lowerPrice = currentPrice.sub(atrValue.mul(atrMultiplier));

        // Convert the upper and lower price levels to ticks
        int24 upperTick = PoolVariables(pool).getTickAtSqrtRatio(
            PoolVariables(pool).getSqrtRatioAtPrice(upperPrice)
        );
        int24 lowerTick = PoolVariables(pool).getTickAtSqrtRatio(
            PoolVariables(pool).getSqrtRatioAtPrice(lowerPrice)
        );

        // Calculate the price range between the upper and lower ticks
        uint256 priceRange = upperPrice - lowerPrice;

        // Calculate the MA value from the pool price history
        uint256 maValue = calculateMA(currentPrice);

        // Calculate the MAPercent value from the current price and the MA value
        uint256 maPercent = currentPrice.mul(100) / maValue;

        // Check if the current tick is above or below the upper or lower ticks
        if (currentTick > upperTick) {
            // We are above the upper tick, so we sell token0 and buy token1
            // Check that the current price is not too far from the upper price
            require(currentPrice <= upperPrice.add(priceRange), "Invalid current price");

            // Calculate the distance from the current price to the upper price
            uint256 distance = currentPrice - upperPrice;

            // Calculate the trade percentage using the formula:
            // trade percentage = 100 - (distance / price range) * 100
            uint256 tradePercentage = 100 - (distance.mul(100) / priceRange);

            // Adjust the trade percentage using the MAPercent and maTrendFactor values
            tradePercentage = ((maPercent.mul(maTrendFactor)) + (tradePercentage.mul(100))) / (100 + maTrendFactor);

            // Clamp the trade percentage between 0 and 100
            tradePercentage = clamp(tradePercentage, 0, 100);

            // Calculate the amount to trade using the trade percentage
            amount0Delta = amount0.mul(tradePercentage) / 100 * (-1); // Sell token0
            amount1Delta = amount1.mul(tradePercentage) / 100; // Buy token1
        } else if (currentTick < lowerTick) {
            // We are below the lower tick, so we sell token1 and buy token0
            // Check that the current price is not too far from the lower price
            require(currentPrice >= lowerPrice.sub(priceRange), "Invalid current price");

            // Calculate the distance from the current price to the lower price
            uint256 distance = lowerPrice - currentPrice;

            // Calculate the trade percentage using the formula:
            // trade percentage = 100 - (distance / price range) * 100
            uint256 tradePercentage = 100 - (distance.mul(100) / priceRange);

            // Adjust the trade percentage using the MAPercent and maTrendFactor values
            tradePercentage = ((maPercent.mul(maTrendFactor)) + (tradePercentage.mul(100))) / (100 + maTrendFactor);

            // Clamp the trade percentage between 0 and 100
            tradePercentage = clamp(tradePercentage, 0, 100);

            // Calculate the amount to trade using the trade percentage
            amount0Delta = amount0.mul(tradePercentage) / 100; // Buy token0
            amount1Delta = amount1.mul(tradePercentage) / 100 * (-1); // Sell token1
        } else {
            // We are between the upper and lower ticks, so we do nothing
            amount0Delta = 0;
            amount1Delta = 0;
        }

        // Return the amounts to trade
        return (amount0Delta, amount1Delta);
    }

    // Define a helper function to calculate the ATR value from the pool price history
    function calculateATR(uint256 currentPrice)
        internal
        view
        returns (uint256)
    {
        // Initialize an array to store the true range values
        uint256[] memory trueRanges = new uint256[](atrPeriod);

        // Loop through the pool price history and calculate the true range for each period
        for (uint256 i = 0; i < atrPeriod; i++) {
            // Get the previous price from the pool price history
            uint256 previousPrice = PoolVariables(pool).priceHistory(i);

            // Calculate the true range using the formula:
            // true range = max(current price - previous price, previous price - current price)
            uint256 trueRange;
            if (currentPrice > previousPrice) {
                trueRange = currentPrice - previousPrice;
            } else {
                trueRange = previousPrice - currentPrice;
            }

            // Store the true range in the array
            trueRanges[i] = trueRange;
        }

        // Calculate the average true range using the formula:
        // average true range = sum of true ranges / number of periods
        uint256 sumOfTrueRanges;
        for (uint256 i = 0; i < atrPeriod; i++) {
            sumOfTrueRanges += trueRanges[i];
        }
        uint256 averageTrueRange = sumOfTrueRanges / atrPeriod;

        // Return the average true range value
        return averageTrueRange;
    }

    // Define a helper function to calculate the MA value from the pool price history
    function calculateMA(uint256 currentPrice)
        internal
        view
        returns (uint256)
    {
        // Initialize an array to store the price values
        uint256[] memory prices = new uint256[](maPeriod);

        // Loop through the pool price history and store the price values in the array
        for (uint256 i = 0; i < maPeriod; i++) {
            // Get the previous price from the pool price history
            uint256 previousPrice = PoolVariables(pool).priceHistory(i);

            // Store the previous price in the array
            prices[i] = previousPrice;
        }

        // Calculate the MA value based on the maType
        uint256 maValue;
        if (keccak256(bytes(maType)) == keccak256(bytes("simple"))) {
            // Calculate the simple moving average using the formula:
            // simple moving average = sum of prices / number of periods
            uint256 sumOfPrices;
            for (uint256 i = 0; i < maPeriod; i++) {
                sumOfPrices += prices[i];
            }
            maValue = sumOfPrices / maPeriod;
        } else if (keccak256(bytes(maType)) == keccak256(bytes("exponential"))) {
            // Calculate the exponential moving average using the formula:
            // exponential moving average = (current price - previous moving average) * multiplier + previous moving average
            // where multiplier = 2 / (number of periods + 1)
            uint256 multiplier = 2 / (maPeriod + 1);
            uint256 previousMA = PoolVariables(pool).priceHistory(maPeriod);
            maValue = (currentPrice - previousMA) * multiplier + previousMA;
        } else if (keccak256(bytes(maType)) == keccak256(bytes("weighted"))) {
            // Calculate the weighted moving average using the formula:
            // weighted moving average = (sum of prices * weights) / sum of weights
            // where weights are assigned in descending order from current price to oldest price
            uint256[] memory weights = new uint256[](maPeriod);
            for (uint256 i = 0; i < maPeriod; i++) {
                weights[i] = maPeriod - i;
            }
            uint256 sumOfPricesTimesWeights;
            uint256 sumOfWeights;
            for (uint256 i = 0; i < maPeriod; i++) {
                sumOfPricesTimesWeights += prices[i] * weights[i];
                sumOfWeights += weights[i];
            }
            maValue = sumOfPricesTimesWeights / sumOfWeights;
        }

        // Return the MA value
        return maValue;
    }

    // Define a helper function to clamp a value between a minimum and a maximum
    function clamp(uint256 value, uint256 min, uint256 max)
        internal
        pure
        returns (uint256)
    {
        // If the value is less than the minimum, return the minimum
        if (value < min) {
            return min;
        }
        // If the value is greater than the maximum, return the maximum
        if (value > max) {
            return max;
        }
        // Otherwise, return the value
        return value;
    }
}
