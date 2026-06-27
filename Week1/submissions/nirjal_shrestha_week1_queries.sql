-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?

SELECT COUNT(*) AS total_rides
FROM rides;


-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.

SELECT DISTINCT pickup_city
FROM rides
ORDER BY pickup_city ASC;


-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.

SELECT *
FROM rides
WHERE fare_amount > 500
ORDER BY fare_amount DESC;


-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?

SELECT COUNT(*) AS null_ratings
FROM rides
WHERE rating IS NULL;

-- Add a comment: what does a NULL rating most likely mean?
-- NULL ratings most likely mean the ride has not been rated yet.


-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
-- (hint: order by requested_at, filter by ride_status).

SELECT *
FROM rides
WHERE ride_status = 'completed'
ORDER BY requested_at DESC
LIMIT 10;


-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)

SELECT ride_status,
       COUNT(*) AS total_rides
FROM rides
GROUP BY ride_status
ORDER BY total_rides DESC;


-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?

SELECT SUM(fare_amount) AS total_fare_collected
FROM rides
WHERE ride_status = 'completed';


-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.

SELECT *
FROM rides
WHERE pickup_city = dropoff_city;

-- How many are there?

SELECT COUNT(*) AS same_city_rides
FROM rides
WHERE pickup_city = dropoff_city;

--  Add a comment: are these valid records?
-- Yes because a ride can start and end 
-- within the same city, especially in large cities.