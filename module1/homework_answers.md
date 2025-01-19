# Data Engineering Zoomcamp 2025 - Module 1 Homework Answers

## Question 1: Understanding docker first run

*Run docker with the `python:3.12.8` image in an interactive mode, use the entrypoint `bash`. What's the version of `pip` in the image?*

We verified this in our devcontainer:
```bash
python --version  # Python 3.12.8
pip --version     # pip 24.3.1
```

**Answer**: 24.3.1

## Question 2: Understanding Docker networking and docker-compose

*What is the `hostname` and `port` that **pgadmin** should use to connect to the postgres database?*

Looking at our docker-compose.yaml:
```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    ...
  pgadmin:
    container_name: pgadmin
    ...
```

Since both services are in the same Docker network, pgAdmin should use:
- **Hostname**: postgres (the container name)
- **Port**: 5432 (the default PostgreSQL port inside the container)

**Answer**: `postgres:5432`

## Question 3: Trip Segmentation Count

*During October 2019, how many trips had these distances?*

Query used:
```sql
SELECT 
    CASE
        WHEN trip_distance <= 1 THEN '0-1 miles'
        WHEN trip_distance > 1 AND trip_distance <= 3 THEN '1-3 miles'
        WHEN trip_distance > 3 AND trip_distance <= 7 THEN '3-7 miles'
        WHEN trip_distance > 7 AND trip_distance <= 10 THEN '7-10 miles'
        ELSE 'over 10 miles'
    END AS distance_category,
    COUNT(*) as number_trips
FROM green_taxi_trips
WHERE lpep_pickup_datetime >= '2019-10-01' 
    AND lpep_pickup_datetime < '2019-11-01'
GROUP BY 1
ORDER BY 1;
```

Results:
- 0-1 miles: 104,838
- 1-3 miles: 199,013
- 3-7 miles: 109,645
- 7-10 miles: 27,688
- over 10 miles: 35,202

**Answer**: Option 5: 104,838; 199,013; 109,645; 27,688; 35,202

## Question 4: Longest trip for each day

*Which was the pick up day with the longest trip distance? Use the pick up time for your calculations.*

Query used:
```sql
SELECT 
    DATE(lpep_pickup_datetime) as pickup_day,
    MAX(trip_distance) as longest_trip
FROM green_taxi_trips
WHERE lpep_pickup_datetime >= '2019-10-01' 
    AND lpep_pickup_datetime < '2019-11-01'
GROUP BY DATE(lpep_pickup_datetime)
ORDER BY longest_trip DESC
LIMIT 1;
```

Results:
- October 31, 2019 had the longest trip of 515.89 miles

## Question 5: Three biggest pickup zones

*Which were the top pickup locations with over 13,000 in total_amount (across all trips) for 2019-10-18?*

Query used:
```sql
SELECT 
    pz."Zone" as pickup_zone,
    SUM(total_amount) as total_amount
FROM green_taxi_trips t
JOIN taxi_zones pz ON t."PULocationID" = pz."LocationID"
WHERE DATE(lpep_pickup_datetime) = '2019-10-18'
GROUP BY 1
HAVING SUM(total_amount) > 13000
ORDER BY total_amount DESC;
```

Results:
- East Harlem North: $18,686.68
- East Harlem South: $16,797.26
- Morningside Heights: $13,029.79


## Question 6: Largest tip

*For the passengers picked up in October 2019 in the zone name East Harlem North, which was the drop off zone that had the largest tip?*

Query used:
```sql
SELECT 
    dz."Zone" as dropoff_zone,
    MAX(tip_amount) as max_tip
FROM green_taxi_trips t
JOIN taxi_zones pz ON t."PULocationID" = pz."LocationID"
JOIN taxi_zones dz ON t."DOLocationID" = dz."LocationID"
WHERE DATE(lpep_pickup_datetime) >= '2019-10-01' 
    AND DATE(lpep_pickup_datetime) < '2019-11-01'
    AND pz."Zone" = 'East Harlem North'
GROUP BY dz."Zone"
ORDER BY max_tip DESC
LIMIT 1;
```

Results:
- JFK Airport had the largest tip amount of $87.30


## Question 7: Terraform Workflow

*Which of the following sequences, respectively, describes the workflow for:*
1. *Downloading the provider plugins and setting up backend*
2. *Generating proposed changes and auto-executing the plan*
3. *Remove all resources managed by terraform*

Analysis of the commands:

1. `terraform init`
   - Initializes a working directory
   - Downloads provider plugins
   - Sets up backend configuration

2. `terraform apply -auto-approve`
   - Generates execution plan
   - Shows proposed changes
   - Auto-approves and executes the changes

3. `terraform destroy`
   - Removes all resources managed by Terraform
   - Proper command for cleanup
   - Ensures complete resource removal

**Answer**: `terraform init`, `terraform apply -auto-approve`, `terraform destroy`
