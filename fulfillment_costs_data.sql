-- =====================================================
-- FULFILLMENT COSTS DATA LOADING
-- =====================================================

USE Shipping;

-- Disable checks for faster loading
SET AUTOCOMMIT = 0;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;

-- Insert fulfillment costs data
INSERT INTO fulfillmentCosts (effectiveDateFrom, effectiveDateTo, costType, costCode, costDescription, allocationUOM, costPerUOM, allocationMethodology) VALUES
('2024-01-01', '2024-12-31', 'Fixed', 'DCF', 'DC Fixed Cost', 'Unit', 0.8, 'Per Unit'),
('2024-01-01', '2024-12-31', 'Fixed', 'HOF', 'HO Online Fixed Cost', 'Unit', 1.9, 'Per Unit'),
('2024-01-01', '2024-12-31', 'Variable', 'PAC', 'Online Packaging Cost', 'Unit', 0.34, 'Per Unit'),
('2024-01-01', '2024-12-31', 'Variable', 'LAB', 'Online Labour Cost', 'Unit', 2.43, 'Per Unit');

-- Re-enable checks
COMMIT;
SET AUTOCOMMIT = 1;
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;

-- Verify fulfillment costs count
SELECT COUNT(*) as total_fulfillment_costs FROM fulfillmentCosts;

-- Show fulfillment costs summary
SELECT costType, costCode, costDescription, costPerUOM FROM fulfillmentCosts ORDER BY costType, costCode;