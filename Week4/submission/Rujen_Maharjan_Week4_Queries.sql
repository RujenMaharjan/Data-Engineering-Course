--Revenue by city/month

--On Warehouse

SELECT
	dl.city_name ,
	dd.month_name ,
	sum(ft.fare_amount) AS total_revenue
FROM
	fact_trips ft
INNER JOIN dim_date dd ON
	ft.date_key = dd.date_key
INNER JOIN dim_location dl ON
	ft.pickup_location_key = dl.location_key
GROUP BY
	dl.city_name,
	dd.month_name 
ORDER BY
	dl.city_name;

--On OLTP

SELECT
	l.city_name,
	EXTRACT(MONTH FROM t.requested_at ) AS MONTH,
	ROUND(SUM(base_fare * surge_multiplier + tip_amount - discount_amount),2) AS Revenue
FROM
	trips t
INNER JOIN locations l ON
	t.pickup_location_id = l.location_id
GROUP BY
	l.city_name,
	EXTRACT(MONTH FROM t.requested_at)
ORDER BY
	l.city_name,
	EXTRACT(MONTH FROM t.requested_at);

/*OLTP neded fewer join than in Warehouse because OLTP keeps thinghs like requested at on transaction table itself 
 where as in Star Schema we store date /time into its own dimension table.This is a trade off as OLTP computes month inline
 whereas warehouse pre-computes and stores month info once in dim_date making it more efficient.*/
 
 
 --Payment method revenue

SELECT
	dpm."name" AS payment_method,
	dd.month_name,
	SUM(ft.fare_amount) AS total_fare,
	ROUND(AVG(ft.fare_amount),2) AS AVG_fare_per_month,
	COUNT(ft.source_trip_id ) AS total_trips
FROM
	fact_trips ft
INNER JOIN dim_payment_method dpm ON
	fT.payment_method_key = dpm.payment_method_key
INNER JOIN dim_date dd ON
	ft.date_key = dd.date_key
GROUP BY
	dpm."name" 
 	,dd.month_name
ORDER BY 
	payment_method,
	total_fare desc;

	
--Busiest hour of day
SELECT
	dt."hour",
	count(ft.source_trip_id) AS Number_of_trips,
	ROUND(COUNT(ft.source_trip_id )*100/SUM(COUNT(ft.source_trip_id )) OVER(),2) AS percentage_of_all_trips
FROM
	fact_trips ft
INNER JOIN dim_time dt ON
	ft.time_key = dt.time_key
GROUP BY
	dt."hour"
ORDER BY 
	dt."hour";