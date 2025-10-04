-- =====================================================
-- STORED PROCEDURE: GetLogisticsCost
-- =====================================================
-- Purpose: Calculate total logistics cost for an individual order
-- Parameters: 
--   - p_consignmentId: The consignment ID of the order
--   - p_orderDate: The order date to determine applicable cost rates
-- Returns: Total logistics cost for the order
-- 
-- Logic:
-- 1. Get total units across all sales for the order
-- 2. Get current fulfillment cost rates for the order date
-- 3. Calculate: (Total Units * DC Fixed Cost) + 
--              (Total Units * HO Online Fixed Cost) + 
--              (Total Units * Online Packaging Cost) + 
--              (Total Units * Online Labour Cost)
-- =====================================================

USE Shipping;

DELIMITER //

CREATE PROCEDURE GetLogisticsCost(
    IN p_consignmentId VARCHAR(20),
    OUT p_totalLogisticsCost DECIMAL(10,2)
)
BEGIN
    DECLARE v_totalUnits DECIMAL(10,2) DEFAULT 0;
    DECLARE v_dcFixedCost DECIMAL(8,2) DEFAULT 0;
    DECLARE v_hoOnlineFixedCost DECIMAL(8,2) DEFAULT 0;
    DECLARE v_packagingCost DECIMAL(8,2) DEFAULT 0;
    DECLARE v_labourCost DECIMAL(8,2) DEFAULT 0;
    DECLARE v_logisticsCost DECIMAL(10,2) DEFAULT 0;
    
    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_totalLogisticsCost = -1; -- Return -1 to indicate error
    END;
    
    -- Get total units for the order
    SELECT COALESCE(SUM(units), 0) INTO v_totalUnits
    FROM sales 
    WHERE consignmentId = p_consignmentId;
    
    -- If no sales found, return 0
    IF v_totalUnits = 0 THEN
        SET p_totalLogisticsCost = 0;
        LEAVE sp;
    END IF;
    
    -- Get all cost rates in one query (since rates are static for 2024)
    SELECT 
        COALESCE(MAX(CASE WHEN costCode = 'DCF' THEN costPerUOM END), 0),
        COALESCE(MAX(CASE WHEN costCode = 'HOF' THEN costPerUOM END), 0),
        COALESCE(MAX(CASE WHEN costCode = 'PAC' THEN costPerUOM END), 0),
        COALESCE(MAX(CASE WHEN costCode = 'LAB' THEN costPerUOM END), 0)
    INTO v_dcFixedCost, v_hoOnlineFixedCost, v_packagingCost, v_labourCost
    FROM fulfillmentCosts 
    WHERE costCode IN ('DCF', 'HOF', 'PAC', 'LAB');
    
    -- Calculate total logistics cost
    SET v_logisticsCost = (v_totalUnits * v_dcFixedCost) + 
                         (v_totalUnits * v_hoOnlineFixedCost) + 
                         (v_totalUnits * v_packagingCost) + 
                         (v_totalUnits * v_labourCost);
    
    SET p_totalLogisticsCost = v_logisticsCost;
    
    sp: BEGIN END; -- Label for LEAVE statement
    
END //

DELIMITER ;
