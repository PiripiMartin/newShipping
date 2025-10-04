-- =====================================================
-- STORED PROCEDURE: Get Average Net Profit by Order
-- =====================================================

USE Shipping;

DELIMITER //

DROP PROCEDURE IF EXISTS GetAverageNetProfitByOrder//

CREATE PROCEDURE GetAverageNetProfitByOrder(
    IN p_startDate DATE,
    IN p_endDate DATE,
    IN p_carrierName VARCHAR(100),
    IN p_styleCategoryName VARCHAR(25),
    IN p_promotionId INT,
    IN p_state CHAR(3),
    IN p_fromPostcode MEDIUMINT,
    IN p_toPostcode MEDIUMINT,
    IN p_stateClassification VARCHAR(50),
    IN p_stateArea VARCHAR(20),
    IN p_postcodeDeliveryZoneDescription VARCHAR(50)
)
BEGIN
    -- Return only summary statistics
    SELECT 
        COUNT(*) as total_orders,
        SUM(total_units) as total_units,
        
        -- Average percentages (by order)
        ROUND(AVG(gross_profit_pct), 2) as avg_gross_profit_percentage,
        ROUND(AVG(fulfillment_cost_pct), 2) as avg_fulfillment_cost_percentage,
        ROUND(AVG(net_carrier_cost_pct), 2) as avg_net_carrier_cost_percentage,
        ROUND(AVG(total_logistics_cost_pct), 2) as avg_total_logistics_cost_percentage,
        ROUND(AVG(net_profit_pct), 2) as avg_net_profit_percentage,
        
        -- Min/Max
        ROUND(MIN(net_profit_pct), 2) as min_net_profit_percentage,
        ROUND(MAX(net_profit_pct), 2) as max_net_profit_percentage,
        ROUND(STDDEV(net_profit_pct), 2) as stddev_net_profit_percentage,
        
        -- Dollar totals
        SUM(gross_sales) as total_gross_sales,
        SUM(total_cogs) as total_cogs,
        SUM(gross_profit) as total_gross_profit,
        SUM(fulfillment_cost) as total_fulfillment_cost,
        SUM(carrier_cost) as total_carrier_cost,
        SUM(freight_recovery) as total_freight_recovery,
        SUM(net_carrier_cost) as total_net_carrier_cost,
        SUM(total_logistics_cost) as total_logistics_cost,
        SUM(net_profit) as total_net_profit,
        
        -- Overall percentages (all orders combined - for comparison)
        ROUND((SUM(gross_profit) / NULLIF(SUM(gross_sales), 0)) * 100, 2) as overall_gross_profit_pct,
        ROUND((SUM(total_logistics_cost) / NULLIF(SUM(gross_sales), 0)) * 100, 2) as overall_logistics_cost_pct,
        ROUND((SUM(net_profit) / NULLIF(SUM(gross_sales), 0)) * 100, 2) as overall_net_profit_pct,
        
        -- Profit distribution
        SUM(CASE WHEN net_profit_pct < 0 THEN 1 ELSE 0 END) as orders_with_negative_profit,
        SUM(CASE WHEN net_profit_pct >= 0 AND net_profit_pct < 10 THEN 1 ELSE 0 END) as orders_0_to_10_pct,
        SUM(CASE WHEN net_profit_pct >= 10 AND net_profit_pct < 20 THEN 1 ELSE 0 END) as orders_10_to_20_pct,
        SUM(CASE WHEN net_profit_pct >= 20 AND net_profit_pct < 30 THEN 1 ELSE 0 END) as orders_20_to_30_pct,
        SUM(CASE WHEN net_profit_pct >= 30 THEN 1 ELSE 0 END) as orders_over_30_pct
    
    FROM (
        SELECT 
            SUM(s.units) as total_units,
            SUM(s.salesAmount) as gross_sales,
            SUM(s.costOfGoodsSold) as total_cogs,
            SUM(s.salesAmount - s.costOfGoodsSold) as gross_profit,
            SUM(s.units) * 5.47 as fulfillment_cost,
            COALESCE(MAX(cc.amountExcludingTax), 0) as carrier_cost,
            COALESCE(MAX(ccr.freightRecovery), 0) as freight_recovery,
            (COALESCE(MAX(cc.amountExcludingTax), 0) - COALESCE(MAX(ccr.freightRecovery), 0)) as net_carrier_cost,
            (SUM(s.units) * 5.47 + COALESCE(MAX(cc.amountExcludingTax), 0) - COALESCE(MAX(ccr.freightRecovery), 0)) as total_logistics_cost,
            (SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(MAX(cc.amountExcludingTax), 0) + COALESCE(MAX(ccr.freightRecovery), 0)) as net_profit,
            
            ROUND(((SUM(s.salesAmount) - SUM(s.costOfGoodsSold)) / NULLIF(SUM(s.salesAmount), 0)) * 100, 2) as gross_profit_pct,
            ROUND(((SUM(s.units) * 5.47) / NULLIF(SUM(s.salesAmount), 0)) * 100, 2) as fulfillment_cost_pct,
            ROUND(((COALESCE(MAX(cc.amountExcludingTax), 0) - COALESCE(MAX(ccr.freightRecovery), 0)) / NULLIF(SUM(s.salesAmount), 0)) * 100, 2) as net_carrier_cost_pct,
            ROUND(((SUM(s.units) * 5.47 + COALESCE(MAX(cc.amountExcludingTax), 0) - COALESCE(MAX(ccr.freightRecovery), 0)) / NULLIF(SUM(s.salesAmount), 0)) * 100, 2) as total_logistics_cost_pct,
            ROUND(((SUM(s.salesAmount) - SUM(s.costOfGoodsSold) - (SUM(s.units) * 5.47) - COALESCE(MAX(cc.amountExcludingTax), 0) + COALESCE(MAX(ccr.freightRecovery), 0)) / NULLIF(SUM(s.salesAmount), 0)) * 100, 2) as net_profit_pct
        
        FROM orders o
        INNER JOIN sales s ON o.consignmentId = s.consignmentId
        INNER JOIN services sv ON o.serviceId = sv.serviceId
        INNER JOIN carriers c ON sv.carrierId = c.carrierId
        LEFT JOIN promotions p ON o.promotionId = p.promotionId
        LEFT JOIN deliveryZones dz ON o.toPostcode = dz.postcode
        LEFT JOIN carrierCosts cc ON o.consignmentId = cc.consignmentId
        LEFT JOIN carrierCostRecoveries ccr ON o.consignmentId = ccr.consignmentId
        
        WHERE 1=1
            AND (p_startDate IS NULL OR o.orderDate >= p_startDate)
            AND (p_endDate IS NULL OR o.orderDate <= p_endDate)
            AND (p_carrierName IS NULL OR c.carrierName = p_carrierName)
            AND (p_styleCategoryName IS NULL OR s.styleCategoryName = p_styleCategoryName)
            AND (p_promotionId IS NULL OR o.promotionId = p_promotionId)
            AND (p_state IS NULL OR o.state = p_state)
            AND (p_fromPostcode IS NULL OR o.fromPostcode = p_fromPostcode)
            AND (p_toPostcode IS NULL OR o.toPostcode = p_toPostcode)
            AND (p_stateClassification IS NULL OR dz.stateClassification = p_stateClassification)
            AND (p_stateArea IS NULL OR dz.stateArea = p_stateArea)
            AND (p_postcodeDeliveryZoneDescription IS NULL OR dz.postcodeDeliveryZoneDescription = p_postcodeDeliveryZoneDescription)
        
        GROUP BY o.consignmentId
        HAVING SUM(s.salesAmount) > 0
    ) AS order_metrics;
    
END//

DELIMITER ;