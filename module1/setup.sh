#!/bin/bash

# Create data directory if it doesn't exist
mkdir -p data

# Download taxi data
echo "Downloading green taxi data for October 2019..."
wget -O data/green_tripdata_2019-10.csv.gz https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz

# Download zones lookup data
echo "Downloading taxi zone lookup data..."
wget -O data/taxi_zone_lookup.csv https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv

# Unzip the taxi data
echo "Extracting taxi data..."
gunzip -f data/green_tripdata_2019-10.csv.gz

echo "All data files downloaded and extracted."
