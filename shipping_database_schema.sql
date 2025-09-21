-- Create database
USE Shipping;

-- =====================================================
-- ORDERS TABLE
-- =====================================================
-- Primary table containing order information
-- consignmentId serves as the primary key

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
    serviceId VARCHAR(10) NOT NULL COMMENT 'Service ID identifying the carrier',
    promotionId INT UNSIGNED COMMENT 'Foreign key linking to promotions table',
    
    -- Foreign key constraint
    CONSTRAINT fk_orders_promotionId 
        FOREIGN KEY (promotionId) 
        REFERENCES promotions(promotionId) 
        ON DELETE SET NULL 
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
    
    -- Check constraints to ensure data quality
    CONSTRAINT chk_units_positive CHECK (units > 0),
    CONSTRAINT chk_salesAmount_not_negative CHECK (salesAmount >= 0),
    CONSTRAINT chk_costOfGoodsSold_not_negative CHECK (costOfGoodsSold >= 0),
    
    -- Indexes for performance
    INDEX idx_consignmentId (consignmentId),
    INDEX idx_styleCode (styleCode),
    INDEX idx_styleCategoryName (styleCategoryName),
    INDEX idx_units (units),
    INDEX idx_salesAmount (salesAmount)
);
