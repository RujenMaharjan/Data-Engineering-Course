--DROP TABLE IF EXISTS trips;
--DROP TABLE IF EXISTS drivers;
--DROP TABLE IF EXISTS passengers;
--DROP TABLE IF EXISTS locations;
--DROP TABLE IF EXISTS payment_methods ;


-- Cities that appear as pickup or dropoff locations
CREATE TABLE locations (
    location_id   SERIAL        PRIMARY KEY,
    city_name     VARCHAR(100)   NOT NULL UNIQUE
);

-- Drivers (canonical names, deduped from the flat table)
CREATE TABLE drivers (
    driver_id     SERIAL        PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL
);

-- passenger
CREATE TABLE passengers (
    passenger_id     SERIAL        PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL
);

CREATE TABLE payment_methods (
	payment_method_id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL UNIQUE 
);

-- ─────────────────────────────────────────────────────────────────
-- STEP 2: Create the trips table with foreign keys
-- ─────────────────────────────────────────────────────────────────

CREATE TABLE trips (
    trip_id              SERIAL        PRIMARY KEY,
    driver_id            INTEGER       NOT NULL REFERENCES drivers(driver_id),
    passenger_id         INTEGER       NOT NULL REFERENCES passengers(passenger_id),
    pickup_location_id   INTEGER       NOT NULL REFERENCES locations(location_id),
    dropoff_location_id  INTEGER       NOT NULL REFERENCES locations(location_id),
    fare_amount          NUMERIC(10,2) NOT NULL CHECK (fare_amount > 0),
    distance_km          NUMERIC(6,2)  NOT NULL,
    status               varchar(50)   NOT NULL CHECK (status IN ('completed','cancelled','no_show')),
    requested_at         TIMESTAMP     NOT NULL,
    completed_at         TIMESTAMP,
    rating               NUMERIC(2,1)  CHECK (rating BETWEEN 1.0 AND 5.0),
    payment_method_id    INTEGER       REFERENCES payment_methods(payment_method_id)
);


---- migration 

INSERT INTO drivers (name)
SELECT
	DISTINCT INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))
FROM
	rides r;

INSERT INTO passengers (name)
SELECT
	DISTINCT INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))
FROM
	rides r;


INSERT INTO locations(city_name)
SELECT DISTINCT(pickup_city) FROM rides r 
UNION 
SELECT DISTINCT(dropoff_city ) FROM rides r ;

INSERT INTO payment_methods (name)
select DISTINCT payment_method FROM rides
WHERE payment_method IS NOT NULL ;

INSERT INTO trips (
	driver_id,
	passenger_id,
	pickup_location_id,
	dropoff_location_id,
	fare_amount,
	distance_km,
	status,
	requested_at,
	completed_at,
	rating,
	payment_method_id
)
SELECT 
(SELECT  driver_id 
	FROM drivers d 
	 WHERE d.name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))) driver_id,
(SELECT  passenger_id 
		FROM passengers p
	 WHERE p.name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))) passenger_id,
(SELECT  location_id  
		FROM locations p
	 WHERE p.city_name = r.pickup_city ) pickup_location_id,
(SELECT  location_id  
		FROM locations p
	 WHERE p.city_name = r.dropoff_city ) dropoff_location_id,
fare_amount,
ride_distance_km,
ride_status,
requested_at,
completed_at,
rating,
(SELECT  payment_method_id  
		FROM payment_methods pm  
		WHERE pm.name = r.payment_method  ) payment_method_id
FROM rides r;


SELECT * FROM trips;