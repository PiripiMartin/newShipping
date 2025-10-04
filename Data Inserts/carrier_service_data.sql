-- =====================================================
-- CARRIER AND SERVICE DATA LOADING
-- =====================================================

USE Shipping;

-- Disable checks for faster loading
SET AUTOCOMMIT = 0;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;

-- Insert carrier data
INSERT INTO carriers (carrierName, carrierGroup, transportAddress, transportContactName, transportContactTitle, transportContactPhone, transportContactEmail) VALUES
('Australia Post', 'Aus_Post', '480 Swan St, Richmond, VIC, 3121', 'Rob Podnar', 'Account Manager - Parcel, Post & eCommerce Services', '+61 409 181 468', 'Rob.Podnar@auspost.com.au'),
('Rendr', 'Rendr', NULL, NULL, NULL, NULL, NULL),
('Team Global Express', 'TFE', NULL, NULL, NULL, NULL, NULL),
('Unknown', 'Other', NULL, NULL, NULL, NULL, NULL);

-- Insert service data
INSERT INTO services (serviceId, carrierService, carrierId) VALUES
('APE', 'Express', 1),
('X4B', 'Standard', 1),
('ID25', 'ID25', 1),
('005', 'Standard', 3),
('RDR', 'Standard', 2),
('AUS', 'Unknown', 4),
('CHCK', 'Unknown', 4),
('CP', 'Unknown', 4),
('EXP', 'Unknown', 4),
('HE', 'Unknown', 4),
('PICK', 'Unknown', 4),
('STD', 'Unknown', 4);

-- Re-enable checks
COMMIT;
SET AUTOCOMMIT = 1;
SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;

-- Verify counts
SELECT COUNT(*) as total_carriers FROM carriers;
SELECT COUNT(*) as total_services FROM services;