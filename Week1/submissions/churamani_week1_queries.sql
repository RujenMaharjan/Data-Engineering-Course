-- week1_queries.sql
-- Week 1 Assignment
-- Submit this file with all 8 queries filled in.
-- Label each query clearly. Add a comment if your answer
-- reveals something interesting about the data.
--
-- Grading: correctness + NULL handling + clean formatting
-- Due: before Week 2, Day 1

-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?

SELECT
	COUNT(RIDE_ID) as total_rides
FROM
	MYRIDES

-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.

SELECT DISTINCT
	LOWER(PICKUP_CITY) AS PICKUP_CITY
FROM
	MYRIDES
ORDER BY
	PICKUP_CITY

-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.
SELECT
	*
FROM
	MYRIDES
WHERE
	FARE_AMOUNT > 500
ORDER BY
	FARE_AMOUNT DESC

-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?
-- Add a comment: what does a NULL rating most likely mean?

SELECT
	COUNT(RIDE_ID) AS RIDES
FROM
	MYRIDES
WHERE
	RATING IS NULL
-- returns 2379

	-- # WHAT IT MOST LIKELY MEAN.
	-- 1. May be, The ride was cancelled or basically not completed
	-- VERIFICATION

	SELECT
		COUNT(RIDE_ID) AS NON_RATED_RIDES
	FROM
		MYRIDES
	WHERE
		RATING IS NULL
		AND RIDE_STATUS <> 'completed'

	-- returns 2138
	-- which means there are rides (2379 - 2138)
	-- which have completed but have null rating

	-- 2. Above calculation shows that 
	-- completed rides are also non rated,
	-- reason might be because the customer 
	-- have choosen to skip the rating prompt.

	-- # VERIFICATION
	SELECT
		COUNT(RIDE_ID)
	FROM
		MYRIDES
	WHERE
		RIDE_STATUS = 'completed'
		AND RATING IS NULL

	-- returns 241 i.e (2379 - 2138)

-- There can be two cases when rating is null
-- 1. ride never completed
-- 2. customer skipped rating


-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
-- (hint: order by requested_at, filter by ride_status).

	-- # VALIDATION	
	-- lets validate the fact that all rides with completed status 
	-- have not null completed_at
	
	-- 1: ride_status is not null
	SELECT
		*
	FROM
		MYRIDES
	WHERE
		RIDE_STATUS IS NULL
	-- returns 0 rows
	
	-- 2: rows with ride status have not null completed_at
	SELECT
		*
	FROM
		MYRIDES
	WHERE
		RIDE_STATUS = 'completed'
		AND COMPLETED_AT IS NULL
	-- returns 0 rows
	
	-- 3: rows with not null completed_at have ride status completed
	SELECT
		*
	FROM
		MYRIDES
	WHERE
		COMPLETED_AT IS NOT NULL
		AND RIDE_STATUS <> 'completed'
	-- returns 0 rows


-- # SOLUTION
SELECT
	*
FROM
	MYRIDES
WHERE
	COMPLETED_AT IS NOT NULL
ORDER BY
	COMPLETED_AT DESC
LIMIT 10

-- #NOTE:
-- Ordering by completed_at instead of requested_at (the hint) because
-- a ride requested earlier can finish after one requested later.
-- completed_at reflects true recency of completion.


-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)

SELECT
	RIDE_STATUS, -- ride status wont be null as validated before
	COUNT(RIDE_ID) AS RIDE_COUNT
FROM
	MYRIDES
GROUP BY
	RIDE_STATUS




-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?
SELECT
	SUM(FARE_AMOUNT) AS TOTAL_FARE
FROM
	MYRIDES
WHERE
	RIDE_STATUS = 'completed'

-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
-- How many are there? Add a comment: are these valid records?

SELECT
	COUNT(RIDE_ID)
FROM
	MYRIDES
WHERE
	LOWER(PICKUP_CITY) = LOWER(DROPOFF_CITY)
	AND RIDE_DISTANCE > 0
	AND RIDE_STATUS <> 'cancelled' -- ride status are non null as validated before

-- returns 138
-- Yes, same-city rides are valid,
-- they represent intra-city trips
-- (e.g., home to office within Kathmandu). 
-- Cities are large enough for meaningful rides.
-- The questionable records would be same city rides
-- with zero distance or cancelled status.
