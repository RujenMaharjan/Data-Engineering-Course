-- week3_reliability.sql
-- Week 3 Assignment
-- Submit TWO files:
--   1. week3_reliability.sql  (this file — SQL tasks)
--   2. transactional_loader.py (Python task — Q5)
--
-- All SQL runs against the normalized schema from Week 2
-- (drivers, riders, locations, trips)

-- ─────────────────────────────────────────────────────────────────
-- Q1: Add indexes to the trips table
--
-- Before adding ANY index, run EXPLAIN ANALYZE on each query below
-- and record the execution time in a comment.
-- Then add your indexes and run EXPLAIN ANALYZE again.
-- The comparison IS the answer — not just the CREATE INDEX statement.
-- ─────────────────────────────────────────────────────────────────

-- Baseline queries — run EXPLAIN ANALYZE on each BEFORE indexing:

-- Query A: filter by driver
EXPLAIN ANALYZE
SELECT * FROM trips WHERE driver_id = 3;

-- Query B: filter by status
EXPLAIN ANALYZE
SELECT * FROM trips WHERE status = 'cancelled';

-- Query C: filter by driver AND status (common in the pipeline)
EXPLAIN ANALYZE
SELECT * FROM trips
WHERE driver_id = 3 AND status = 'completed';

-- YOUR INDEXES HERE:
-- (add indexes, then re-run the EXPLAIN ANALYZE queries above)

CREATE INDEX idx_trips_driver_id ON trips(driver_id);

CREATE INDEX idx_trips_ride_status ON trips(status);

CREATE INDEX idx_trips_statusanddriver ON trips(driver_id,status);

-- Record results in comments, e.g.:
-- Query A before: Seq Scan, execution time = X ms
-- Query A after:  Index Scan using ..., execution time = Y ms

Query A BEFORE: Seq Scan, Execution Time: 9.663 ms
Query A AFTER: Execution Time: 1.234 ms

Query B BEFORE: Seq Scan, Execution Time: 1.690 ms
Query B AFTER: Bitmap Heap Scan, Execution Time: 1.368 ms

Query C BEFORE: Seq Scan, Execution Time: 0.735 ms
Query C AFTER: Bitmap Heap Scan, Execution Time: 0.228 ms

-- ─────────────────────────────────────────────────────────────────
-- Q2: Create completed_trips_view
--
-- Must return only completed trips with ALL of these columns:
--   trip_id, driver_name, rider_name,
--   pickup_city, dropoff_city,
--   fare_amount, distance_km, rating,
--   payment_method, requested_at, completed_at
--
-- No IDs in the output — use JOINs to resolve all foreign keys.
-- ─────────────────────────────────────────────────────────────────

-- YOUR VIEW HERE:
CREATE OR REPLACE VIEW completed_trips_view  AS
SELECT
	t.trip_id,
	d."name" AS driver_name,
	p."name" AS passenger_name,
	l1.city_name AS pickup_city,
	l2.city_name AS dropoff_city,
	t.fare_amount,
	t.distance_km,
	t.rating,
	pm."name" AS payment_method,
	t.requested_at,
	t.completed_at
FROM
	trips t
INNER JOIN drivers d ON
	t.driver_id = d.driver_id
INNER JOIN passengers p ON
	t.passenger_id = p.passenger_id
INNER JOIN locations l1 ON
	l1.location_id = t.pickup_location_id
INNER JOIN locations l2 ON
	t.dropoff_location_id = l2.location_id
INNER JOIN payment_methods pm ON 
	t.payment_method_id = pm.payment_method_id
WHERE
	t.status = 'completed'
;

SELECT * FROM completed_trips_view LIMIT 5;

SELECT count(*) FROM completed_trips_view;
--2862

-- Verify:
-- SELECT * FROM completed_trips_view LIMIT 5;
-- SELECT COUNT(*) FROM completed_trips_view;
-- Expected count: ~2862 (all completed trips)


-- ─────────────────────────────────────────────────────────────────
-- Q3: Create driver_summary view
--
-- Must show one row per driver with:
--   driver_name
--   total_trips          (all statuses)
--   completed_trips
--   cancelled_trips
--   cancellation_rate    (cancelled / total * 100, rounded to 1dp)
--   avg_fare             (completed trips only, rounded to 2dp)
--   avg_rating           (completed trips only, rounded to 1dp)
--
-- Challenge: use COUNT(*) FILTER (WHERE ...) instead of CASE WHEN
-- ─────────────────────────────────────────────────────────────────

-- YOUR VIEW HERE:
CREATE OR REPLACE VIEW driver_summary AS 
SELECT
	d."name" AS Driver_Name,
	count(t.trip_id) AS total_trips,
	count(t.trip_id) FILTER (WHERE t.status = 'completed') AS completed_trips,
	count(t.trip_id) FILTER (WHERE t.status = 'cancelled') AS cancelled_trips,
	COALESCE(count(t.trip_id) FILTER (WHERE t.status = 'cancelled') * 100/ NULLIF(count(t.trip_id),0),0) AS Cancellation_rate,
	ROUND(avg(t.fare_amount),2) AS avg_fare,
	ROUND(avg(t.rating),1) AS avg_rating
FROM
	drivers d
LEFT JOIN trips t ON
	t.driver_id = d.driver_id
GROUP BY d.driver_id;

-- Verify:
-- SELECT * FROM driver_summary ORDER BY completed_trips DESC;

SELECT * FROM driver_summary ORDER BY completed_trips DESC;

-- ─────────────────────────────────────────────────────────────────
-- Q4: Transaction with intentional failure
--
-- Write a transaction that:
--   1. Inserts a new driver named 'Test Driver'
--   2. Inserts 3 valid trips for that driver
--   3. Inserts a 4th trip with rating = 99 (violates CHECK constraint)
--
-- The entire transaction should roll back.
-- Verify with: SELECT * FROM drivers WHERE name = 'Test Driver';
-- Expected: 0 rows (atomicity — nothing committed)
-- ─────────────────────────────────────────────────────────────────

-- YOUR TRANSACTION HERE:
BEGIN;

INSERT
	INTO
	drivers(name)
VALUES ('Test Driver');

INSERT INTO  trips(driver_id, status, fare_amount, rating)
VALUES
		(101,'completed',101,5),
		(101,'completed',101,4),
		(101,'completed',101,3)
		(101,'completed',101,99)

COMMIT;

-- Verification query:
SELECT
    'drivers' AS tbl,
    COUNT(*) AS test_driver_rows
FROM drivers
WHERE name = 'Test Driver'
UNION ALL
SELECT 'trips', COUNT(*)
FROM trips t
JOIN drivers d ON t.driver_id = d.driver_id
WHERE d.name = 'Test Driver';

-- Expected: 0 / 0
--Actual: 0/0

-- ─────────────────────────────────────────────────────────────────
-- Q6 (STRETCH): Window function — running total fare per driver
--
-- For each completed trip, show:
--   trip_id, driver_name, requested_at, fare_amount,
--   running_total_fare (driver's cumulative fare up to this trip)
--
-- Use: SUM(fare_amount) OVER (PARTITION BY driver_id ORDER BY requested_at)
-- Order the final output by driver_name, requested_at
-- ─────────────────────────────────────────────────────────────────

-- YOUR QUERY HERE:
SELECT
	t.trip_id,
	d."name" AS Driver_name ,
	t.requested_at,
	t.fare_amount,
	SUM(t.fare_amount) OVER (PARTITION BY d.driver_id ORDER BY t.requested_at) AS Running_total_fare
FROM
	drivers d
LEFT JOIN trips t ON
	d.driver_id = t.driver_id
WHERE
	t.status = 'completed'
ORDER BY
	d."name",
	t.requested_at ;