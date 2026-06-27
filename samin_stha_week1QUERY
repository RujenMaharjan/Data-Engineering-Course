
select *
 from rides;
 
 
-- week1_queries.sql


-- ── Query 1 ───────────────────────────────────────────────────────
-- How many total rides are in the dataset?

SELECT count(*) -- In order to get total rides i choose count function as it count the number of selected entity in the query.
FROM rides
-- Therefore there are 5,001 rides in the database as shown in the output.


-- ── Query 2 ───────────────────────────────────────────────────────
-- List all unique pickup cities, sorted alphabetically.
SELECT DISTINCT(pickup_city) -- Distinct function is used in query as it helps us to find unique element withing the entity.
FROM rides
ORDER BY pickup_city;
--Therefore there are 10 different unique pick up city within the data base as shown in the output.


-- ── Query 3 ───────────────────────────────────────────────────────
-- Show all rides where the fare was above 500, ordered by fare descending.
SELECT  *  --Used where, order by and desc function in order to completed the query.
FROM rides 
WHERE fare_amount >500 
ORDER BY fare_amount DESC;

-- As per the data or output shown, There are some null value within the dataset as there are some incomplete data in ride like  completed at, rating and payement method.
--Where as i find that rest of the entity are not having any null value.The highest fare is 2,985.15 and lowest is 500.03.


-- ── Query 4 ───────────────────────────────────────────────────────
-- How many rides have a NULL rating?

 SELECT count(*) --Used count function inorder to get the number of count in  rating.
 FROM rides 
 WHERE rating IS NULL;

-- Therefore,there are 2,379 Null rating in the rides.As from my understanding those people who did not provide any rating to the riders is defined as null rating.

-- ── Query 5 ───────────────────────────────────────────────────────
-- Show the 10 most recent completed rides

SELECT *
FROM rides    --NEW FUNCTION USED IS LIMIT 10 WHERE IT SHOWS ONLY THE TOP 10 DATA IN DATABASE
WHERE ride_status = 'completed'
ORDER BY ride_status DESC
LIMIT 10;
 --Therefore there are 7 different rider who completed rides in recent days.with one repeatation of customer. who rode for 3 different times.with most pick up point lalitpur.


-- ── Query 6 (STRETCH) ─────────────────────────────────────────────

SELECT  count(*),ride_status --used group by function as it separated different element in an entity.
FROM rides 
GROUP BY ride_status;

--theefore u can see in output 3 different element.

-- ── Query 7 ───────────────────────────────────────────────────────
-- What is the total fare collected across completed rides only?
SELECT sum(fare_amount) --used sum function as i add up all the number in data
FROM rides
WHERE ride_status = 'completed';


-- ── Query 8 ───────────────────────────────────────────────────────
-- Find rides where pickup_city and dropoff_city are the same.
-- How many are there? Add a comment: are these valid records?
SELECT count(*)
FROM rides 
WHERE pickup_city = dropoff_city;

--there are 192 in the records. the data is inconsistent so i donot think it is valid.
