-- week1_queries.sql
-- Week 1 Assignment

-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?

select
	count(*) as total_rides
from
	rides;
--Output: There are 5000 total rides in the dataset. 


-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.

select
	distinct pickup_city
from
	rides r
order by
	pickup_city asc;



-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.

select
	*
from
	rides r
where
	fare_amount > 500
order by
	fare_amount desc;



-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?
-- Add a comment: what does a NULL rating most likely mean?
select
	count(*) as total_null_rating
from
	rides
where
	rating is null;

---Output: A total of 2379 rides have a NULL rating.
---The Null value here likely signify two scenarios: either the passenger has skipped the rating or the ride was cancelled. 

-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
-- (hint: order by requested_at, filter by ride_status).
select
	*
from
	rides r
where
	ride_status = 'completed'
order by
	requested_at desc
limit 10;



-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)
select
	ride_status,
	count(*) 
from
	rides
group by
	ride_status;

---Output: The individual total count of each of the ride_status are as follows: 
-- completed= 2,862, cancelled= 1,408, and no_show= 730. 

-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?

select
	sum(fare_amount) as total_fare
from
	rides r
where
	ride_status = 'completed';

---Output: The total fare collected solely across the completed rides is 1430112.40.


-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
-- How many are there? Add a comment: are these valid records?

select
	count(*) as total_same_city_rides
from
	rides r
where
	pickup_city = dropoff_city;

select
	count(*) 
from
	rides r
where
	pickup_city = dropoff_city
	and ride_status = 'no_show';

select
	count(*)
from
	rides r
where
	pickup_city = dropoff_city
	and ride_status = 'completed';


---Output: There are total of 192 rides where the pickup_city and dropoff_city are the same.
-- The records are valid if we are just observing the count, rides frequently start and end within the same city.
--However, if we look into the rides that were actually fulfilled: only 100 rides had the status 'completed', 
-- while the remaining 92 resulted in a 'no_show'.

---Now taking distance and fare into account:

SELECT
    ride_status, 
    COUNT(*) AS total_same_city_rides, 
    ROUND(AVG(ride_distance_km), 2) AS avg_distance,
    MIN(ride_distance_km) AS min_distance,
    MAX(ride_distance_km) AS max_distance, 
    ROUND(AVG(fare_amount), 2) AS avg_amount, 
    MIN(fare_amount) AS min_amount, 
    MAX(fare_amount) AS max_amount
FROM rides
WHERE pickup_city = dropoff_city 
GROUP BY ride_status;


---The data records are completely invalid for 'cancelled' and 'no_show' statuses.
-- The system is incorrectly tracking distances and charging full fares for passengers who either cancelled or never showed up.
-- This glitch is so severe that the average distance (23.89 km) and fare (579.03) of unfulfilled rides are actually higher 
-- than those of completed ones.