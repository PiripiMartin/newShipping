-- =====================================================
-- COMPLETE PROFIT ANALYSIS BY ORDER
-- =====================================================
-- All metrics aggregated by order first, then averaged
-- Logistics costs = Internal fulfillment (5.47 per unit) + Carrier costs - Carrier cost recoveries

USE Shipping;

-- =====================================================
-- PROFIT METRICS BY ORDER
-- =====================================================
-- This creates a detailed view of each order's profitability
CREATE OR REPLACE VIEW order_profit_metrics AS
SELECT 
    o.consignmentId,
    o.orderDate,
    o.orderNo,
    o.serviceId,
    o.promotionId,
    o.state,
    o.fromPostcode,
    o.toPostcode,
    
    -- Sales metrics
    SUM(s.salesAmount) as gross_sales,
    SUM(s.costOfGoodsSold) as total_cogs,
    SUM(s.units) as total_units,
    
    -- Gross profit
    (SUM(s.salesAmount) - SUM(s.costOfGoodsSold)) as gross_profit,
    
    -- Logistics costs
    SUM(s.units) * 5.47 as fulfillment_cost,
    COALESCE(cc.amountExcludingTax, 0) as carrier_cost,
    COALESCE(ccr.freightRecovery, 0) as freight_recovery,
    (COALESCE(cc.amountExcludingTax, 0) - COALESCE(ccr.freightRecovery, 0)) as net_carrier_cost,
    (SUM(s.units) * 5.47 + COALESCE(cc.amountExcludingTax, 0) - COALESCE(ccr.freightRecovery, 0)) as total_logistics_cost,
    
    -- Net sales and net profit
    (SUM(s.salesAmount) - COALESCE(ccr.freightRecovery, 0)) as net_sales,
    (SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(cc.amountExcludingTax, 0) + COALESCE(ccr.freightRecovery, 0)) as net_profit,
    
    -- Percentages
    ROUND(
        CASE 
            WHEN SUM(s.salesAmount) = 0 THEN 0
            ELSE ((SUM(s.salesAmount) - SUM(s.costOfGoodsSold)) / SUM(s.salesAmount)) * 100
        END, 
        2
    ) as gross_profit_percentage,
    
    ROUND(
        CASE 
            WHEN SUM(s.salesAmount) = 0 THEN 0
            ELSE ((SUM(s.units) * 5.47) / SUM(s.salesAmount)) * 100
        END, 
        2
    ) as fulfillment_cost_percentage,
    
    ROUND(
        CASE 
            WHEN SUM(s.salesAmount) = 0 THEN 0
            ELSE ((COALESCE(cc.amountExcludingTax, 0) - COALESCE(ccr.freightRecovery, 0)) / SUM(s.salesAmount)) * 100
        END, 
        2
    ) as net_carrier_cost_percentage,
    
    ROUND(
        CASE 
            WHEN SUM(s.salesAmount) = 0 THEN 0
            ELSE ((SUM(s.units) * 5.47 + COALESCE(cc.amountExcludingTax, 0) - COALESCE(ccr.freightRecovery, 0)) / SUM(s.salesAmount)) * 100
        END, 
        2
    ) as total_logistics_cost_percentage,
    
    ROUND(
        CASE 
            WHEN SUM(s.salesAmount) = 0 THEN 0
            ELSE ((SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(cc.amountExcludingTax, 0) + COALESCE(ccr.freightRecovery, 0)) / SUM(s.salesAmount)) * 100
        END, 
        2
    ) as net_profit_percentage

FROM orders o
JOIN sales s ON o.consignmentId = s.consignmentId
LEFT JOIN carrierCosts cc ON o.consignmentId = cc.consignmentId
LEFT JOIN carrierCostRecoveries ccr ON o.consignmentId = ccr.consignmentId
GROUP BY o.consignmentId, o.orderDate, o.orderNo, o.serviceId, o.promotionId, o.state, o.fromPostcode, o.toPostcode, cc.amountExcludingTax, ccr.freightRecovery;

-- =====================================================
-- AVERAGE METRICS ACROSS ALL ORDERS
-- =====================================================
SELECT 
    'AVERAGE BY ORDER' as Analysis,
    COUNT(*) as total_orders,
    
    -- Average percentages (aggregated by order first)
    ROUND(AVG(gross_profit_percentage), 2) as avg_gross_profit_percentage,
    ROUND(AVG(fulfillment_cost_percentage), 2) as avg_fulfillment_cost_percentage,
    ROUND(AVG(net_carrier_cost_percentage), 2) as avg_net_carrier_cost_percentage,
    ROUND(AVG(total_logistics_cost_percentage), 2) as avg_total_logistics_cost_percentage,
    ROUND(AVG(net_profit_percentage), 2) as avg_net_profit_percentage,
    
    -- Min/Max percentages
    ROUND(MIN(net_profit_percentage), 2) as min_net_profit_percentage,
    ROUND(MAX(net_profit_percentage), 2) as max_net_profit_percentage,
    
    -- Total dollar amounts
    SUM(gross_sales) as total_gross_sales,
    SUM(net_sales) as total_net_sales,
    SUM(total_cogs) as total_cogs,
    SUM(gross_profit) as total_gross_profit,
    SUM(fulfillment_cost) as total_fulfillment_cost,
    SUM(net_carrier_cost) as total_net_carrier_cost,
    SUM(total_logistics_cost) as total_logistics_cost,
    SUM(net_profit) as total_net_profit
    
FROM order_profit_metrics;

-- =====================================================
-- DISTRIBUTION OF PROFIT PERCENTAGES
-- =====================================================
SELECT 
    'Profit Distribution' as Analysis,
    SUM(CASE WHEN net_profit_percentage < 0 THEN 1 ELSE 0 END) as negative_profit_orders,
    SUM(CASE WHEN net_profit_percentage BETWEEN 0 AND 10 THEN 1 ELSE 0 END) as profit_0_to_10_pct,
    SUM(CASE WHEN net_profit_percentage BETWEEN 10 AND 20 THEN 1 ELSE 0 END) as profit_10_to_20_pct,
    SUM(CASE WHEN net_profit_percentage BETWEEN 20 AND 30 THEN 1 ELSE 0 END) as profit_20_to_30_pct,
    SUM(CASE WHEN net_profit_percentage BETWEEN 30 AND 40 THEN 1 ELSE 0 END) as profit_30_to_40_pct,
    SUM(CASE WHEN net_profit_percentage >= 40 THEN 1 ELSE 0 END) as profit_over_40_pct
FROM order_profit_metrics;

-- =====================================================
-- TOP 20 MOST PROFITABLE ORDERS
-- =====================================================
SELECT 
    consignmentId,
    orderDate,
    gross_sales,
    net_profit,
    net_profit_percentage
FROM order_profit_metrics
ORDER BY net_profit DESC
LIMIT 20;

-- =====================================================
-- TOP 20 LEAST PROFITABLE ORDERS (Biggest Losses)
-- =====================================================
SELECT 
    consignmentId,
    orderDate,
    gross_sales,
    net_profit,
    net_profit_percentage
FROM order_profit_metrics
ORDER BY net_profit ASC
LIMIT 20;

-- =====================================================
-- PROFIT ANALYSIS BY PROMOTION
-- =====================================================
SELECT 
    COALESCE(CAST(opm.promotionId AS CHAR), 'No Promotion') as promotion,
    COUNT(*) as order_count,
    ROUND(AVG(opm.net_profit_percentage), 2) as avg_net_profit_pct,
    SUM(opm.gross_sales) as total_sales,
    SUM(opm.net_profit) as total_net_profit
FROM order_profit_metrics opm
GROUP BY opm.promotionId
ORDER BY avg_net_profit_pct DESC;

-- =====================================================
-- PROFIT ANALYSIS BY SERVICE TYPE
-- =====================================================
SELECT 
    opm.serviceId,
    COUNT(*) as order_count,
    ROUND(AVG(opm.net_profit_percentage), 2) as avg_net_profit_pct,
    ROUND(AVG(opm.net_carrier_cost_percentage), 2) as avg_carrier_cost_pct,
    SUM(opm.gross_sales) as total_sales,
    SUM(opm.net_profit) as total_net_profit
FROM order_profit_metrics opm
GROUP BY opm.serviceId
ORDER BY avg_net_profit_pct DESC;

