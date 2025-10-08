-- =====================================================
-- NET PROFIT PERCENTAGE CALCULATION
-- =====================================================
-- Net Profit = SalesSum - COGSSum - (UnitsSum * 5.47)
-- Net Profit % = (Net Profit / SalesSum) * 100

USE Shipping;

SELECT 
    SUM(salesAmount) as SalesSum,
    SUM(costOfGoodsSold) as COGSSum,
    SUM(units) as UnitsSum,
    SUM(units) * 5.47 as LogisticsCost,
    (SUM(salesAmount) - SUM(costOfGoodsSold) - (SUM(units) * 5.47)) as NetProfit,
    ROUND(
        CASE 
            WHEN SUM(salesAmount) = 0 THEN 0
            ELSE ((SUM(salesAmount) - SUM(costOfGoodsSold) - (SUM(units) * 5.47)) / SUM(salesAmount)) * 100
        END, 
        2
    ) as NetProfitPercentage
FROM sales;




