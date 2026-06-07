--Student name: Aditya Shanker Shrestha
--Week:1
--Queries completed: Q1–Q8
--Stretch attempted: Yes 

-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?


-- All rides recorded.
SELECT COUNT(*) AS total_rides FROM rides;


-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.


-- The dataset contains only major metro and sub-metro cities, rides data based on Nepal's primary urban areas.
SELECT DISTINCT pickup_city
FROM rides
ORDER BY pickup_city;


-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.


-- Data towards the top fares consists prominent rides of routes between cities.
-- No confidence for correlation between distance travelled and fare amount.
SELECT
    ride_id,
    driver_name,
    passenger_name,
    pickup_city,
    dropoff_city,
    fare_amount,
    ride_distance_km,
    ride_status,
    requested_at,
    completed_at,
    rating,
    payment_method
FROM rides
WHERE fare_amount > 500
ORDER BY fare_amount DESC;


-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?
-- Add a comment: what does a NULL rating most likely mean?


-- NULL ratings could be  most of the cases when the ride was cancelled or was a "no_show".
-- other times  completed rides where no rating was submitted by the user.
-- Number of Null ratings is 2379
SELECT COUNT(*)
FROM rides
WHERE rating IS NULL;


-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
-- (hint: order by requested_at, filter by ride_status).

-- initally made a mistake regarding not using IS NOT NULL, therefore realized that without null checks DESC sorts NULL values first.
-- limitation is that completed_at is not a true indicator of ride completion status
SELECT
    ride_id,
    driver_name,
    passenger_name,
    pickup_city,
    dropoff_city,
    fare_amount,
    ride_distance_km,
    ride_status,
    requested_at,
    completed_at,
    rating,
    payment_method
FROM rides
WHERE completed_at IS NOT NULL
ORDER BY requested_at DESC
LIMIT 10;
-- ALTERNATIVE QUERY WITH SAME RESULT ; 
SELECT
    ride_id,
    driver_name,
    passenger_name,
    pickup_city,
    dropoff_city,
    fare_amount,
    ride_distance_km,
    ride_status,
    requested_at,
    completed_at,
    rating,
    payment_method
FROM rides
WHERE ride_status = 'completed'
ORDER BY requested_at DESC
LIMIT 10;



-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)

-- no_show + cancelled = 1408 + 730 = 2318 ~ Number of Null rating from q.4.
-- NULL ratings are  correlated with cancellations and no-shows, but may also include completed rides without user feedback. 
-- Therefore gives the explanation of for most of the number of null ratings a strong proposition. 
-- completed: 2862
SELECT ride_status, COUNT(*)
FROM rides
GROUP BY ride_status;

-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?

-- total fare raised : Rs. 14,30,112.40 Over 5,000 rides. 
-- Avg fare per completed ride = Rs.499.69
SELECT SUM(fare_amount)
FROM rides
WHERE ride_status = 'completed';


-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
-- How many are there? Add a comment: are these valid records?

-- these rides are valid: inside a city there are multiple locations to route a travel the user requires.
SELECT
    ride_id,
    driver_name,
    passenger_name,
    pickup_city,
    dropoff_city,
    fare_amount,
    ride_distance_km,
    ride_status,
    requested_at,
    completed_at,
    rating,
    payment_method
FROM rides
WHERE pickup_city = dropoff_city;

SELECT COUNT(*) FROM rides WHERE pickup_city = dropoff_city ;
