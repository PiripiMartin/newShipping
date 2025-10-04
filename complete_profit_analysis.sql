-- =====================================================
-- COMPLETE PROFIT ANALYSIS WITH LOGISTICS COSTS
-- =====================================================
-- Logistics costs = Internal fulfillment (5.47 per unit) + Carrier costs - Carrier cost recoveries

USE Shipping;

-- =====================================================
-- GROSS PROFIT PERCENTAGE
-- =====================================================
SELECT 
    'Gross Profit Analysis' as Analysis,
    SUM(s.salesAmount) as TotalSales,
    SUM(s.costOfGoodsSold) as TotalCOGS,
    (SUM(s.salesAmount) - SUM(s.costOfGoodsSold)) as GrossProfit,
    ROUND(
        CASE 
            WHEN SUM(s.salesAmount) = 0 THEN 0
            ELSE ((SUM(s.salesAmount) - SUM(s.costOfGoodsSold)) / SUM(s.salesAmount)) * 100
        END, 
        2
    ) as GrossProfitPercentage
FROM sales s;

-- =====================================================
-- NET PROFIT PERCENTAGE (with total logistics costs)
-- =====================================================
SELECT 
    'Net Profit Analysis' as Analysis,
    SUM(s.salesAmount) as SalesSum,
    SUM(s.costOfGoodsSold) as COGSSum,
    SUM(s.units) as UnitsSum,
    SUM(s.units) * 5.47 as FulfillmentCost,
    COALESCE(SUM(cc.amountExcludingTax), 0) as CarrierCost,
    COALESCE(SUM(ccr.freightRecovery), 0) as CarrierCostRecovery,
    (SUM(s.units) * 5.47 + COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) as TotalLogisticsCost,
    (SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(SUM(cc.amountExcludingTax), 0) + COALESCE(SUM(ccr.freightRecovery), 0)) as NetProfit,
    ROUND(
        CASE 
            WHEN SUM(s.salesAmount) = 0 THEN 0
            ELSE ((SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(SUM(cc.amountExcludingTax), 0) + COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100
        END, 
        2
    ) as NetProfitPercentage
FROM sales s
LEFT JOIN orders o ON s.consignmentId = o.consignmentId
LEFT JOIN carrierCosts cc ON o.consignmentId = cc.consignmentId
LEFT JOIN carrierCostRecoveries ccr ON o.consignmentId = ccr.consignmentId;

-- =====================================================
-- FULFILLMENT COST PERCENTAGE (internal fulfillment only)
-- =====================================================
SELECT 
    'Fulfillment Cost Analysis' as Analysis,
    SUM(s.salesAmount) as SalesSum,
    SUM(s.units) as UnitsSum,
    SUM(s.units) * 5.47 as FulfillmentCost,
    ROUND(
        CASE 
            WHEN SUM(s.salesAmount) = 0 THEN 0
            ELSE ((SUM(s.units) * 5.47) / SUM(s.salesAmount)) * 100
        END, 
        2
    ) as FulfillmentCostPercentage
FROM sales s;

-- =====================================================
-- CARRIER COST PERCENTAGE (shipping costs only)
-- =====================================================
SELECT 
    'Carrier Cost Analysis' as Analysis,
    SUM(s.salesAmount) as SalesSum,
    COALESCE(SUM(cc.amountExcludingTax), 0) as CarrierCost,
    COALESCE(SUM(ccr.freightRecovery), 0) as CarrierCostRecovery,
    (COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) as NetCarrierCost,
    ROUND(
        CASE 
            WHEN SUM(s.salesAmount) = 0 THEN 0
            ELSE ((COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100
        END, 
        2
    ) as NetCarrierCostPercentage
FROM sales s
LEFT JOIN orders o ON s.consignmentId = o.consignmentId
LEFT JOIN carrierCosts cc ON o.consignmentId = cc.consignmentId
LEFT JOIN carrierCostRecoveries ccr ON o.consignmentId = ccr.consignmentId;

-- =====================================================
-- TOTAL LOGISTICS COST PERCENTAGE (fulfillment + net carrier cost)
-- =====================================================
SELECT 
    'Total Logistics Cost Analysis' as Analysis,
    SUM(s.salesAmount) as SalesSum,
    SUM(s.units) as UnitsSum,
    SUM(s.units) * 5.47 as FulfillmentCost,
    COALESCE(SUM(cc.amountExcludingTax), 0) as CarrierCost,
    COALESCE(SUM(ccr.freightRecovery), 0) as CarrierCostRecovery,
    (SUM(s.units) * 5.47 + COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) as TotalLogisticsCost,
    ROUND(
        CASE 
            WHEN SUM(s.salesAmount) = 0 THEN 0
            ELSE ((SUM(s.units) * 5.47 + COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100
        END, 
        2
    ) as TotalLogisticsCostPercentage
FROM sales s
LEFT JOIN orders o ON s.consignmentId = o.consignmentId
LEFT JOIN carrierCosts cc ON o.consignmentId = cc.consignmentId
LEFT JOIN carrierCostRecoveries ccr ON o.consignmentId = ccr.consignmentId;

-- =====================================================
-- COMPREHENSIVE SUMMARY (All metrics in one query)
-- =====================================================
SELECT 
    'COMPREHENSIVE ANALYSIS' as Analysis,
    SUM(s.salesAmount) as TotalSales,
    SUM(s.costOfGoodsSold) as TotalCOGS,
    SUM(s.units) as TotalUnits,
    
    -- Costs breakdown
    (SUM(s.salesAmount) - SUM(s.costOfGoodsSold)) as GrossProfit,
    SUM(s.units) * 5.47 as FulfillmentCost,
    COALESCE(SUM(cc.amountExcludingTax), 0) as CarrierCost,
    COALESCE(SUM(ccr.freightRecovery), 0) as CarrierCostRecovery,
    (SUM(s.units) * 5.47 + COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) as TotalLogisticsCost,
    
    -- Final net profit
    (SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(SUM(cc.amountExcludingTax), 0) + COALESCE(SUM(ccr.freightRecovery), 0)) as NetProfit,
    
    -- Percentages
    ROUND(((SUM(s.salesAmount) - SUM(s.costOfGoodsSold)) / SUM(s.salesAmount)) * 100, 2) as GrossProfitPercentage,
    ROUND(((SUM(s.units) * 5.47) / SUM(s.salesAmount)) * 100, 2) as FulfillmentCostPercentage,
    ROUND(((COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100, 2) as NetCarrierCostPercentage,
    ROUND((COALESCE(SUM(ccr.freightRecovery), 0) / SUM(s.salesAmount)) * 100, 2) as CarrierCostRecoveryPercentage,
    ROUND(((SUM(s.units) * 5.47 + COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100, 2) as TotalLogisticsCostPercentage,
    ROUND(((SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(SUM(cc.amountExcludingTax), 0) + COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100, 2) as NetProfitPercentage

FROM sales s
LEFT JOIN orders o ON s.consignmentId = o.consignmentId
LEFT JOIN carrierCosts cc ON o.consignmentId = cc.consignmentId
LEFT JOIN carrierCostRecoveries ccr ON o.consignmentId = ccr.consignmentId;
