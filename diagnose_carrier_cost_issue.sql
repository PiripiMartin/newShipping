-- =====================================================
-- DIAGNOSE CARRIER COST DATA INTEGRITY ISSUE
-- =====================================================
-- Script to identify and fix carrier costs that don't have matching orders

USE Shipping;

-- =====================================================
-- STEP 1: CHECK CURRENT COUNTS
-- =====================================================

SELECT 'CURRENT DATA COUNTS' as section;

SELECT 
    'orders' as table_name, 
    COUNT(*) as record_count 
FROM orders
UNION ALL
SELECT 
    'carrierCosts' as table_name, 
    COUNT(*) as record_count 
FROM carrierCosts;

-- =====================================================
-- STEP 2: CHECK FOREIGN KEY CONSTRAINTS
-- =====================================================

SELECT 'FOREIGN KEY CONSTRAINTS' as section;

SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE 
    TABLE_SCHEMA = 'Shipping' 
    AND TABLE_NAME = 'carrierCosts'
    AND REFERENCED_TABLE_NAME IS NOT NULL;

-- =====================================================
-- STEP 3: FIND ORPHANED CARRIER COSTS
-- =====================================================

SELECT 'ORPHANED CARRIER COSTS ANALYSIS' as section;

-- Count carrier costs that don't have matching orders
SELECT 
    COUNT(*) as orphaned_carrier_costs
FROM carrierCosts cc
LEFT JOIN orders o ON cc.consignmentId = o.consignmentId
WHERE o.consignmentId IS NULL;

-- Show sample orphaned carrier costs
SELECT 'Sample orphaned carrier costs:' as info;
SELECT 
    cc.consignmentId,
    cc.amountExcludingTax
FROM carrierCosts cc
LEFT JOIN orders o ON cc.consignmentId = o.consignmentId
WHERE o.consignmentId IS NULL
LIMIT 10;

-- =====================================================
-- STEP 4: ANALYZE CONSIGNMENT ID PATTERNS
-- =====================================================

SELECT 'CONSIGNMENT ID PATTERNS' as section;

-- Pattern analysis for orders
SELECT 
    'orders' as source,
    SUBSTRING(consignmentId, 1, 3) as id_prefix,
    COUNT(*) as count
FROM orders
GROUP BY SUBSTRING(consignmentId, 1, 3)
ORDER BY count DESC;

-- Pattern analysis for carrier costs
SELECT 
    'carrierCosts' as source,
    SUBSTRING(consignmentId, 1, 3) as id_prefix,
    COUNT(*) as count
FROM carrierCosts
GROUP BY SUBSTRING(consignmentId, 1, 3)
ORDER BY count DESC;

-- =====================================================
-- STEP 5: CHECK FOR EXACT MATCHES
-- =====================================================

SELECT 'MATCHING ANALYSIS' as section;

-- Count how many carrier costs have matching orders
SELECT 
    COUNT(*) as matching_carrier_costs
FROM carrierCosts cc
INNER JOIN orders o ON cc.consignmentId = o.consignmentId;

-- Count orders that have carrier costs
SELECT 
    COUNT(*) as orders_with_carrier_costs
FROM orders o
INNER JOIN carrierCosts cc ON o.consignmentId = cc.consignmentId;

-- =====================================================
-- STEP 6: SUMMARY REPORT
-- =====================================================

SELECT 'SUMMARY REPORT' as section;

SELECT 
    (SELECT COUNT(*) FROM orders) as total_orders,
    (SELECT COUNT(*) FROM carrierCosts) as total_carrier_costs,
    (SELECT COUNT(*) FROM carrierCosts cc INNER JOIN orders o ON cc.consignmentId = o.consignmentId) as matching_records,
    (SELECT COUNT(*) FROM carrierCosts cc LEFT JOIN orders o ON cc.consignmentId = o.consignmentId WHERE o.consignmentId IS NULL) as orphaned_carrier_costs,
    ROUND(
        (SELECT COUNT(*) FROM carrierCosts cc INNER JOIN orders o ON cc.consignmentId = o.consignmentId) * 100.0 / 
        (SELECT COUNT(*) FROM carrierCosts), 2
    ) as match_percentage;
