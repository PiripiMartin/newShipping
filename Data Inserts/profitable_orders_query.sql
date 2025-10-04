-- =====================================================
-- PROFITABLE ORDERS QUERY
-- =====================================================
-- Query to get all orders that are profitable (profit > 0)

USE Shipping;

-- =====================================================
-- BASIC PROFITABLE ORDERS QUERY
-- =====================================================
-- Get all orders with positive profit

SELECT 
    o.consignmentId,
    o.orderDate,
    o.orderNo,
    o.state,
    o.toPostcode,
    c.carrierName,
    s.carrierService,
    p.promotionDescription,
    SUM(sa.salesAmount) as total_sales,
    SUM(sa.costOfGoodsSold) as total_cogs,
    SUM(sa.salesAmount - sa.costOfGoodsSold) as profit,
    COUNT(sa.saleId) as item_count
FROM orders o
INNER JOIN sales sa ON o.consignmentId = sa.consignmentId
INNER JOIN services s ON o.serviceId = s.serviceId
INNER JOIN carriers c ON s.carrierId = c.carrierId
LEFT JOIN promotions p ON o.promotionId = p.promotionId
GROUP BY 
    o.consignmentId, 
    o.orderDate, 
    o.orderNo, 
    o.state, 
    o.toPostcode, 
    c.carrierName, 
    s.carrierService, 
    p.promotionDescription
HAVING SUM(sa.salesAmount - sa.costOfGoodsSold) > 0
ORDER BY profit DESC;

-- =====================================================
-- PROFITABLE ORDERS WITH COSTS INCLUDED
-- =====================================================
-- Get profitable orders including carrier costs and recoveries

SELECT 
    o.consignmentId,
    o.orderDate,
    o.orderNo,
    o.state,
    o.toPostcode,
    c.carrierName,
    s.carrierService,
    -- Sales metrics
    SUM(sa.salesAmount) as total_sales,
    SUM(sa.costOfGoodsSold) as total_cogs,
    SUM(sa.salesAmount - sa.costOfGoodsSold) as gross_profit,
    
    -- Carrier costs
    COALESCE(cc.amountExcludingTax, 0) as carrier_cost,
    COALESCE(ccr.freightRecovery, 0) as freight_recovery,
    
    -- Net profit calculation
    (SUM(sa.salesAmount - sa.costOfGoodsSold) 
     - COALESCE(cc.amountExcludingTax, 0) 
     + COALESCE(ccr.freightRecovery, 0)) as net_profit,
    
    COUNT(sa.saleId) as item_count
FROM orders o
INNER JOIN sales sa ON o.consignmentId = sa.consignmentId
INNER JOIN services s ON o.serviceId = s.serviceId
INNER JOIN carriers c ON s.carrierId = c.carrierId
LEFT JOIN promotions p ON o.promotionId = p.promotionId
LEFT JOIN carrierCosts cc ON o.consignmentId = cc.consignmentId
LEFT JOIN carrierCostRecoveries ccr ON o.consignmentId = ccr.consignmentId
GROUP BY 
    o.consignmentId, 
    o.orderDate, 
    o.orderNo, 
    o.state, 
    o.toPostcode, 
    c.carrierName, 
    s.carrierService,
    cc.amountExcludingTax,
    ccr.freightRecovery
HAVING (SUM(sa.salesAmount - sa.costOfGoodsSold) 
        - COALESCE(cc.amountExcludingTax, 0) 
        + COALESCE(ccr.freightRecovery, 0)) > 0
ORDER BY net_profit DESC;

-- =====================================================
-- PROFITABLE ORDERS SUMMARY BY CATEGORY
-- =====================================================
-- Summary of profitable orders grouped by different dimensions

-- By Carrier
SELECT 
    c.carrierName,
    s.carrierService,
    COUNT(DISTINCT o.consignmentId) as profitable_order_count,
    SUM(sa.salesAmount) as total_sales,
    SUM(sa.costOfGoodsSold) as total_cogs,
    SUM(sa.salesAmount - sa.costOfGoodsSold) as total_profit,
    AVG(sa.salesAmount - sa.costOfGoodsSold) as avg_profit_per_item,
    ROUND(SUM(sa.salesAmount - sa.costOfGoodsSold) / COUNT(DISTINCT o.consignmentId), 2) as avg_profit_per_order
FROM orders o
INNER JOIN sales sa ON o.consignmentId = sa.consignmentId
INNER JOIN services s ON o.serviceId = s.serviceId
INNER JOIN carriers c ON s.carrierId = c.carrierId
GROUP BY c.carrierName, s.carrierService
HAVING SUM(sa.salesAmount - sa.costOfGoodsSold) > 0
ORDER BY total_profit DESC;

-- By State
SELECT 
    o.state,
    COUNT(DISTINCT o.consignmentId) as profitable_order_count,
    SUM(sa.salesAmount) as total_sales,
    SUM(sa.costOfGoodsSold) as total_cogs,
    SUM(sa.salesAmount - sa.costOfGoodsSold) as total_profit,
    ROUND(SUM(sa.salesAmount - sa.costOfGoodsSold) / COUNT(DISTINCT o.consignmentId), 2) as avg_profit_per_order
FROM orders o
INNER JOIN sales sa ON o.consignmentId = sa.consignmentId
GROUP BY o.state
HAVING SUM(sa.salesAmount - sa.costOfGoodsSold) > 0
ORDER BY total_profit DESC;

-- By Month
SELECT 
    DATE_FORMAT(o.orderDate, '%Y-%m') as order_month,
    COUNT(DISTINCT o.consignmentId) as profitable_order_count,
    SUM(sa.salesAmount) as total_sales,
    SUM(sa.costOfGoodsSold) as total_cogs,
    SUM(sa.salesAmount - sa.costOfGoodsSold) as total_profit,
    ROUND(SUM(sa.salesAmount - sa.costOfGoodsSold) / COUNT(DISTINCT o.consignmentId), 2) as avg_profit_per_order
FROM orders o
INNER JOIN sales sa ON o.consignmentId = sa.consignmentId
GROUP BY DATE_FORMAT(o.orderDate, '%Y-%m')
HAVING SUM(sa.salesAmount - sa.costOfGoodsSold) > 0
ORDER BY order_month;

-- =====================================================
-- HIGH PROFIT ORDERS (PROFIT > $50)
-- =====================================================
-- Focus on orders with significant profit

SELECT 
    o.consignmentId,
    o.orderDate,
    o.state,
    o.toPostcode,
    c.carrierName,
    s.carrierService,
    p.promotionDescription,
    SUM(sa.salesAmount) as total_sales,
    SUM(sa.costOfGoodsSold) as total_cogs,
    SUM(sa.salesAmount - sa.costOfGoodsSold) as profit,
    ROUND((SUM(sa.salesAmount - sa.costOfGoodsSold) / SUM(sa.salesAmount)) * 100, 2) as profit_margin_percent,
    COUNT(sa.saleId) as item_count
FROM orders o
INNER JOIN sales sa ON o.consignmentId = sa.consignmentId
INNER JOIN services s ON o.serviceId = s.serviceId
INNER JOIN carriers c ON s.carrierId = c.carrierId
LEFT JOIN promotions p ON o.promotionId = p.promotionId
GROUP BY 
    o.consignmentId, 
    o.orderDate, 
    o.state, 
    o.toPostcode, 
    c.carrierName, 
    s.carrierService, 
    p.promotionDescription
HAVING SUM(sa.salesAmount - sa.costOfGoodsSold) > 50
ORDER BY profit DESC
LIMIT 100;

-- =====================================================
-- PROFITABLE ORDERS COUNT BY PROFIT RANGES
-- =====================================================
-- Distribution of profitable orders by profit ranges

SELECT 
    CASE 
        WHEN profit BETWEEN 0.01 AND 10 THEN '$0.01 - $10'
        WHEN profit BETWEEN 10.01 AND 25 THEN '$10.01 - $25'
        WHEN profit BETWEEN 25.01 AND 50 THEN '$25.01 - $50'
        WHEN profit BETWEEN 50.01 AND 100 THEN '$50.01 - $100'
        WHEN profit BETWEEN 100.01 AND 250 THEN '$100.01 - $250'
        WHEN profit > 250 THEN 'Over $250'
    END as profit_range,
    COUNT(*) as order_count,
    SUM(profit) as total_profit,
    AVG(profit) as avg_profit
FROM (
    SELECT 
        o.consignmentId,
        SUM(sa.salesAmount - sa.costOfGoodsSold) as profit
    FROM orders o
    INNER JOIN sales sa ON o.consignmentId = sa.consignmentId
    GROUP BY o.consignmentId
    HAVING SUM(sa.salesAmount - sa.costOfGoodsSold) > 0
) profitable_orders
GROUP BY profit_range
ORDER BY MIN(profit);
