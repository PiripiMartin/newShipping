-- =====================================================
-- FUNCTION: GetGrossProfitPercentage
-- =====================================================
-- Purpose: Calculate overall gross profit percentage across all sales
-- Returns: Gross profit percentage as DECIMAL(5,2)
-- Formula: ((Total Sales - Total COGS) / Total Sales) * 100
-- =====================================================

USE Shipping;

DELIMITER //

CREATE FUNCTION GetGrossProfitPercentage() 
RETURNS DECIMAL(5,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_salesSum DECIMAL(15,2) DEFAULT 0;
    DECLARE v_cogsSum DECIMAL(15,2) DEFAULT 0;
    DECLARE v_grossProfitPercentage DECIMAL(5,2) DEFAULT 0;
    
    -- Get total sales amount and total cost of goods sold
    SELECT 
        COALESCE(SUM(salesAmount), 0),
        COALESCE(SUM(costOfGoodsSold), 0)
    INTO v_salesSum, v_cogsSum
    FROM sales;
    
    -- Avoid division by zero
    IF v_salesSum = 0 THEN
        RETURN 0;
    END IF;
    
    -- Calculate gross profit percentage
    SET v_grossProfitPercentage = ((v_salesSum - v_cogsSum) / v_salesSum) * 100;
    
    RETURN v_grossProfitPercentage;
    
END //

DELIMITER ;

-- =====================================================
-- USAGE EXAMPLES
-- =====================================================

-- Example 1: Get overall gross profit percentage
-- SELECT GetGrossProfitPercentage() as GrossProfitPercentage;

-- Example 2: Get gross profit percentage with additional context
-- SELECT 
--     GetGrossProfitPercentage() as GrossProfitPercentage,
--     SUM(salesAmount) as TotalSales,
--     SUM(costOfGoodsSold) as TotalCOGS,
--     (SUM(salesAmount) - SUM(costOfGoodsSold)) as GrossProfit
-- FROM sales;