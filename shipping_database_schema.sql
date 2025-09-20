-- Create database
USE Shipping;

-- =====================================================
-- ORDERS TABLE
-- =====================================================
-- Primary table containing order information
-- consignmentId serves as the primary key

CREATE TABLE orders (
    consignmentId VARCHAR(20) NOT NULL PRIMARY KEY COMMENT 'Unique consignment ID - primary key',
    orderDate DATE NOT NULL COMMENT 'Date when the order was placed',
    orderNo BIGINT UNSIGNED NOT NULL COMMENT 'Order number from the system',
    locationCode SMALLINT UNSIGNED NOT NULL COMMENT 'Location code where order originated',
    state CHAR(3) NOT NULL COMMENT 'State abbreviation (e.g., VIC, NSW)',
    fromPostcode MEDIUMINT UNSIGNED NOT NULL COMMENT 'Origin postal code',
    toPostcode MEDIUMINT UNSIGNED NOT NULL COMMENT 'Destination postal code',
    serviceId VARCHAR(10) NOT NULL COMMENT 'Service ID identifying the carrier',
    
    -- Indexes for performance
    INDEX idx_orderDate (orderDate),
    INDEX idx_orderNo (orderNo),
    INDEX idx_locationCode (locationCode),
    INDEX idx_state (state),
    INDEX idx_serviceId (serviceId)
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
