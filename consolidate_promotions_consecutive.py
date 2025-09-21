#!/usr/bin/env python3
"""
Consolidate promotions.csv by consecutive days within each promotion group
If there's a gap in dates, treat as separate promotion periods
"""

import pandas as pd
from datetime import datetime, timedelta

def consolidate_promotions_consecutive():
    print("🔄 Consolidating promotions.csv by consecutive days...")
    
    # Read the promotions CSV
    df = pd.read_csv('/Users/piripimartin/Desktop/NewShippingDatabase/CSVs/promotions.csv')
    
    print(f"📊 Original data: {len(df):,} rows")
    print(f"📊 Unique promotion groups: {df['Promotion Group'].nunique()}")
    
    # Convert Date column to datetime
    df['Date'] = pd.to_datetime(df['Date'], format='%d/%m/%Y')
    
    # Sort by Promotion Group and Date
    df = df.sort_values(['Promotion Group', 'Date'])
    
    consolidated_periods = []
    
    # Process each promotion group
    for group in df['Promotion Group'].unique():
        if group == 'Promotion Group':  # Skip header
            continue
            
        group_data = df[df['Promotion Group'] == group].copy()
        group_data = group_data.sort_values('Date')
        
        print(f"🔍 Processing {group}: {len(group_data)} days")
        
        # Find consecutive date periods
        current_period_start = None
        current_period_end = None
        previous_date = None
        
        for idx, row in group_data.iterrows():
            current_date = row['Date']
            
            if previous_date is None:
                # First date in group
                current_period_start = current_date
                current_period_end = current_date
            elif current_date == previous_date + timedelta(days=1):
                # Consecutive day - extend current period
                current_period_end = current_date
            else:
                # Gap found - save current period and start new one
                period_data = group_data[
                    (group_data['Date'] >= current_period_start) & 
                    (group_data['Date'] <= current_period_end)
                ]
                
                consolidated_periods.append({
                    'promotion_id': period_data['Promotion ID'].iloc[0],
                    'promotion_description': period_data['Promotion Description'].iloc[0],
                    'start_date': current_period_start.strftime('%Y-%m-%d'),
                    'end_date': current_period_end.strftime('%Y-%m-%d'),
                    'duration_days': (current_period_end - current_period_start).days + 1,
                    'start_week': period_data['Week Number'].min(),
                    'end_week': period_data['Week Number'].max(),
                    'calendar_year': period_data['Calendar Year'].iloc[0],
                    'financial_year': period_data['Financial Year'].iloc[0]
                })
                
                # Start new period
                current_period_start = current_date
                current_period_end = current_date
            
            previous_date = current_date
        
        # Don't forget the last period
        if current_period_start is not None:
            period_data = group_data[
                (group_data['Date'] >= current_period_start) & 
                (group_data['Date'] <= current_period_end)
            ]
            
            consolidated_periods.append({
                'promotion_id': period_data['Promotion ID'].iloc[0],
                'promotion_description': period_data['Promotion Description'].iloc[0],
                'start_date': current_period_start.strftime('%Y-%m-%d'),
                'end_date': current_period_end.strftime('%Y-%m-%d'),
                'duration_days': (current_period_end - current_period_start).days + 1,
                'start_week': period_data['Week Number'].min(),
                'end_week': period_data['Week Number'].max(),
                'calendar_year': period_data['Calendar Year'].iloc[0],
                'financial_year': period_data['Financial Year'].iloc[0]
            })
    
    # Convert to DataFrame
    result = pd.DataFrame(consolidated_periods)
    
    # Sort by start_date
    result = result.sort_values('start_date')
    
    # Save consolidated file
    output_file = '/Users/piripimartin/Desktop/NewShippingDatabase/CSVs/promotions_consolidated.csv'
    result.to_csv(output_file, index=False)
    
    print(f"✅ Consolidated data: {len(result):,} promotion periods")
    print(f"📁 Saved to: promotions_consolidated.csv")
    
    # Show summary
    print(f"\n📈 Summary:")
    print(f"  • Original rows: {len(df):,}")
    print(f"  • Consolidated periods: {len(result):,}")
    print(f"  • Reduction: {len(df) - len(result):,} rows ({((len(df) - len(result)) / len(df) * 100):.1f}%)")
    
    # Show sample of results
    print(f"\n📋 Sample consecutive promotion periods:")
    pd.set_option('display.max_columns', None)
    pd.set_option('display.width', None)
    print(result.head(15).to_string(index=False))
    
    # Show duration statistics
    print(f"\n📊 Duration Statistics:")
    print(f"  • Average duration: {result['duration_days'].mean():.1f} days")
    print(f"  • Shortest period: {result['duration_days'].min()} days")
    print(f"  • Longest period: {result['duration_days'].max()} days")
    
    # Show gaps analysis
    print(f"\n🔍 Gap Analysis:")
    same_description = result.groupby('promotion_description').size()
    multi_period_promos = same_description[same_description > 1]
    if len(multi_period_promos) > 0:
        print(f"  • Promotions with multiple periods (gaps): {len(multi_period_promos)}")
        for desc, count in multi_period_promos.head(5).items():
            print(f"    - '{desc[:50]}...': {count} periods")
    else:
        print(f"  • All promotions are consecutive (no gaps found)")
    
    return result

def main():
    print("🚀 Consecutive Promotions Consolidation Tool")
    print("=" * 60)
    
    start_time = datetime.now()
    
    # Consolidate promotions by consecutive days
    result = consolidate_promotions_consecutive()
    
    end_time = datetime.now()
    duration = end_time - start_time
    
    print(f"\n🎉 Consecutive Consolidation Complete!")
    print(f"⏱️  Processing time: {duration}")
    
    print(f"\n📋 Next Steps:")
    print("1. Review promotions_consolidated.csv")
    print("2. Each row represents a consecutive date period")
    print("3. Gaps in dates create separate promotion periods")

if __name__ == "__main__":
    try:
        import pandas as pd
    except ImportError:
        print("❌ pandas not installed. Run: pip install pandas")
        exit(1)
    
    main()
