
-- Key Stats for Operators based by Districts

WITH SessionsStations AS
(
SELECT stat.station_id, stat.district_name, stat.operator_name, sess.session_id, sess.session_start_time, sess.kwh_charged, sess.total_cost
FROM charging_sessions sess
JOIN charging_stations stat
	ON sess.station_id = stat.station_id
)

SELECT district_name, operator_name, AVG(cast(kwh_charged as float)) AS AVG_ChargedKWH, SUM(cast(total_cost as float)) AS Total_Revenue
FROM SessionsStations
GROUP BY district_name, operator_name
ORDER BY 1, Total_Revenue DESC

ALTER TABLE charging_sessions
ALTER COLUMN total_cost float;

-- For date visuals

    WITH TimeCost AS
(
SELECT  sta.station_id, ses.session_start_time, ses.total_cost, ses.kwh_charged , sta.district_name, sta.operator_name
  FROM charging_sessions ses
  JOIN charging_stations sta
    ON ses.station_id = sta.station_id
)

SELECT *
FROM TimeCost
ORDER BY district_name, operator_name

-- Rolling Customers for each operator

WITH Operator_Customers AS
(
SELECT stat.station_id, stat.district_name, stat.operator_name, sess.session_id, sess.customer_id, sess.session_start_time, sess.kwh_charged, sess.total_cost, stat.income_tier
FROM charging_sessions sess
JOIN charging_stations stat
	ON sess.station_id = stat.station_id
),
dist AS
(
SELECT DISTINCT operator_name, district_name, customer_id
FROM Operator_Customers
)

SELECT operator_name, district_name, COUNT(customer_id) AS Total_Unique_Charges, SUM(COUNT(customer_id)) OVER(PARTITION BY operator_name ORDER BY district_name) AS Rolling_DistinctCharges
FROM dist
GROUP BY operator_name, district_name
ORDER BY operator_name, Total_Unique_Charges ASC


-- Key stats for Operators with map details

WITH Map_For_Operators AS
(
SELECT stat.station_id, stat.latitude, stat.longitude, stat.district_name, stat.operator_name, sess.session_id, sess.kwh_charged, sess.cost_per_kwh, sess.total_cost, stat.income_tier
FROM charging_sessions sess
JOIN charging_stations stat
	ON sess.station_id = stat.station_id
)

SELECT station_id, latitude,longitude, district_name, operator_name, AVG(cast(kwh_charged as float)) AS AVG_ChargedKWH, AVG(cast(cost_per_kwh as float)) as AVG_Cost_per_KWH , SUM(cast(total_cost as float)) AS Total_Revenue
FROM Map_For_Operators
GROUP BY district_name, operator_name, income_tier, station_id, latitude, longitude
ORDER BY 5,4, Total_Revenue DESC


-- Identifying customers more better (Such as total paid by districts depending on income tier) 

WITH CustomersCharges AS
(
SELECT cus.customer_id,cus.income_tier,cus.battery_capacity_kwh, sess.station_id, sess.session_id, sess.kwh_charged, sess.total_cost
FROM charging_sessions sess
JOIN customers cus
	ON sess.customer_id = cus.customer_id
),
Station_District AS
(SELECT district_name, station_id
FROM charging_stations
)
 

SELECT sd.district_name, COUNT(DISTINCT cc.customer_id) AS Unique_Charges, cc.income_tier, AVG(cast(cc.battery_capacity_kwh as float)) AS AVG_Battery_Capacity, AVG(cast(cc.kwh_charged as float)) AS avg_chargedKWH, SUM(cast(total_cost as float)) as Total_Paid
FROM CustomersCharges cc
JOIN Station_District sd
	ON cc.station_id = sd.station_id
GROUP BY sd.district_name, cc.income_tier
ORDER BY sd.district_name, Total_paid DESC
