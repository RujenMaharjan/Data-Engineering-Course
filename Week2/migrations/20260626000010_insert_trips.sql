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
    d.driver_id,
    p.passenger_id,
    pl.location_id,
    dl.location_id,
    r.fare_amount,
    r.ride_distance_km,
    r.ride_status,
    r.requested_at,
    r.completed_at,
    r.rating,
    pm.payment_method_id
FROM rides r
JOIN drivers d
    ON d.name = INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))
JOIN passengers p
    ON p.name = INITCAP(TRIM(REGEXP_REPLACE(r.passenger_name, '\s+', ' ', 'g')))
JOIN locations pl
    ON pl.city_name = r.pickup_city
JOIN locations dl
    ON dl.city_name = r.dropoff_city
LEFT JOIN payment_methods pm
    ON pm.name = r.payment_method;
