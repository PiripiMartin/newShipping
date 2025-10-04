-- =====================================================
-- LOGISTICS COST PERCENTAGE CALCULATION
-- =====================================================
-- Logistics Cost % = (Units * 5.47) / Sales * 100

USE Shipping;

SELECT 
    SUM(salesAmount) as SalesSum,
    SUM(units) as UnitsSum,
    SUM(units) * 5.47 as LogisticsCost,
    ROUND(
        CASE 
            WHEN SUM(salesAmount) = 0 THEN 0
            ELSE ((SUM(units) * 5.47) / SUM(salesAmount)) * 100
        END, 
        2
    ) as LogisticsCostPercentage
FROM sales;
