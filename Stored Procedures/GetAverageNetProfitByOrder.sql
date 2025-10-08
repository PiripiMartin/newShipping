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
    IN p_promotionId INT,
    IN p_originatingState CHAR(3),
    IN p_destinationState CHAR(3),
    IN p_destinationZoneCode VARCHAR(10),
    IN p_fromPostcode MEDIUMINT,
    IN p_toPostcode MEDIUMINT,
    IN p_postcodeDeliveryZoneDescription VARCHAR(50)
)
BEGIN
    -- Return only summary statistics
    SELECT 
        COUNT(*) as total_orders,
        SUM(total_units) as total_units,
        ROUND(SUM(total_units) / NULLIF(COUNT(*), 0), 2) as avg_units_per_order,
        COUNT(DISTINCT order_state) as number_of_originating_states,
        COUNT(DISTINCT from_postcode) as number_of_originating_postcodes,
        COUNT(DISTINCT destination_state) as number_of_delivery_states,
        COUNT(DISTINCT to_postcode) as number_of_delivery_postcodes,
        ROUND(SUM(shipped_cubic_m3), 4) as total_shipped_cubic_m3,
        ROUND(AVG(shipped_cubic_m3), 4) as avg_shipped_cubic_m3_per_order,
        ROUND(SUM(cubic_weight), 2) as total_cubic_weight_kg,
        ROUND(AVG(cubic_weight), 2) as avg_cubic_weight_per_order_kg,
        ROUND(SUM(billed_weight), 2) as total_billed_weight_kg,
        ROUND(AVG(billed_weight), 2) as avg_billed_weight_per_order_kg,
        
        -- Average percentages (by order)
        ROUND(AVG(gross_profit_pct), 2) as avg_gross_profit_percentage,
        ROUND(AVG(fulfillment_cost_pct), 2) as avg_fulfillment_cost_percentage,
        ROUND(AVG(net_carrier_cost_pct), 2) as avg_net_carrier_cost_percentage,
        ROUND(AVG(total_logistics_cost_pct), 2) as avg_total_logistics_cost_percentage,
        ROUND(AVG(net_profit_pct), 2) as avg_net_profit_percentage,
        ROUND(MIN(net_profit_pct), 2) as min_net_profit_percentage,
        ROUND(MAX(net_profit_pct), 2) as max_net_profit_percentage,
        
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
        
        -- Average Per Order Metrics
        ROUND(SUM(gross_sales) / NULLIF(COUNT(*), 0), 2) as avg_revenue_per_order,
        ROUND((SUM(total_cogs) + SUM(total_logistics_cost)) / NULLIF(COUNT(*), 0), 2) as avg_cost_per_order,
        ROUND(SUM(net_profit) / NULLIF(COUNT(*), 0), 2) as avg_net_profit_per_order,
        ROUND(SUM(net_carrier_cost) / NULLIF(COUNT(*), 0), 2) as avg_freight_cost_per_order,
        ROUND(SUM(freight_recovery) / NULLIF(COUNT(*), 0), 2) as avg_freight_recovery_per_order,
        
        -- Average Per Unit Metrics
        ROUND(SUM(gross_sales) / NULLIF(SUM(total_units), 0), 2) as avg_revenue_per_unit,
        ROUND((SUM(total_cogs) + SUM(total_logistics_cost)) / NULLIF(SUM(total_units), 0), 2) as avg_cost_per_unit,
        ROUND(SUM(net_profit) / NULLIF(SUM(total_units), 0), 2) as avg_net_profit_per_unit,
        ROUND(SUM(net_carrier_cost) / NULLIF(SUM(total_units), 0), 2) as avg_freight_cost_per_unit,
        ROUND(SUM(freight_recovery) / NULLIF(SUM(total_units), 0), 2) as avg_freight_recovery_per_unit
    
    FROM (
        SELECT 
            o.state as order_state,
            o.fromPostcode as from_postcode,
            o.toPostcode as to_postcode,
            dz.destinationZoneState as destination_state,
            SUM(s.units) as total_units,
            SUM(s.salesAmount) as gross_sales,
            -- Calculate cubic meters: (length * width * height) / 1,000,000 to convert cm³ to m³
            (COALESCE(MAX(cc.billedLength), 0) * COALESCE(MAX(cc.billedWidth), 0) * COALESCE(MAX(cc.billedHeight), 0)) as shipped_cubic_m3,
            COALESCE(MAX(cc.cubicWeight), 0) as cubic_weight,
            COALESCE(MAX(cc.billedWeight), 0) as billed_weight,
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
            AND (p_promotionId IS NULL OR o.promotionId = p_promotionId)
            AND (p_originatingState IS NULL OR o.state = p_originatingState)
            AND (p_destinationState IS NULL OR dz.destinationZoneState = p_destinationState)
            AND (p_destinationZoneCode IS NULL OR dz.destinationZoneCode = p_destinationZoneCode)
            AND (p_fromPostcode IS NULL OR o.fromPostcode = p_fromPostcode)
            AND (p_toPostcode IS NULL OR o.toPostcode = p_toPostcode)
            AND (p_postcodeDeliveryZoneDescription IS NULL OR dz.postcodeDeliveryZoneDescription = p_postcodeDeliveryZoneDescription)
        
        GROUP BY o.consignmentId
        HAVING SUM(s.salesAmount) > 0
    ) AS order_metrics;
    
END//

DELIMITER ;