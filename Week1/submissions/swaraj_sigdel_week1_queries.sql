
-- Week 1 Assignment

-- ── Query 1 ───────────────────────────────────────────────────────
-- Question: How many total rides are in the dataset?

SELECT
    count(*)
FROM
    rides;   -- Output: 5000


-- ── Query 2 ───────────────────────────────────────────────────────
-- Question: List all unique pickup cities, sorted alphabetically.

SELECT
    DISTINCT pickup_city
FROM
    rides
ORDER BY
    pickup_city ASC;


-- ── Query 3 ───────────────────────────────────────────────────────
-- Question: Show all rides where the fare was above 500,
-- ordered by fare in descending order.

SELECT
    *
FROM
    rides
WHERE
    fare_amount > 500
ORDER BY
    fare_amount DESC;


-- ── Query 4 ───────────────────────────────────────────────────────
-- Question: How many rides have a NULL rating?

SELECT
    count(*)
FROM
    rides
WHERE
    rating IS NULL;   -- Output: 2379 rides

-- Interpretation:
-- A NULL rating may indicate:
--   • The ride was not rated by the passenger.
--   • The ride was cancelled or marked as no_show.
--   • The system failed to capture or store the feedback.


-- ── Query 5 ───────────────────────────────────────────────────────
-- Question: Show the 10 most recent completed rides.

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
-- Question: Count how many rides exist for each ride_status.

SELECT
    ride_status,
    count(*) AS count_ride_status
FROM
    rides
GROUP BY
    ride_status;


-- ── Query 7 ───────────────────────────────────────────────────────
-- Question: What is the total fare collected across completed rides only?

SELECT
    sum(fare_amount)
FROM
    rides
WHERE
    ride_status = 'completed';   -- Output: 1,430,112.40


-- ── Query 8 ───────────────────────────────────────────────────────
-- Question: Find rides where pickup_city and dropoff_city are the same.

SELECT
    *
FROM
    rides
WHERE
    pickup_city = dropoff_city;


-- Follow-up: How many such rides are there, and are these valid records?

SELECT
    count(*)
FROM
    rides
WHERE
    pickup_city = dropoff_city;

-- There are 192 rides where the pickup and dropoff cities are the same.
-- These can be valid records for short trips within a single city.
-- However, some of these rides have relatively high ride_distance_km values,
-- which may be unusual for same-city trips and worth investigating
-- for possible data quality issues.