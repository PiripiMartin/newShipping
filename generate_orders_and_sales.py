#!/usr/bin/env python3
"""
Generate SQL INSERT statements for orders and sales tables.
This script processes raw sales data and links it with carrier costs and promotions.
"""

import csv
import os
from datetime import datetime
from collections import defaultdict
import glob

# Configuration
RAW_SALES_CSV = 'RawCSVs/rawSales.csv'
PROMOTIONS_CSV = 'CSVs/promotions.csv'
CARRIER_COSTS_DIR = 'CY24 Australia Post Invoicing Data'
ORDERS_OUTPUT = 'Data Inserts/orders_batched.sql'
SALES_OUTPUT = 'Data Inserts/sales_batched.sql'
BATCH_SIZE = 1000

def parse_date(date_str):
    """Parse date from d/m/yyyy format."""
    try:
        return datetime.strptime(date_str, '%d/%m/%Y').date()
    except:
        return None

def clean_numeric(value):
    """Remove commas and quotes from numeric values."""
    if isinstance(value, str):
        value = value.replace(',', '').replace('"', '').strip()
    try:
        return float(value)
    except (ValueError, TypeError):
        return 0.0

def escape_string(value):
    """Escape single quotes in strings for SQL."""
    if value is None:
        return ''
    return str(value).replace("'", "''").strip()

def load_carrier_costs():
    """Load all carrier cost data from Australia Post CSV files."""
    print("Loading carrier costs from Australia Post invoices...")
    carrier_costs = {}
    
    # Find all AP CSV files
    ap_files = glob.glob(f'{CARRIER_COSTS_DIR}/**/*.csv', recursive=True)
    
    for ap_file in ap_files:
        print(f"  Reading: {ap_file}")
        try:
            with open(ap_file, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    consignment_id = escape_string(row.get('CONSIGNMENT ID', ''))
                    if consignment_id and consignment_id not in carrier_costs:
                        carrier_costs[consignment_id] = {
                            'toPostcode': row.get('TO POSTAL CODE', '').strip(),
                            'amountExcludingTax': clean_numeric(row.get('AMOUNT EXCL TAX', 0)),
                            'billedLength': clean_numeric(row.get('BILLED LENGTH', 0)) or None,
                            'billedWidth': clean_numeric(row.get('BILLED WIDTH', 0)) or None,
                            'billedHeight': clean_numeric(row.get('BILLED HEIGHT', 0)) or None,
                            'cubicWeight': clean_numeric(row.get('CUBIC WEIGHT', 0)) or None,
                            'billedWeight': clean_numeric(row.get('BILLED WEIGHT', 0)) or None
                        }
        except Exception as e:
            print(f"  Warning: Error reading {ap_file}: {e}")
    
    print(f"Loaded {len(carrier_costs):,} carrier cost records\n")
    return carrier_costs

def load_promotions():
    """Load promotions data from SQL file and create date range mappings."""
    print("Loading promotions from SQL file...")
    
    # Read the promotions SQL file directly
    promotions = []
    sql_file = 'Data Inserts/promotions_batched.sql'
    
    with open(sql_file, 'r', encoding='utf-8') as f:
        content = f.read()
        
        # Extract promotion data from INSERT statements
        import re
        pattern = r'\((\d+),\s*\'([^\']+)\',\s*\'(\d{4}-\d{2}-\d{2})\',\s*\'(\d{4}-\d{2}-\d{2})\''
        matches = re.findall(pattern, content)
        
        for match in matches:
            promo_id = int(match[0])
            description = match[1]
            start_date = datetime.strptime(match[2], '%Y-%m-%d').date()
            end_date = datetime.strptime(match[3], '%Y-%m-%d').date()
            
            promotions.append({
                'id': promo_id,
                'description': description,
                'startDate': start_date,
                'endDate': end_date
            })
    
    print(f"Loaded {len(promotions)} promotions with date ranges\n")
    return promotions

def process_sales_data(carrier_costs, promotions):
    """Process raw sales data and group by order."""
    print(f"Processing raw sales data from: {RAW_SALES_CSV}")
    
    orders = {}  # Key: consignmentId, Value: order data
    sales = []   # List of all sales records
    
    missing_carrier_costs = set()
    negative_count = 0
    orders_with_promotions = 0
    
    with open(RAW_SALES_CSV, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        
        for row in reader:
            connote_no = escape_string(row['Connote No'])
            order_date = parse_date(row['Order Date'])
            
            if not connote_no or not order_date:
                continue
            
            # Create order record if not exists
            if connote_no not in orders:
                # Get TO postcode from carrier costs
                carrier_data = carrier_costs.get(connote_no, {})
                to_postcode = carrier_data.get('toPostcode', '')
                
                if not to_postcode:
                    missing_carrier_costs.add(connote_no)
                    continue  # Skip orders without carrier cost data
                
                # Find promotion ID by checking if order date falls within any promotion date range
                promotion_id = None
                for promo in promotions:
                    if promo['startDate'] <= order_date <= promo['endDate']:
                        promotion_id = promo['id']
                        orders_with_promotions += 1
                        break
                
                orders[connote_no] = {
                    'consignmentId': connote_no,
                    'orderDate': order_date.strftime('%Y-%m-%d'),
                    'orderNo': row['Order No'].strip(),
                    'locationCode': row['Location Code'].strip(),
                    'state': escape_string(row['State']),
                    'fromPostcode': row['Postcode'].strip(),
                    'toPostcode': to_postcode,
                    'serviceId': escape_string(row['Carrier Name Code']),
                    'promotionId': promotion_id
                }
            
            # Create sales record
            units = clean_numeric(row['Units'])
            sales_amount = clean_numeric(row['Sales $'])
            cogs = clean_numeric(row['COGS $'])
            
            if units < 0 or sales_amount < 0 or cogs < 0:
                negative_count += 1
            
            sales.append({
                'consignmentId': connote_no,
                'styleCode': escape_string(row['Style Code']),
                'styleCategoryName': escape_string(row['Style Category Name']),
                'units': units,
                'salesAmount': sales_amount,
                'costOfGoodsSold': cogs
            })
    
    print(f"Processed {len(orders):,} unique orders")
    print(f"Orders linked to promotions: {orders_with_promotions:,}")
    print(f"Processed {len(sales):,} sales records")
    print(f"Records with negative values: {negative_count:,}")
    print(f"Missing carrier cost data for {len(missing_carrier_costs):,} orders\n")
    
    return orders, sales

def write_orders_sql(orders):
    """Write orders INSERT statements to SQL file."""
    print(f"Generating orders SQL file: {ORDERS_OUTPUT}")
    
    orders_list = list(orders.values())
    
    with open(ORDERS_OUTPUT, 'w', encoding='utf-8') as f:
        # Write header
        f.write("-- =====================================================\n")
        f.write("-- ORDERS DATA LOADING\n")
        f.write("-- =====================================================\n")
        f.write("-- Generated from raw sales data linked with carrier costs\n")
        f.write("-- =====================================================\n\n")
        f.write("USE Shipping;\n\n")
        f.write("-- Disable checks for faster loading\n")
        f.write("SET AUTOCOMMIT = 0;\n")
        f.write("SET FOREIGN_KEY_CHECKS = 0;\n")
        f.write("SET UNIQUE_CHECKS = 0;\n\n")
        
        # Write batched INSERT statements
        total_batches = (len(orders_list) + BATCH_SIZE - 1) // BATCH_SIZE
        
        for batch_num in range(total_batches):
            start_idx = batch_num * BATCH_SIZE
            end_idx = min(start_idx + BATCH_SIZE, len(orders_list))
            batch_rows = orders_list[start_idx:end_idx]
            
            f.write(f"-- ===== Batch {batch_num + 1} of {total_batches} ({len(batch_rows)} records) =====\n")
            f.write("INSERT INTO orders (consignmentId, orderDate, orderNo, locationCode, state, fromPostcode, toPostcode, serviceId, promotionId) VALUES\n")
            
            for i, order in enumerate(batch_rows):
                # Promotion ID is numeric, no quotes needed
                promo_id = str(order['promotionId']) if order['promotionId'] else 'NULL'
                
                values = (
                    f"('{order['consignmentId']}', "
                    f"'{order['orderDate']}', "
                    f"{order['orderNo']}, "
                    f"{order['locationCode']}, "
                    f"'{order['state']}', "
                    f"{order['fromPostcode']}, "
                    f"{order['toPostcode']}, "
                    f"'{order['serviceId']}', "
                    f"{promo_id})"
                )
                
                if i < len(batch_rows) - 1:
                    f.write(values + ",\n")
                else:
                    f.write(values + ";\n\n")
            
            # Commit every 10 batches
            if (batch_num + 1) % 10 == 0:
                f.write("COMMIT;\n")
                f.write("SET AUTOCOMMIT = 0;\n\n")
        
        # Write footer
        f.write("-- Final commit and re-enable checks\n")
        f.write("COMMIT;\n")
        f.write("SET FOREIGN_KEY_CHECKS = 1;\n")
        f.write("SET UNIQUE_CHECKS = 1;\n")
        f.write("SET AUTOCOMMIT = 1;\n\n")
        f.write(f"-- Total orders inserted: {len(orders_list):,}\n")
    
    print(f"Orders SQL file generated successfully! ({len(orders_list):,} records)\n")

def write_sales_sql(sales):
    """Write sales INSERT statements to SQL file."""
    print(f"Generating sales SQL file: {SALES_OUTPUT}")
    
    with open(SALES_OUTPUT, 'w', encoding='utf-8') as f:
        # Write header
        f.write("-- =====================================================\n")
        f.write("-- SALES DATA LOADING (ALL RECORDS INCLUDING NEGATIVES)\n")
        f.write("-- =====================================================\n")
        f.write("-- This script includes negative values (returns/refunds).\n")
        f.write("-- Schema has been modified to allow negative units and salesAmount.\n")
        f.write("-- =====================================================\n\n")
        f.write("USE Shipping;\n\n")
        f.write("-- Disable checks for faster loading\n")
        f.write("SET AUTOCOMMIT = 0;\n")
        f.write("SET FOREIGN_KEY_CHECKS = 0;\n")
        f.write("SET UNIQUE_CHECKS = 0;\n\n")
        
        # Write batched INSERT statements
        total_batches = (len(sales) + BATCH_SIZE - 1) // BATCH_SIZE
        
        for batch_num in range(total_batches):
            start_idx = batch_num * BATCH_SIZE
            end_idx = min(start_idx + BATCH_SIZE, len(sales))
            batch_rows = sales[start_idx:end_idx]
            
            f.write(f"-- ===== Batch {batch_num + 1} of {total_batches} ({len(batch_rows)} records) =====\n")
            f.write("INSERT INTO sales (consignmentId, styleCode, styleCategoryName, units, salesAmount, costOfGoodsSold) VALUES\n")
            
            for i, sale in enumerate(batch_rows):
                values = (
                    f"('{sale['consignmentId']}', "
                    f"'{sale['styleCode']}', "
                    f"'{sale['styleCategoryName']}', "
                    f"{sale['units']}, "
                    f"{sale['salesAmount']}, "
                    f"{sale['costOfGoodsSold']})"
                )
                
                if i < len(batch_rows) - 1:
                    f.write(values + ",\n")
                else:
                    f.write(values + ";\n\n")
            
            # Commit every 10 batches
            if (batch_num + 1) % 10 == 0:
                f.write("COMMIT;\n")
                f.write("SET AUTOCOMMIT = 0;\n\n")
        
        # Write footer
        f.write("-- Final commit and re-enable checks\n")
        f.write("COMMIT;\n")
        f.write("SET FOREIGN_KEY_CHECKS = 1;\n")
        f.write("SET UNIQUE_CHECKS = 1;\n")
        f.write("SET AUTOCOMMIT = 1;\n\n")
        f.write(f"-- Total sales records inserted: {len(sales):,}\n")
    
    print(f"Sales SQL file generated successfully! ({len(sales):,} records)\n")

def main():
    """Main execution function."""
    print("=" * 60)
    print("ORDERS AND SALES DATA GENERATOR")
    print("=" * 60)
    print()
    
    # Load carrier costs
    carrier_costs = load_carrier_costs()
    
    # Load promotions
    promotions = load_promotions()
    
    # Process sales data
    orders, sales = process_sales_data(carrier_costs, promotions)
    
    # Generate SQL files
    write_orders_sql(orders)
    write_sales_sql(sales)
    
    print("=" * 60)
    print("GENERATION COMPLETE!")
    print("=" * 60)
    print(f"✅ Orders SQL: {ORDERS_OUTPUT}")
    print(f"✅ Sales SQL: {SALES_OUTPUT}")
    print()
    print("⚠️  IMPORTANT:")
    print("1. Orders are linked to promotions based on order date ranges")
    print("2. Orders TO postcode comes from carrier costs data")
    print("3. Orders FROM postcode comes from sales postcode")
    print("4. Sales include negative values (returns/refunds)")
    print("5. Schema already modified to allow negative values")

if __name__ == '__main__':
    main()

