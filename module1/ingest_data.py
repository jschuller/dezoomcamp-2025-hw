#!/usr/bin/env python
# coding: utf-8

import os
import pandas as pd
from sqlalchemy import create_engine, text
from time import time

def main():
    # Check for data files
    trips_file = './data/green_tripdata_2019-10.csv'
    zones_file = './data/taxi_zone_lookup.csv'

    if not os.path.exists(trips_file) or not os.path.exists(zones_file):
        print(f'Error: Required data files not found!')
        return

    # Database connection parameters
    user = "postgres"
    password = "postgres"
    host = "postgres"      # Use container name in network
    port = "5432"         # Use container port
    db = "ny_taxi"        # Match with docker-compose.yaml
    
    print(f'\nConnecting to database: postgres://{user}:***@{host}:{port}/{db}')
    
    # Create SQLAlchemy engine
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    try:
        # Test connection
        with engine.connect() as conn:
            result = conn.execute(text("SELECT 1"))
            print("Database connection successful!")
    except Exception as e:
        print(f"Error connecting to database: {str(e)}")
        return

    # Ingest taxi zones
    print('\nIngesting taxi zones data...')
    df_zones = pd.read_csv(zones_file)
    df_zones.to_sql(name='taxi_zones', con=engine, if_exists='replace', index=False)
    print(f'Successfully ingested {len(df_zones)} taxi zones')

    # Ingest trip data
    print('\nIngesting trip data...')
    total_rows = 0
    chunk_size = 100000
    start_time = time()

    for chunk in pd.read_csv(trips_file, chunksize=chunk_size):
        t_start = time()
        
        # Convert timestamps
        chunk.lpep_pickup_datetime = pd.to_datetime(chunk.lpep_pickup_datetime)
        chunk.lpep_dropoff_datetime = pd.to_datetime(chunk.lpep_dropoff_datetime)
        
        # Write to database
        chunk.to_sql(name='green_taxi_trips', con=engine, 
                    if_exists='append' if total_rows > 0 else 'replace', 
                    index=False)
        
        # Update progress
        total_rows += len(chunk)
        t_end = time()
        print(f'Inserted chunk of {len(chunk):,} rows, took {(t_end - t_start):.2f} seconds. Total rows: {total_rows:,}')

    print(f"\nFinished ingesting all data")
    print(f"Total rows ingested: {total_rows:,}")
    print(f"Total time: {(time() - start_time):.2f} seconds")

    # Verify data
    print("\nVerifying data...")
    with engine.connect() as conn:
        result = conn.execute(text("SELECT COUNT(*) FROM green_taxi_trips"))
        count = result.scalar()
        print(f"Verified {count:,} rows in database")

if __name__ == '__main__':
    main()