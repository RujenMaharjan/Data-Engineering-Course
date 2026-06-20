-- week2_queries.sql
-- Week 2 Assignment


/* TABLE CREATION */

--Create table location
CREATE TABLE locations(
	location_id SERIAL PRIMARY KEY,
	city_name VARCHAR(100) NOT NULL UNIQUE 	
);

--Create Table Driver
CREATE TABLE drivers(
	driver_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);


--CREATE TABLE passanger
CREATE TABLE passengers(
	passenger_id SERIAL PRIMARY KEY,
	name Varchar(100) NOT NULL
);

--Create table payment  method
CREATE TABLE payment_methods (
	payment_method_id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL UNIQUE 
);

--Create table trips with Foreign Key Constraints
CREATE TABLE trips(
	trip_id SERIAL PRIMARY KEY,
	driver_id INTEGER NOT NULL REFERENCES drivers(driver_id),
    passenger_id INTEGER NOT NULL REFERENCES passengers(passenger_id),
    pickup_location_id INTEGER NOT NULL REFERENCES locations(location_id),
    dropoff_location_id INTEGER NOT NULL REFERENCES locations(location_id),
    fare_amount NUMERIC(10, 2) NOT NULL CHECK (fare_amount > 0),
    distance_km NUMERIC(6, 2) NOT NULL,
    status varchar(50) NOT NULL CHECK (status IN ('completed', 'cancelled', 'no_show')),
    requested_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    rating NUMERIC(2, 1) CHECK (rating BETWEEN 1.0 AND 5.0),
    payment_method_id INTEGER REFERENCES payment_methods(payment_method_id)
);




/* DATA INSERTION */

--Driver Table
INSERT
	INTO
	drivers(name)
SELECT
	DISTINCT(initcap(Trim(regexp_replace(driver_name, '\s+', ' ', 'g'))))
FROM
	rides;




--Passenger Table
INSERT
	INTO
	passengers(name)
SELECT
	DISTINCT(initcap(Trim(regexp_replace(passenger_name, '\s+', ' ', 'g'))))
FROM
	rides;



--Location Table
INSERT
	INTO
	locations(city_name)
SELECT
	DISTINCT(initcap(Trim(regexp_replace(pickup_city, '\s+', ' ', 'g'))))
FROM
	rides
UNION
SELECT
	DISTINCT(initcap(Trim(regexp_replace(dropoff_city, '\s+', ' ', 'g'))))
FROM
	rides;



--Payment method table
INSERT
	INTO
	payment_methods(name)
SELECT
	DISTINCT(initcap(Trim(regexp_replace(payment_method, '\s+', ' ', 'g'))))
FROM
	rides
WHERE
	payment_method IS NOT NULL;




--Trip Table
INSERT
	INTO
	trips (
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
	(
	SELECT
		driver_id
	FROM
		drivers d
	WHERE
		d.name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))) driver_id,
	(
	SELECT
		passenger_id
	FROM
		passengers p
	WHERE
		p.name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))) passenger_id,
	(
	SELECT
		location_id
	FROM
		locations p
	WHERE
		p.city_name = r.pickup_city ) pickup_location_id,
	(
	SELECT
		location_id
	FROM
		locations p
	WHERE
		p.city_name = r.dropoff_city ) dropoff_location_id,
	fare_amount,
	ride_distance_km,
	ride_status,
	requested_at,
	completed_at,
	rating,
	(
	SELECT
		payment_method_id
	FROM
		payment_methods pm
	WHERE
		pm.name = INIzTCAP(TRIM(REGEXP_REPLACE(r.payment_method, '\s+', ' ', 'g')))) payment_method_id
FROM
	rides r;
