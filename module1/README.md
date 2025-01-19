# NYC Taxi Data Pipeline

## Architecture

```mermaid
graph LR
    CSV[CSV Data] --> IS[Ingest Script<br>ingest_data.py]
    IS -->|Write| DB[(PostgreSQL<br>postgres)]
    DB -->|View| PG[pgAdmin]
    subgraph Docker Network
        direction TB
        IS
        DB
        PG
    end
```

## Quick Start

1. Download data files:
```bash
chmod +x setup.sh
./setup.sh
```

2. Start database services:
```bash
docker-compose up -d
```

3. Run data ingestion:
```bash
python ingest_data.py
```

## Data Flow

```mermaid
sequenceDiagram
    participant CSV as CSV Files
    participant IS as Ingest Script
    participant DB as PostgreSQL
    participant PG as pgAdmin

    Note over CSV: green_tripdata_2019-10.csv<br>taxi_zone_lookup.csv
    IS->>CSV: Read Files
    IS->>IS: Transform Data
    IS->>DB: Write to Tables
    Note over IS,DB: Using SQLAlchemy
    PG->>DB: Query/View Data
    Note over PG,DB: Via postgres:5432
```

## Infrastructure Configuration

```mermaid
graph TB
    subgraph External Access
        H[Host Machine] -->|localhost:5433| P1[Port Mapping]
        H -->|localhost:8080| P2[Port Mapping]
    end
    subgraph Docker Network homework_default
        P1 -->|5432| DB[(PostgreSQL)]
        P2 -->|80| PG[pgAdmin]
        IS[Ingest Script] -->|postgres:5432| DB
    end
```

## Directory Structure
```
.
├── data/                      # Downloaded data files
│   ├── green_tripdata_2019-10.csv
│   └── taxi_zone_lookup.csv
├── docker-compose.yaml        # Database services config
├── setup.sh                   # Data download script
├── ingest_data.py            # Data ingestion script
└── test_queries.sql          # SQL queries for homework
```

## Service Configuration

### Database Access
- Host: localhost (external) or postgres (internal)
- Port: 5433 (external) or 5432 (internal)
- Database: ny_taxi
- Username: postgres
- Password: postgres

### pgAdmin Access
- URL: http://localhost:8080
- Email: pgadmin@pgadmin.com
- Password: pgadmin
- Server configuration:
  - Host: postgres
  - Port: 5432
  - Database: ny_taxi
  - Username: postgres
  - Password: postgres

## Data Pipeline Process

```mermaid
graph TD
    A[Download Data] -->|setup.sh| B[Extract CSV]
    B --> C[Start Services]
    C -->|docker-compose| D[PostgreSQL]
    C -->|docker-compose| E[pgAdmin]
    D --> F[Ingest Data]
    F -->|ingest_data.py| G[Load Zones]
    F -->|ingest_data.py| H[Load Trips]
    G --> I[Verify Data]
    H --> I
```

## Common Issues

### Connection Issues
1. Check containers:
```bash
docker-compose ps
```

2. View logs:
```bash
docker-compose logs
```

### Data Loading Problems
1. Verify files:
```bash
ls -l data/
```

2. Check space:
```bash
df -h
```

## Cleanup

```mermaid
graph TD
    A[Stop Services] -->|docker-compose down| B[Remove Containers]
    B -->|docker-compose down -v| C[Remove Volumes]
    C --> D[Clean Data]
    D -->|rm -rf data/*| E[Directory Clean]
```

### Full Cleanup
```bash
# Stop and remove containers
docker-compose down

# Remove volumes
docker-compose down -v

# Clean data directory
rm -rf data/*
```

## Useful Commands

### Container Management
```bash
# Check container status
docker-compose ps

# View container logs
docker-compose logs

# Restart services
docker-compose restart
```

### Database Access
```bash
# Connect using pgcli
pgcli -h localhost -p 5433 -U postgres -d ny_taxi

# Run test queries
pgcli -h localhost -p 5433 -U postgres -d ny_taxi -f test_queries.sql
```