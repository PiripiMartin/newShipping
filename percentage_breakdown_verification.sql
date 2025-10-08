-- =====================================================
-- PERCENTAGE BREAKDOWN VERIFICATION
-- =====================================================
-- This should add up to 100% of sales revenue

USE Shipping;

SELECT 
    'PERCENTAGE BREAKDOWN VERIFICATION' as Analysis,
    
    -- Revenue base (should be 100%)
    SUM(s.salesAmount) as TotalSales,
    
    -- Cost components as absolute amounts
    SUM(s.costOfGoodsSold) as COGS_Amount,
    SUM(s.units) * 5.47 as FulfillmentCost_Amount,
    COALESCE(SUM(cc.amountExcludingTax), 0) as CarrierCost_Amount,
    COALESCE(SUM(ccr.freightRecovery), 0) as CarrierRecovery_Amount,
    (COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) as NetCarrierCost_Amount,
    (SUM(s.units) * 5.47 + COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) as TotalLogisticsCost_Amount,
    (SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(SUM(cc.amountExcludingTax), 0) + COALESCE(SUM(ccr.freightRecovery), 0)) as NetProfit_Amount,
    
    -- Percentages (should add up to 100%)
    ROUND((SUM(s.costOfGoodsSold) / SUM(s.salesAmount)) * 100, 2) as COGS_Percentage,
    ROUND(((SUM(s.units) * 5.47) / SUM(s.salesAmount)) * 100, 2) as FulfillmentCost_Percentage,
    ROUND(((COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100, 2) as NetCarrierCost_Percentage,
    ROUND(((SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(SUM(cc.amountExcludingTax), 0) + COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100, 2) as NetProfit_Percentage,
    
    -- Verification: This should equal 100%
    ROUND((SUM(s.costOfGoodsSold) / SUM(s.salesAmount)) * 100, 2) +
    ROUND(((SUM(s.units) * 5.47) / SUM(s.salesAmount)) * 100, 2) +
    ROUND(((COALESCE(SUM(cc.amountExcludingTax), 0) - COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100, 2) +
    ROUND(((SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(SUM(cc.amountExcludingTax), 0) + COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100, 2) as Total_Percentage_Check

FROM sales s
LEFT JOIN orders o ON s.consignmentId = o.consignmentId
LEFT JOIN carrierCosts cc ON o.consignmentId = cc.consignmentId
LEFT JOIN carrierCostRecoveries ccr ON o.consignmentId = ccr.consignmentId;

-- =====================================================
-- ALTERNATIVE: Show each component clearly
-- =====================================================

SELECT 
    'SALES BREAKDOWN - WHERE EVERY DOLLAR GOES' as Analysis,
    
    -- Show as percentages that should total 100%
    ROUND((SUM(s.costOfGoodsSold) / SUM(s.salesAmount)) * 100, 2) as 'COGS_%',
    ROUND(((SUM(s.units) * 5.47) / SUM(s.salesAmount)) * 100, 2) as 'Fulfillment_%',
    ROUND((COALESCE(SUM(cc.amountExcludingTax), 0) / SUM(s.salesAmount)) * 100, 2) as 'CarrierCost_%',
    ROUND((COALESCE(SUM(ccr.freightRecovery), 0) / SUM(s.salesAmount)) * 100, 2) as 'CarrierRecovery_%',
    ROUND(((SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(SUM(cc.amountExcludingTax), 0) + COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100, 2) as 'NetProfit_%',
    
    -- Total check
    ROUND((SUM(s.costOfGoodsSold) / SUM(s.salesAmount)) * 100, 2) +
    ROUND(((SUM(s.units) * 5.47) / SUM(s.salesAmount)) * 100, 2) +
    ROUND((COALESCE(SUM(cc.amountExcludingTax), 0) / SUM(s.salesAmount)) * 100, 2) -
    ROUND((COALESCE(SUM(ccr.freightRecovery), 0) / SUM(s.salesAmount)) * 100, 2) +
    ROUND(((SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(SUM(cc.amountExcludingTax), 0) + COALESCE(SUM(ccr.freightRecovery), 0)) / SUM(s.salesAmount)) * 100, 2) as 'Total_Should_Be_100%'

FROM sales s
LEFT JOIN orders o ON s.consignmentId = o.consignmentId
LEFT JOIN carrierCosts cc ON o.consignmentId = cc.consignmentId
LEFT JOIN carrierCostRecoveries ccr ON o.consignmentId = ccr.consignmentId;




