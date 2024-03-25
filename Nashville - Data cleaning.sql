/*
CLEANING DATA IN SQL QUERIES
*/


select * from Project..Nashville

--UPDATE DATE FORMAT
--Updating the dates from DateTime format to Date format

select SaleDates, CONVERT(date, SaleDate)
from Project..Nashville

UPDATE Nashville
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE Nashville
Add SaleDates Date;

UPDATE Nashville
SET SaleDates = CONVERT(date, SaleDate)



--POPULATE PROPERTY ADDRESS DATA

select *
from Project..Nashville
--where PropertyAddress is null
order by ParcelID

Select *
from Project..Nashville a
JOIN Project..Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project..Nashville a
JOIN Project..Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project..Nashville a
JOIN Project..Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
--PROPERTY ADDRESS
--Substring and CharIndex

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from Project..Nashville

ALTER TABLE Nashville
Add PropertySplitAddress NVARCHAR(255);

UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville
Add PropertySplitCity NVARCHAR(255);

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--OWNER ADDRESS
select OwnerAddress
from Project..Nashville

select
PARSENAME(OwnerAddress, 1)
from Project..Nashville

select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from Project..Nashville

ALTER TABLE Nashville
Add OwnerSplitAddress NVARCHAR(255);

UPDATE Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE Nashville
Add OwnerSplitCity NVARCHAR(255);

UPDATE Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE Nashville
Add OwnerSplitState NVARCHAR(255);

UPDATE Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD
--Using Case statement

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Project..Nashville
Group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from Project..Nashville

UPDATE Nashville
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



--REMOVE DUPLICATES
--Using CTE

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from Project..Nashville
--Order by ParcelID
)
DELETE
from RowNumCTE
where row_num > 1
--order by OwnerName



--DELETE UNUSED COLUMNS

select *
from Project..Nashville

ALTER TABLE Project..Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




































