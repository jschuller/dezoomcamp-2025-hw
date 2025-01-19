-- Basic data verification queries

-- Count of records by day
SELECT 
    DATE(lpep_pickup_datetime) as day,
    COUNT(*) as trips,
    AVG(trip_distance) as avg_distance,
    AVG(total_amount) as avg_amount
FROM green_taxi_trips
GROUP BY day
ORDER BY day;

-- Distribution of trip distances
-- Homework Question 3: During October 2019, how many trips had these distances?
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

-- Homework Question 6: Largest tip for trips from East Harlem North
-- First, let's look at the top tips in detail
WITH tips_by_zone AS (
    SELECT 
        dz."Zone" as dropoff_zone,
        t.tip_amount,
        t.total_amount,
        t.lpep_pickup_datetime,
        t.lpep_dropoff_datetime,
        t.trip_distance
    FROM green_taxi_trips t
    JOIN taxi_zones pz ON t."PULocationID" = pz."LocationID"
    JOIN taxi_zones dz ON t."DOLocationID" = dz."LocationID"
    WHERE DATE(lpep_pickup_datetime) >= '2019-10-01' 
        AND DATE(lpep_pickup_datetime) < '2019-11-01'
        AND pz."Zone" = 'East Harlem North'
    ORDER BY tip_amount DESC
    LIMIT 5
)
SELECT *
FROM tips_by_zone;

-- Then get just the zone with the highest tip
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

-- Homework Question 4: Which was the pick up day with the longest trip distance?
SELECT 
    DATE(lpep_pickup_datetime) as pickup_day,
    MAX(trip_distance) as longest_trip
FROM green_taxi_trips
WHERE lpep_pickup_datetime >= '2019-10-01' 
    AND lpep_pickup_datetime < '2019-11-01'
GROUP BY DATE(lpep_pickup_datetime)
ORDER BY longest_trip DESC
LIMIT 1;

