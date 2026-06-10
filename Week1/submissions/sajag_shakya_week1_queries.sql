-- sajag_shakya_week1_queries.sql
-- Week 1 Assignment
-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?

SELECT
	count(*)
FROM
	rides;	--output=5000


-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.

SELECT
	DISTINCT pickup_city
FROM
	rides
ORDER BY
	pickup_city ASC;


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


-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?
SELECT
	count(*)
FROM
	rides
WHERE
	rating IS NULL; --2379 rides

-- A NULL rating may mean any of the following:
--		ride was not rated by the passenger
--		ride was cancelled/ no_show
--		system may have failed to store feedback



-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
SELECT
	*
FROM
	rides r
WHERE
	ride_status = 'completed'
ORDER BY
	requested_at DESC
LIMIT 10;



-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)

SELECT
	ride_status,
	count(*) AS count_ride_status
FROM
	rides
GROUP BY
	ride_status;


-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?

SELECT
	sum(fare_amount)
FROM
	rides
WHERE
	ride_status = 'completed'; -- output = 1430112.40


-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
	SELECT
	*
FROM
	rides
WHERE
	pickup_city = dropoff_city;


-- How many are there? Add a comment: are these valid records?
SELECT
	count(*)
FROM
	rides
WHERE
	pickup_city = dropoff_city; 
-- There are 192 such rides where pickup and dropoff cities are the same
-- These may be valid records for short trips within the same city. 
-- But, some records seem to have a higher 'ride_distance_km' which is not likely for same city trips
-- so it should be further verified for possible inconsistencies.
