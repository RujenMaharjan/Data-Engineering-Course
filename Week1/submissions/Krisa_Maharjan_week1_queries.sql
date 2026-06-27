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
 
SELECT count(*) FROM rides r ;


-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.

SELECT DISTINCT r.pickup_city  FROM rides r 
ORDER BY r.pickup_city ASC ;


SELECT r.pickup_city FROM rides r 
GROUP BY r.pickup_city
ORDER BY 1; 


-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.

SELECT * FROM rides r 
WHERE r.fare_amount >500
ORDER BY r.fare_amount DESC;



-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?
-- Add a comment: what does a NULL rating most likely mean?

SELECT * FROM rides r 
WHERE r.rating IS NULL ;

SELECT count(*) FROM rides r 
WHERE r.rating IS NULL ;

-- The null rating is most likely cancelled and no_show ride_status.
-- There is 2379 rides have a null rating.


-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides
-- (hint: order by requested_at, filter by ride_status).

SELECT * FROM rides r 
WHERE r.ride_status  = 'completed'
ORDER BY r.requested_at DESC 
LIMIT 10;


-- ── Query 6 (STRETCH) ─────────────────────────────────────────────
-- Count how many rides exist for each ride_status.
-- (This uses GROUP BY which we haven't covered yet -- figure it out!)

SELECT count(r.ride_id), r.ride_status FROM rides r
GROUP BY r.ride_status;


-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?

SELECT sum(r.fare_amount ) FROM rides r
WHERE r.ride_status = 'completed';

SELECT sum(r.fare_amount ), r.ride_status FROM rides r
WHERE r.ride_status = 'completed'
GROUP BY r.ride_status ;

-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
-- How many are there? Add a comment: are these valid records?

SELECT count(*) FROM rides r 
WHERE r.pickup_city = r.dropoff_city;

SELECT * FROM rides r 
WHERE r.pickup_city = r.dropoff_city;

--192 rides have the same pickup and dropoff city.
-- At first glance these look like errors, but digging into the data
-- reveals a deeper problem: the fare amounts are wildly inconsistent
-- relative to the distance travelled.
--
-- For example, ride_id 105 (Kathmandu → Kathmandu) covered 41.84 km
-- but was only charged 80.33 — that works out to roughly 1.92 per km.
-- Meanwhile, ride_id 200 (also Kathmandu → Kathmandu) covered just
-- 23.58 km yet was charged 503.94 — about 21.37 per km. Two rides in
-- the same city, one less than half the distance of the other, yet
-- charged over 6x more. There is no consistent pricing logic here.
--
-- This is not just a same-city issue. Across all 192 same-city rides,
-- the fare per km ranges from 0.68 all the way up to 553 — a spread
-- that makes no sense for any fixed or distance-based pricing model.
--
-- If left unchecked, this kind of inconsistency will erode passenger
-- trust, make revenue reporting unreliable, and create disputes that
-- are hard to resolve. The fare calculation logic needs to be reviewed
-- and standardised before this data can be relied upon.



