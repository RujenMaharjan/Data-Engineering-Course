-- week1_queries.sql
-- Week 1 Assignment

-- Grading: correctness + NULL handling + clean formatting
-- Due: before Week 2, Day 1



-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?

SELECT 
	count(ride_id) AS total_rides
FROM
	rides;

--Output: 5000




-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.

SELECT
	DISTINCT pickup_city AS pickup_cities
FROM 
	rides
ORDER BY 
	pickup_city ASC;

--Output: 
--Bhaktapur
--Biratnagar
--Birgunj
--Butwal
--Chitwan
--Hetauda
--Kathmandu
--Kirtipur
--Lalitpur
--Pokhara




-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.

SELECT 
	*
FROM
	rides 
WHERE
	fare_amount >500
ORDER BY
	fare_amount DESC;

-- Remarks: There are 2096 rides with fare >500, highest being 2985.15 and the lowest being 500.03




-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?
-- Add a comment: what does a NULL rating most likely mean?

SELECT 
	count(*)
FROM 
	rides
WHERE 
	rating IS NULL;

--Output: 2379

-- Remarks: A NULL rating most likely mean one of the following:
-- 1. Ride is completed, yet the rider decides not to rate.
-- 2. Cancelled ride.
-- 3. Rider no-show.
-- 4. App/system crash/error.




-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
-- (hint: order by requested_at, filter by ride_status).

SELECT 
	*
FROM 
	rides
WHERE 
	ride_status = 'completed'
ORDER BY
	requested_at DESC --For accurate data for completed rides, better to sort by completed_at
LIMIT 
	10;

--Remarks: The most recently completed ride was on 2024-12-31 03:27:00.206 requested at 2024-12-31 01:59:33.00




-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)

SELECT 
	ride_status,
	count(*) AS Total_rides_per_Status
FROM 
	rides
GROUP BY 
	ride_status;

--Output:
--ride_status   total_rides_per_status
--completed	    2862
--cancelled	    1408
--no_show	    730




-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?

SELECT 
	SUM(fare_amount) AS Total_fare_collected
FROM 
	rides
WHERE 
	ride_status = 'completed';

-- Output: 
--total_fare_collected
--1430112.40

-- Remarks: NULLs in SUM are ignored by SQL, so even if the fare_amount is NULL, it won't affect the sum.




-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
-- How many are there? Add a comment: are these valid records?


---- rides where pickup_city and dropoff_city are the same

SELECT 
	*
FROM 
	rides
WHERE 
	pickup_city IS NOT null
	AND dropoff_city IS NOT NULL
	AND pickup_city = dropoff_city ;



----number of rides where pickup_city and the dropoff_city are the same

SELECT 
	count(*) AS Total_same_city_rides
FROM 
	rides
WHERE 
	pickup_city IS NOT null
	AND dropoff_city IS NOT NULL
	AND pickup_city = dropoff_city ;

--Output: 192

--Remarks:
-- These data could be valid for short trips like intracity travel.
-- These data could be invalid if there is data entry error or geolocation mapping issue.

