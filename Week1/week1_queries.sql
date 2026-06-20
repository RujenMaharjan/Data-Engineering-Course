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
	count(ride_id) AS total_rides
FROM
	rides;


-- ── Query 2 ───────────────────────────────────────────────────────
	-- List all unique pickup cities, sorted alphabetically.

SELECT
	DISTINCT pickup_city AS pickup_cities
FROM
	rides
ORDER BY
	pickup_city;


-- ── Query 3 ───────────────────────────────────────────────────────
	-- Show all rides where the fare was above 500, ordered by fare descending.

SELECT
	ride_id,
	driver_name ,
	passenger_name ,
	pickup_city ,
	dropoff_city ,
	fare_amount,
	payment_method
FROM
	rides
WHERE
	fare_amount >500
ORDER BY
	fare_amount DESC;


-- ── Query 4 ───────────────────────────────────────────────────────
	-- How many rides have a NULL rating?

SELECT
	COUNT(ride_id)
FROM
	rides
WHERE
	rating IS NULL;

/*Ans: It might mean three things i.e., ride was cancelled, driver or passenger didn't show up or passenger forgot or
refused to rate driver.*/


-- ── Query 5 ───────────────────────────────────────────────────────
	-- Show the 10 most recent completed rides
	-- (hint: order by requested_at, filter by ride_status).

SELECT
	ride_id,
	driver_name,
	passenger_name,
	requested_at,
	completed_at
FROM
	rides
WHERE
	requested_at IS NOT NULL
	AND ride_status = 'completed'
ORDER BY
	requested_at DESC
LIMIT 10;


-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)

SELECT
	Ride_status,
	count(ride_status) AS Status_Count
FROM
	rides
GROUP BY
	ride_status;


-- ── Query 7 ───────────────────────────────────────────────────────
	-- What is the total fare collected across completed rides only?

SELECT
	SUM(fare_amount) AS Total_Fare_Collected
FROM
	rides
WHERE
	ride_status = 'completed';


-- ── Query 8 ───────────────────────────────────────────────────────
	-- Find rides where pickup_city and dropoff_city are the same.
	-- How many are there? Add a comment: are these valid records?

--Total ride with same pickup and dropoff city

SELECT
	ride_id,
	driver_name ,
	passenger_name ,
	pickup_city ,
	dropoff_city,
	ride_distance_km,
	fare_amount
FROM
	rides
WHERE
	pickup_city = dropoff_city;


--Number of ride with same pickup and dropoff city

SELECT
	count(ride_id)
FROM
	rides
WHERE
	pickup_city = dropoff_city;


--Average fareprice comparision per M. between whole dataset and data with same pickup and drop cities.

SELECT
	avg(fare_amount / ride_distance_km) AS Fare_Price_Per_KM_Whole
FROM
	rides;

SELECT
	avg(fare_amount / ride_distance_km) AS Fare_Price_Per_KM_WithinCity
FROM
	rides
WHERE
	pickup_city = dropoff_city ;

/* Ans: Analysing the data, Yes these 192 records seems valid. My strongest argument would be comparing the average fare price
 per kilometer between the whole dataset and the data with the same pickup and dropoff cities, as the outputs came out very
 similar around RS. 41.83/km across the board versus RS. 38.60/km for same-city rides. Next, booking intracity rides is completely
 normal and expected in any ride-sharing app since people constantly travel within the same city. Lastly, the ride distances
 themselves look very realistic, proving that these aren't system glitches but actual, genuine trips.*/
