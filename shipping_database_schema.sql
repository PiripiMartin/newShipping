-- Create database
USE Shipping;

-- =====================================================
-- ORDERS TABLE
-- =====================================================
-- Primary table containing order information
-- consignmentId serves as the primary key

-- =====================================================
-- CARRIERS TABLE
-- =====================================================
-- Table containing carrier company information
-- carrierId serves as the primary key

CREATE TABLE carriers (
    carrierId INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Auto-generated unique carrier ID',
    carrierName VARCHAR(100) NOT NULL COMMENT 'Name of the carrier company',
    carrierGroup VARCHAR(50) NOT NULL COMMENT 'Group classification of the carrier',
    transportAddress TEXT COMMENT 'Physical address of the transport facility',
    transportContactName VARCHAR(100) COMMENT 'Name of the transport contact person',
    transportContactTitle VARCHAR(150) COMMENT 'Job title of the transport contact person',
    transportContactPhone VARCHAR(20) COMMENT 'Phone number of the transport contact',
    transportContactEmail VARCHAR(100) COMMENT 'Email address of the transport contact',
    
    -- Indexes for performance
    INDEX idx_carrierName (carrierName),
    INDEX idx_carrierGroup (carrierGroup)
);

-- =====================================================
-- SERVICES TABLE
-- =====================================================
-- Table containing service information linked to carriers
-- serviceId serves as the primary key

CREATE TABLE services (
    serviceId VARCHAR(10) NOT NULL PRIMARY KEY COMMENT 'Service ID code (e.g., APE, X4B)',
    carrierService VARCHAR(50) NOT NULL COMMENT 'Name/type of the carrier service',
    carrierId INT UNSIGNED NOT NULL COMMENT 'Foreign key linking to carrier table',
    
    -- Foreign key constraint
    CONSTRAINT fk_service_carrierId 
        FOREIGN KEY (carrierId) 
        REFERENCES carriers(carrierId) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Indexes for performance
    INDEX idx_carrierService (carrierService),
    INDEX idx_carrierId (carrierId)
);

-- =====================================================
-- PROMOTIONS TABLE
-- =====================================================
-- Table containing promotion information
-- promotionId serves as the primary key

CREATE TABLE promotions (
    promotionId INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Auto-generated unique promotion ID',
    promotionDescription TEXT NOT NULL COMMENT 'Description of the promotion',
    startDate DATE NOT NULL COMMENT 'Start date of the promotion',
    endDate DATE NOT NULL COMMENT 'End date of the promotion',
    calendarYear YEAR NOT NULL COMMENT 'Calendar year',
    financialYear YEAR NOT NULL COMMENT 'Financial year',

    -- Check constraints to ensure data quality
    CONSTRAINT chk_promotion_dates CHECK (endDate >= startDate),
    
    -- Indexes for performance
    INDEX idx_startDate (startDate),
    INDEX idx_endDate (endDate),
    INDEX idx_calendarYear (calendarYear),
    INDEX idx_financialYear (financialYear)
);

CREATE TABLE orders (
    consignmentId VARCHAR(20) NOT NULL PRIMARY KEY COMMENT 'Unique consignment ID - primary key',
    orderDate DATE NOT NULL COMMENT 'Date when the order was placed',
    orderNo BIGINT UNSIGNED NOT NULL COMMENT 'Order number from the system',
    locationCode SMALLINT UNSIGNED NOT NULL COMMENT 'Location code where order originated',
    state CHAR(3) NOT NULL COMMENT 'State abbreviation (e.g., VIC, NSW)',
    fromPostcode MEDIUMINT UNSIGNED NOT NULL COMMENT 'Origin postal code',
    toPostcode MEDIUMINT UNSIGNED NOT NULL COMMENT 'Destination postal code',
    serviceId VARCHAR(10) NOT NULL COMMENT 'Service ID identifying the carrier service',
    promotionId INT UNSIGNED COMMENT 'Foreign key linking to promotions table',
    
    -- Foreign key constraints
    CONSTRAINT fk_orders_serviceId 
        FOREIGN KEY (serviceId) 
        REFERENCES services(serviceId) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_orders_promotionId 
        FOREIGN KEY (promotionId) 
        REFERENCES promotions(promotionId) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    CONSTRAINT fk_orders_toPostcode 
        FOREIGN KEY (toPostcode) 
        REFERENCES deliveryZones(postcode) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    
    -- Indexes for performance
    INDEX idx_orderDate (orderDate),
    INDEX idx_orderNo (orderNo),
    INDEX idx_locationCode (locationCode),
    INDEX idx_state (state),
    INDEX idx_fromPostcode (fromPostcode),
    INDEX idx_toPostcode (toPostcode),
    INDEX idx_serviceId (serviceId),
    INDEX idx_promotionId (promotionId)
);


CREATE TABLE sales (
    saleId BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Auto-generated unique sale ID',
    consignmentId VARCHAR(20) NOT NULL COMMENT 'Foreign key linking to orders table',
    styleCode VARCHAR(20) NOT NULL COMMENT 'Product style code',
    styleCategoryName VARCHAR(25) NOT NULL COMMENT 'Product category name',
    units DECIMAL(10,2) NOT NULL COMMENT 'Number of units sold',
    salesAmount DECIMAL(12,2) NOT NULL COMMENT 'Total sales amount for this line item',
    costOfGoodsSold DECIMAL(12,2) NOT NULL COMMENT 'Cost of goods sold for this line item',
    
    -- Foreign key constraint
    CONSTRAINT fk_sales_consignmentId 
        FOREIGN KEY (consignmentId) 
        REFERENCES orders(consignmentId) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    
    -- Indexes for performance
    INDEX idx_consignmentId (consignmentId),
    INDEX idx_styleCode (styleCode),
    INDEX idx_styleCategoryName (styleCategoryName),
    INDEX idx_units (units),
    INDEX idx_salesAmount (salesAmount)
);

-- =====================================================
-- CARRIER COSTS TABLE
-- =====================================================
-- Table containing carrier cost information
-- consignmentId serves as both primary key and foreign key

CREATE TABLE carrierCosts (
    consignmentId VARCHAR(20) NOT NULL PRIMARY KEY COMMENT 'Consignment ID - primary key and foreign key to orders',
    amountExcludingTax DECIMAL(12,2) NOT NULL COMMENT 'Amount excluding tax',
    billedLength DECIMAL(8,3) COMMENT 'Billed length in centimeters',
    billedWidth DECIMAL(8,3) COMMENT 'Billed width in centimeters', 
    billedHeight DECIMAL(8,3) COMMENT 'Billed height in centimeters',
    cubicWeight DECIMAL(10,3) COMMENT 'Cubic weight calculation',
    billedWeight DECIMAL(10,3) COMMENT 'Billed weight in kilograms',
    
    -- Foreign key constraint
    CONSTRAINT fk_carrierCost_consignmentId 
        FOREIGN KEY (consignmentId) 
        REFERENCES orders(consignmentId) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Check constraints to ensure data quality
    CONSTRAINT chk_amountExcludingTax_not_negative CHECK (amountExcludingTax >= 0),
    CONSTRAINT chk_billedLength_positive CHECK (billedLength IS NULL OR billedLength > 0),
    CONSTRAINT chk_billedWidth_positive CHECK (billedWidth IS NULL OR billedWidth > 0),
    CONSTRAINT chk_billedHeight_positive CHECK (billedHeight IS NULL OR billedHeight > 0),
    CONSTRAINT chk_cubicWeight_positive CHECK (cubicWeight IS NULL OR cubicWeight > 0),
    CONSTRAINT chk_billedWeight_positive CHECK (billedWeight IS NULL OR billedWeight > 0),
    
    -- Indexes for performance
    INDEX idx_amountExcludingTax (amountExcludingTax),
    INDEX idx_billedWeight (billedWeight),
    INDEX idx_cubicWeight (cubicWeight)
);

-- =====================================================
-- FULFILLMENT COSTS TABLE
-- =====================================================
-- Table containing fulfillment cost information
-- fulfillmentCostId serves as the primary key

CREATE TABLE fulfillmentCosts (
    fulfillmentCostId INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Auto-generated unique fulfillment cost ID',
    effectiveDateFrom DATE NOT NULL COMMENT 'Start date when this cost is effective',
    effectiveDateTo DATE NOT NULL COMMENT 'End date when this cost is effective',
    costType VARCHAR(20) NOT NULL COMMENT 'Type of cost (Fixed, Variable)',
    costCode VARCHAR(10) NOT NULL COMMENT 'Cost code identifier (DCF, HOF, PAC, LAB)',
    costDescription VARCHAR(100) NOT NULL COMMENT 'Description of the cost',
    allocationUOM VARCHAR(20) NOT NULL COMMENT 'Unit of measure for allocation (Unit, etc)',
    costPerUOM DECIMAL(8,2) NOT NULL COMMENT 'Cost per unit of measure',
    allocationMethodology VARCHAR(50) NOT NULL COMMENT 'Method of cost allocation (Per Unit, etc)',
    
    -- Check constraints to ensure data quality
    CONSTRAINT chk_effectiveDateTo_after_from CHECK (effectiveDateTo >= effectiveDateFrom),
    CONSTRAINT chk_costPerUOM_not_negative CHECK (costPerUOM >= 0),
    
    -- Indexes for performance
    INDEX idx_effectiveDateFrom (effectiveDateFrom),
    INDEX idx_effectiveDateTo (effectiveDateTo),
    INDEX idx_costType (costType),
    INDEX idx_costCode (costCode),
    INDEX idx_date_range (effectiveDateFrom, effectiveDateTo)
);

-- =====================================================
-- CARRIER COST RECOVERIES TABLE
-- =====================================================
-- Table containing carrier cost recovery information
-- consignmentId serves as the primary key and foreign key

CREATE TABLE carrierCostRecoveries (
    consignmentId VARCHAR(20) NOT NULL PRIMARY KEY COMMENT 'Consignment ID - primary key and foreign key to orders',
    freightRecovery DECIMAL(8,2) NOT NULL COMMENT 'Freight recovery amount in dollars',
    
    -- Foreign key constraint
    CONSTRAINT fk_carrierCostRecoveries_consignmentId 
        FOREIGN KEY (consignmentId) 
        REFERENCES orders(consignmentId) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Check constraints to ensure data quality
    CONSTRAINT chk_freightRecovery_not_negative CHECK (freightRecovery >= 0),
    
    -- Indexes for performance
    INDEX idx_freightRecovery (freightRecovery)
);

-- =====================================================
-- DELIVERY ZONES TABLE
-- =====================================================
-- Table containing delivery zone information
-- postcode serves as the primary key

CREATE TABLE deliveryZones (
    postcode MEDIUMINT UNSIGNED NOT NULL PRIMARY KEY COMMENT 'Postcode - primary key',
    destinationZoneCode VARCHAR(10) NOT NULL COMMENT 'Destination zone code (e.g., AAT, BR)',
    destinationZoneState VARCHAR(10) NOT NULL COMMENT 'Destination zone state',
    description VARCHAR(50) NOT NULL COMMENT 'Zone description',
    postcodeDeliveryZone VARCHAR(20) NOT NULL COMMENT 'Postcode delivery zone identifier',
    stateClassification VARCHAR(50) NOT NULL COMMENT 'State classification (Same State, Distant State, etc)',
    stateArea VARCHAR(20) NOT NULL COMMENT 'State area (Metro, Remote, etc)',
    postcodeDeliveryZoneDescription VARCHAR(50) NOT NULL COMMENT 'Full postcode delivery zone description',
    
    -- Indexes for performance
    INDEX idx_destinationZoneCode (destinationZoneCode),
    INDEX idx_destinationZoneState (destinationZoneState),
    INDEX idx_stateClassification (stateClassification),
    INDEX idx_stateArea (stateArea),
    INDEX idx_postcodeDeliveryZone (postcodeDeliveryZone)
);
