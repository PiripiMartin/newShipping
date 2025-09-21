-- =====================================================
-- FIX ORPHANED CARRIER COSTS
-- =====================================================
-- Script to remove carrier costs that don't have matching orders
-- Run this AFTER running the diagnosis script

USE Shipping;

-- =====================================================
-- STEP 1: BACKUP COUNT BEFORE CLEANUP
-- =====================================================

SELECT 'BEFORE CLEANUP' as status;
SELECT COUNT(*) as total_carrier_costs_before FROM carrierCosts;
SELECT COUNT(*) as orphaned_records_before 
FROM carrierCosts cc
LEFT JOIN orders o ON cc.consignmentId = o.consignmentId
WHERE o.consignmentId IS NULL;

-- =====================================================
-- STEP 2: REMOVE ORPHANED CARRIER COSTS
-- =====================================================

-- Delete carrier costs that don't have matching orders
DELETE cc FROM carrierCosts cc
LEFT JOIN orders o ON cc.consignmentId = o.consignmentId
WHERE o.consignmentId IS NULL;

-- Get the number of deleted records
SELECT ROW_COUNT() as records_deleted;

-- =====================================================
-- STEP 3: VERIFY CLEANUP
-- =====================================================

SELECT 'AFTER CLEANUP' as status;
SELECT COUNT(*) as total_carrier_costs_after FROM carrierCosts;
SELECT COUNT(*) as orphaned_records_after 
FROM carrierCosts cc
LEFT JOIN orders o ON cc.consignmentId = o.consignmentId
WHERE o.consignmentId IS NULL;

-- =====================================================
-- STEP 4: RE-ENABLE FOREIGN KEY CONSTRAINT
-- =====================================================

-- Drop existing foreign key constraint if it exists
ALTER TABLE carrierCosts DROP FOREIGN KEY IF EXISTS fk_carrierCosts_consignmentId;

-- Recreate the foreign key constraint (this should now work without errors)
ALTER TABLE carrierCosts 
ADD CONSTRAINT fk_carrierCosts_consignmentId 
    FOREIGN KEY (consignmentId) 
    REFERENCES orders(consignmentId) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE;

-- =====================================================
-- STEP 5: FINAL VERIFICATION
-- =====================================================

SELECT 'FINAL VERIFICATION' as status;

-- Verify foreign key constraint exists
SELECT 
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE 
    TABLE_SCHEMA = 'Shipping' 
    AND TABLE_NAME = 'carrierCosts'
    AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Final counts
SELECT 
    (SELECT COUNT(*) FROM orders) as total_orders,
    (SELECT COUNT(*) FROM carrierCosts) as total_carrier_costs,
    (SELECT COUNT(*) FROM carrierCosts cc INNER JOIN orders o ON cc.consignmentId = o.consignmentId) as matching_records;

SELECT 'CLEANUP COMPLETED SUCCESSFULLY' as final_status;
