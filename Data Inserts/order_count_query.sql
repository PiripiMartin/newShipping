-- =====================================================
-- ORDER COUNT QUERY WITH FLEXIBLE FILTERS
-- =====================================================
-- Query to get total order count with various filter options

USE Shipping;

-- Basic query with all possible filters (customize as needed)
SELECT COUNT(*) as total_orders
FROM orders o
INNER JOIN services s ON o.serviceId = s.serviceId
INNER JOIN carriers c ON s.carrierId = c.carrierId
LEFT JOIN promotions p ON o.promotionId = p.promotionId
LEFT JOIN deliveryZones dz ON o.toPostcode = dz.postcode
WHERE 1=1
    -- Date range filter (uncomment and modify dates as needed)
    -- AND o.orderDate >= '2024-01-01'
    -- AND o.orderDate <= '2024-12-31'
    
    -- Carrier name filter (uncomment and modify carrier name as needed)
    -- AND c.carrierName = 'Australia Post'
    
    -- Promotion filter (uncomment and modify promotion description as needed)
    -- AND p.promotionDescription LIKE '%Christmas%'
    
    -- State filter (uncomment and modify state as needed)
    -- AND o.state = 'VIC'
    
    -- Postcode filter (uncomment and modify postcode as needed)
    -- AND o.toPostcode = 3029
    
    -- Postcode range filter (uncomment and modify range as needed)
    -- AND o.toPostcode BETWEEN 3000 AND 3999
;

-- =====================================================
-- EXAMPLE QUERIES WITH SPECIFIC FILTERS
-- =====================================================

-- Example 1: Orders in December 2024 from Australia Post to VIC
SELECT 
    COUNT(*) as order_count,
    'December 2024 Australia Post orders to VIC' as description
FROM orders o
INNER JOIN services s ON o.serviceId = s.serviceId
INNER JOIN carriers c ON s.carrierId = c.carrierId
WHERE o.orderDate >= '2024-12-01'
    AND o.orderDate <= '2024-12-31'
    AND c.carrierName = 'Australia Post'
    AND o.state = 'VIC';

-- Example 2: Orders with promotions in Q4 2024
SELECT 
    COUNT(*) as order_count,
    'Q4 2024 orders with promotions' as description
FROM orders o
INNER JOIN promotions p ON o.promotionId = p.promotionId
WHERE o.orderDate >= '2024-10-01'
    AND o.orderDate <= '2024-12-31';

-- Example 3: Orders to Melbourne postcodes (3000-3999)
SELECT 
    COUNT(*) as order_count,
    'Orders to Melbourne postcodes (3000-3999)' as description
FROM orders o
WHERE o.toPostcode BETWEEN 3000 AND 3999;

-- Example 4: Orders by Express service in November 2024
SELECT 
    COUNT(*) as order_count,
    'Express service orders in November 2024' as description
FROM orders o
INNER JOIN services s ON o.serviceId = s.serviceId
WHERE o.orderDate >= '2024-11-01'
    AND o.orderDate <= '2024-11-30'
    AND s.carrierService = 'Express';

-- =====================================================
-- DETAILED BREAKDOWN QUERY
-- =====================================================
-- Get order counts with breakdown by multiple dimensions

SELECT 
    c.carrierName,
    s.carrierService,
    o.state,
    CASE 
        WHEN o.toPostcode BETWEEN 1000 AND 1999 THEN 'NSW'
        WHEN o.toPostcode BETWEEN 2000 AND 2999 THEN 'NSW'
        WHEN o.toPostcode BETWEEN 3000 AND 3999 THEN 'VIC'
        WHEN o.toPostcode BETWEEN 4000 AND 4999 THEN 'QLD'
        WHEN o.toPostcode BETWEEN 5000 AND 5999 THEN 'SA'
        WHEN o.toPostcode BETWEEN 6000 AND 6999 THEN 'WA'
        WHEN o.toPostcode BETWEEN 7000 AND 7999 THEN 'TAS'
        ELSE 'Other'
    END as postcode_region,
    COUNT(*) as order_count,
    MIN(o.orderDate) as earliest_order,
    MAX(o.orderDate) as latest_order
FROM orders o
INNER JOIN services s ON o.serviceId = s.serviceId
INNER JOIN carriers c ON s.carrierId = c.carrierId
WHERE 1=1
    -- Add your filters here
    -- AND o.orderDate >= '2024-01-01'
    -- AND c.carrierName = 'Australia Post'
GROUP BY c.carrierName, s.carrierService, o.state, postcode_region
ORDER BY order_count DESC;

-- =====================================================
-- PARAMETERIZED QUERY TEMPLATE
-- =====================================================
-- Template for building dynamic queries with parameters

/*
-- Replace @param values with actual values or use prepared statements

SET @start_date = '2024-01-01';
SET @end_date = '2024-12-31';
SET @carrier_name = 'Australia Post';
SET @state_filter = 'VIC';
SET @min_postcode = 3000;
SET @max_postcode = 3999;

SELECT COUNT(*) as total_orders
FROM orders o
INNER JOIN services s ON o.serviceId = s.serviceId
INNER JOIN carriers c ON s.carrierId = c.carrierId
WHERE 1=1
    AND (@start_date IS NULL OR o.orderDate >= @start_date)
    AND (@end_date IS NULL OR o.orderDate <= @end_date)
    AND (@carrier_name IS NULL OR c.carrierName = @carrier_name)
    AND (@state_filter IS NULL OR o.state = @state_filter)
    AND (@min_postcode IS NULL OR o.toPostcode >= @min_postcode)
    AND (@max_postcode IS NULL OR o.toPostcode <= @max_postcode);
*/
