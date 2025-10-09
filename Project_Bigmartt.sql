SELECT *
FROM bigmart

-- Correcting some data

SELECT item_fat_content ,
(CASE
WHEN item_fat_content = 'reg' THEN 'Regular'
WHEN item_fat_content = 'LF' THEN 'Low Fat'
ELSE item_fat_content
END) AS item_fat_updated
FROM bigmart
GROUP BY item_fat_content

UPDATE bigmart 
SET item_fat_content = CASE
WHEN item_fat_content = 'reg' THEN 'Regular'
WHEN item_fat_content = 'LF' THEN 'Low Fat'
ELSE item_fat_content
END;

SELECT CONCAT(
UPPER(LEFT(item_fat_content,1)),
LOWER(SUBSTRING(item_fat_content, 2, LEN(item_fat_content)))
) AS Proper_Fat_content
from bigmart

UPDATE bigmart 
SET item_fat_content = CONCAT(
UPPER(LEFT(item_fat_content,1)),
LOWER(SUBSTRING(item_fat_content, 2, LEN(item_fat_content))))

SELECT try_cast(item_weight as float) as item_weight,
(	CASE
WHEN try_cast(item_weight as float) < 4 THEN 'Low_weight'
WHEN try_cast(item_weight as float) >= 4 AND try_cast(item_weight as float) < 10 THEN 'Medium_weight'
WHEN try_cast(item_weight as float) >=10 THEN 'High_weight'
ELSE 'No_info'
	END) AS Item_weight_Bracket
FROM bigmart
ORDER BY 1;

ALTER TABLE bigmart
ADD Item_weight_Bracket varchar(255);


UPDATE bigmart
SET Item_weight_Bracket = CASE
WHEN try_cast(item_weight as float) < 4 THEN 'Low_weight 4<'
WHEN try_cast(item_weight as float) >= 4 AND try_cast(item_weight as float) < 10 THEN 'Medium_weight (4-10)'
WHEN try_cast(item_weight as float) >=10 THEN 'High_weight 10+'
ELSE 'No_info'
END

-- Working with missing info


SELECT *,
ROW_NUMBER() OVER(PARTITION BY outlet_identifier, item_visibility, item_MRP
ORDER BY item_identifier
) AS rn
FROM bigmart 
ORDER BY item_identifier

SELECT Outlet_size,
(	CASE
WHEN Outlet_size = ' ' OR Outlet_size IS NULL THEN 'No information'
ELSE Outlet_size
	END) AS Outlet_size_upd
FROM bigmart



SELECT item_weight,
(	CASE
WHEN item_weight = ' ' OR item_weight is NULL THEN 'No information'
ELSE item_weight
	END) AS item_weight_upd
FROM bigmart


UPDATE bigmart
	SET Outlet_Size = CASE
WHEN Outlet_size = ' ' OR outlet_size is NULL THEN 'No information'
ELSE Outlet_size
	END,
	item_weight = CASE
WHEN item_weight = ' ' OR item_weight is NULL THEN 'No information'
ELSE item_weight
	END;

-- Key stats

SELECT outlet_type, SUM(cast(item_outlet_sales as FLOAT)) AS Sum_Outlet_sales
FROM bigmart
GROUP BY outlet_type
ORDER BY 1


SELECT item_type, outlet_type, SUM(cast(item_outlet_sales as FLOAT)) AS Sum_Outlet_sales
FROM bigmart
GROUP BY item_type, outlet_type
ORDER BY 1,2

SELECT item_fat_content, outlet_type, COUNT(item_fat_content) AS Count_fat_type, AVG(cast(item_outlet_sales as float)) as AVG_Sales
FROM bigmart
GROUP BY item_fat_content, outlet_type
ORDER BY 1,2


SELECT item_type, AVG(cast(item_mrp as float)) as AVG_Item_MRP
FROM bigmart
GROUP BY item_type
ORDER BY 2 DESC

