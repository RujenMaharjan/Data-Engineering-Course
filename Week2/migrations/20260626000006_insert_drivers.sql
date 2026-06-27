INSERT INTO drivers (name)
SELECT DISTINCT INITCAP(TRIM(REGEXP_REPLACE(r.driver_name, '\s+', ' ', 'g')))
FROM rides r
ON CONFLICT DO NOTHING;
