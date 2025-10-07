SELECT *
FROM Portfolio_Project.dbo.LandSales;


-- Making date box look more accurate 
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Portfolio_Project.dbo.LandSales;

UPDATE LandSales
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE LandSales
ADD SaleDateConv Date; 

UPDATE LandSales
SET SaleDateConv = CONVERT(Date,SaleDate)


SELECT SaleDateConv
FROM Portfolio_Project.dbo.LandSales;


-- Adding addresses to missing addresses (if its possible)

SELECT *
FROM Portfolio_Project.dbo.LandSales
-- WHERE Propertyaddress is NULL
ORDER BY ParcelID 


SELECT a.ParcelID, a.Propertyaddress, b.ParcelID, b.Propertyaddress, ISNULL(a.Propertyaddress, b.Propertyaddress)
FROM Portfolio_Project.dbo.LandSales a
JOIN Portfolio_Project.dbo.LandSales b
	ON a.parcelID = b.parcelID
	AND a.uniqueID <> b.uniqueID
WHERE a.Propertyaddress is NULL
 

 UPDATE a
 SET Propertyaddress = ISNULL(a.Propertyaddress, b.Propertyaddress)
 FROM Portfolio_Project.dbo.LandSales a
JOIN Portfolio_Project.dbo.LandSales b
	ON a.parcelID = b.parcelID
	AND a.uniqueID <> b.uniqueID
	WHERE a.Propertyaddress is NULL


-- Separating Addresses to: Address, City

SELECT Propertyaddress
FROM Portfolio_Project.dbo.LandSales


SELECT
SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress) -1) AS Address,
SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress) + 1 , LEN(Propertyaddress)) AS City
FROM Portfolio_Project.dbo.LandSales


ALTER TABLE LandSales
ADD Property_Address nvarchar(255); 


UPDATE LandSales
SET Property_Address = SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress) -1)

ALTER TABLE LandSales
ADD Property_City nvarchar(255); 

UPDATE LandSales
SET Property_City = SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress) + 1 , LEN(Propertyaddress))


SELECT *
FROM Portfolio_Project.dbo.LandSales


SELECT OwnerAddress
FROM Portfolio_Project.dbo.LandSales

SELECT 
PARSENAME(REPLACE(Owneraddress,',','.'), 3) AS Address,
PARSENAME(REPLACE(Owneraddress,',','.'), 2) AS City,
PARSENAME(REPLACE(Owneraddress,',','.'), 1) AS State

FROM Portfolio_Project.dbo.LandSales


ALTER TABLE LandSales
ADD Owner_Address nvarchar(255); 


UPDATE LandSales
SET Owner_Address = PARSENAME(REPLACE(Owneraddress,',','.'), 3)

ALTER TABLE LandSales
ADD Owner_City nvarchar(255); 

UPDATE LandSales
SET Owner_City = PARSENAME(REPLACE(Owneraddress,',','.'), 2)

ALTER TABLE LandSales
ADD Owner_State nvarchar(255); 

UPDATE LandSales
SET Owner_State = PARSENAME(REPLACE(Owneraddress,',','.'), 1)




-- Changing Y and N = Yes and No


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project.dbo.LandSales
GROUP BY SoldAsVacant 
ORDER BY 2 DESC


SELECT SoldAsVacant ,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Portfolio_Project.dbo.LandSales



UPDATE LandSales
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Duplicates Removing  

WITH row_numCTE AS 
(
SELECT * ,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
							   Propertyaddress,
							   SalePrice,
							   SaleDate,
							   LegalReference
ORDER BY UniqueID) row_num

FROM Portfolio_Project.dbo.LandSales
--ORDER BY ParcelID
)
DELETE 
FROM row_numCTE
WHERE row_num > 1


-- Removing  columns 

SELECT *
FROM Portfolio_Project.dbo.LandSales

ALTER TABLE Portfolio_Project.dbo.LandSales
DROP COLUMN Propertyaddress, OwnerAddress, SaleDate

