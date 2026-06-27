INSERT INTO locations (city_name)
SELECT DISTINCT pickup_city  FROM rides
UNION
SELECT DISTINCT dropoff_city FROM rides
ON CONFLICT DO NOTHING;
