-- Step 1: Update Date Format
ALTER TABLE project..Nashville
ADD SaleDateCleaned DATE;

UPDATE project..Nashville
SET SaleDateCleaned = CONVERT(DATE, SaleDate);

-- Step 2: Populate Missing Property Addresses
UPDATE a
SET a.PropertyAddress = ISNULL(b.PropertyAddress, a.PropertyAddress)
FROM project..Nashville a
JOIN project..Nashville b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Step 3a: Break Out PropertyAddress into Individual Columns
ALTER TABLE project..Nashville
ADD PropertyStreetAddress NVARCHAR(255),
    PropertyCity NVARCHAR(255);

UPDATE project..Nashville
SET PropertyStreetAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1),
    PropertyCity = LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)));

-- Step 3b: Break Out OwnerAddress into Individual Columns
ALTER TABLE project..Nashville
ADD OwnerStreetAddress NVARCHAR(255),
    OwnerCity NVARCHAR(255),
    OwnerState NVARCHAR(255);

UPDATE project..Nashville
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Step 4: Normalize the SoldAsVacant Field
UPDATE project..Nashville
SET SoldAsVacant = CASE
                    WHEN SoldAsVacant = 'Y' THEN 'Yes'
                    WHEN SoldAsVacant = 'N' THEN 'No'
                    ELSE SoldAsVacant
                   END;

-- Step 5: Remove Duplicate Rows
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM project..Nashville
)
DELETE FROM RowNumCTE
WHERE row_num > 1;

-- Step 6: Drop Unused Columns
ALTER TABLE project..Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
