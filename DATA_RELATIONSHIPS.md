# Data Relationships Documentation

## Overview
This document explains the relationships between tables and how data flows through the shipping database.

## Data Generation Summary

### Orders Table
- **Source**: `RawCSVs/rawSales.csv` (grouped by Connote No)
- **Total Records**: 158,801 unique orders
- **Key**: `consignmentId` (from Connote No)

### Sales Table  
- **Source**: `RawCSVs/rawSales.csv` (all records)
- **Total Records**: 376,181 sales records
- **Includes**: Negative values (returns/refunds) - 2,953 records
- **Relationship**: Multiple sales records per order

### Excluded Data
- **716 orders** were excluded due to missing carrier cost data (no TO postcode available)

---

## Table Relationships

### 1. Orders → Sales (One-to-Many)
```
orders.consignmentId → sales.consignmentId
```
- Each order contains multiple sales line items
- Sales are grouped by `Connote No` (consignmentId)
- Example: Order X4B6517585 has 2 sales records

### 2. Orders → Services (Many-to-One)
```
orders.serviceId → services.serviceId
```
- **Source of serviceId**: `Carrier Name Code` field in raw sales CSV
- Service types include: APE, X4B, ID25, etc.
- Found in `Services.csv`

### 3. Orders → Promotions (Many-to-One, Optional)
```
orders.promotionId → promotions.promotionId
```
- **Linking Logic**: Order date falls within promotion date range
- Source: `promotions.csv` contains dates for each promotion
- **1 unique promotion** found (PR0001)
- **553 promotion dates** mapped
- Orders without matching promotion dates have `promotionId = NULL`

### 4. Orders → Carrier Costs (One-to-One)
```
orders.consignmentId → carrierCosts.consignmentId
```
- **Source**: Australia Post invoicing CSV files (`CY24 Australia Post Invoicing Data/`)
- **395,416 carrier cost records** loaded from AP invoices
- Used to get:
  - `toPostcode` (destination)
  - Shipping costs
  - Package dimensions and weights

### 5. Orders → Delivery Zones (Many-to-One)
```
orders.toPostcode → deliveryZones.postcode
```
- Links orders to destination zone information
- Provides zone classifications and descriptions

---

## Field Mappings

### Orders Table Field Sources

| Database Field | Source CSV | Source Field | Notes |
|---------------|------------|--------------|-------|
| `consignmentId` | rawSales.csv | Connote No | Primary key |
| `orderDate` | rawSales.csv | Order Date | Format: d/m/yyyy |
| `orderNo` | rawSales.csv | Order No | |
| `locationCode` | rawSales.csv | Location Code | Origin location |
| `state` | rawSales.csv | State | Origin state |
| `fromPostcode` | rawSales.csv | Postcode | **Origin postcode** |
| `toPostcode` | AP *.csv | TO POSTAL CODE | **Destination postcode** |
| `serviceId` | rawSales.csv | Carrier Name Code | Links to services table |
| `promotionId` | promotions.csv | Promotion ID | Matched by order date |

### Sales Table Field Sources

| Database Field | Source CSV | Source Field |
|---------------|------------|--------------|
| `consignmentId` | rawSales.csv | Connote No |
| `styleCode` | rawSales.csv | Style Code |
| `styleCategoryName` | rawSales.csv | Style Category Name |
| `units` | rawSales.csv | Units |
| `salesAmount` | rawSales.csv | Sales $ |
| `costOfGoodsSold` | rawSales.csv | COGS $ |

### Carrier Costs Field Sources

| Database Field | Source CSV | Source Field |
|---------------|------------|--------------|
| `consignmentId` | AP *.csv | CONSIGNMENT ID |
| `amountExcludingTax` | AP *.csv | AMOUNT EXCL TAX |
| `billedLength` | AP *.csv | BILLED LENGTH |
| `billedWidth` | AP *.csv | BILLED WIDTH |
| `billedHeight` | AP *.csv | BILLED HEIGHT |
| `cubicWeight` | AP *.csv | CUBIC WEIGHT |
| `billedWeight` | AP *.csv | BILLED WEIGHT |

---

## Important Notes

### Negative Values in Sales
- **2,953 sales records** contain negative values
- Represents returns, refunds, or adjustments
- Schema constraints must be dropped to allow these values:
  ```sql
  ALTER TABLE sales DROP CONSTRAINT chk_units_positive;
  ALTER TABLE sales DROP CONSTRAINT chk_salesAmount_positive;
  ```

### Data Flow
1. Start with `rawSales.csv` (contains all transaction data)
2. Group by `Connote No` to create unique orders
3. Link to Australia Post invoices to get `toPostcode` and shipping costs
4. Match order dates to promotion dates
5. Create sales records for each line item

### Service Identification
Service ID comes from the `Carrier Name Code` in raw sales data:
- **APE**: Australia Post Express
- **X4B**: Australia Post Standard  
- **ID25**: Australia Post ID25
- **005**: Team Global Express (TFE)
- **RDR**: Rendr
- Others: Various carriers

---

## SQL Loading Order

To load data correctly, follow this sequence:

1. Load reference tables first:
   - `carriers`
   - `services`
   - `deliveryZones`
   - `promotions`

2. Load orders:
   - `orders_batched.sql`

3. Load related order data:
   - `carrier_cost_batched.sql`
   - `carrier_cost_recoveries_batched.sql`
   - `fulfillment_costs_data.sql`

4. Load sales:
   - `sales_batched.sql`

---

## Generated Files

1. **`Data Inserts/orders_batched.sql`**
   - 158,801 orders
   - Linked with carrier costs for TO postcode
   - Linked with promotions by date

2. **`Data Inserts/sales_batched.sql`**
   - 376,181 sales records
   - Includes negative values (returns/refunds)
   - Schema modified to allow negative values

3. **`generate_orders_and_sales.py`**
   - Python script to regenerate these files
   - Reads raw sales, links with carrier costs and promotions
   - Generates batched SQL inserts

