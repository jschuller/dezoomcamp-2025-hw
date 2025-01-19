#!/bin/bash

# Function to check and fix Docker permissions
setup_docker_permissions() {
    # Check if we can access Docker
    if ! docker ps >/dev/null 2>&1; then
        echo "Setting up Docker permissions..."
        # Add current user to Docker group
        if ! groups | grep -q docker; then
            sudo usermod -aG docker $USER
            echo "Added user to Docker group. You may need to run 'newgrp docker' or restart your shell."
            # Refresh group membership without requiring logout
            exec sg docker -c "$0"
        fi
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect environment
if [ -n "${CODESPACES}" ]; then
    echo "Setting up GitHub Codespaces environment..."
    POSTGRES_HOST="db"
else
    echo "Setting up local devcontainer environment..."
    POSTGRES_HOST="localhost"
fi

# Setup Docker permissions
setup_docker_permissions

# Create data directory
mkdir -p data

# Download data files if they don't exist
echo "Checking/Downloading required data files..."
if [ ! -f data/green_tripdata_2019-10.csv ]; then
    if [ ! -f data/green_tripdata_2019-10.csv.gz ]; then
        echo "Downloading taxi trip data..."
        wget -O data/green_tripdata_2019-10.csv.gz https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz
    fi
    echo "Extracting taxi data..."
    gunzip -f data/green_tripdata_2019-10.csv.gz
fi

if [ ! -f data/taxi_zone_lookup.csv ]; then
    echo "Downloading taxi zone lookup data..."
    wget -O data/taxi_zone_lookup.csv https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
fi

# Ensure Docker is running
echo "Checking Docker service..."
if ! docker info >/dev/null 2>&1; then
    echo "Docker is not running or not accessible. Please check Docker installation."
    exit 1
fi

# Start database services
echo "Starting Postgres and pgAdmin..."
docker-compose down -v >/dev/null 2>&1  # Clean up any existing containers
docker-compose up -d

# Wait for Postgres to be ready
echo "Waiting for Postgres to be ready..."
for i in {1..30}; do
    if docker-compose exec -T db pg_isready -U postgres >/dev/null 2>&1; then
        echo "Postgres is ready!"
        break
    fi
    echo "Waiting for Postgres... ($i/30)"
    sleep 2
done

# Check if Postgres is really ready
if ! docker-compose exec -T db pg_isready -U postgres >/dev/null 2>&1; then
    echo "Failed to connect to Postgres after 60 seconds"
    echo "Checking container logs:"
    docker-compose logs db
    exit 1
fi

# Install Python dependencies if needed
if ! command_exists pgcli; then
    echo "Installing Python dependencies..."
    pip install -r requirements.txt
fi

# Ingest data
echo "Ingesting data into Postgres..."
python ingest_data.py

echo -e "\nSetup complete! Access:"
echo "- Postgres: ${POSTGRES_HOST}:5433"
echo "- pgAdmin: http://localhost:8080"
echo "  Email: pgadmin@pgadmin.com"
echo "  Password: pgadmin"
echo -e "\nTry running test queries:"
echo "pgcli -h localhost -p 5433 -U postgres -d ny_taxi -f test_queries.sql"