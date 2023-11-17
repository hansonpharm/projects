SELECT *
FROM NashVilleHousing


-- Covert Date to standard date format

SELECT SaleDate, CONVERT(DATE, SaleDate)
from NashVilleHousing


ALTER TABLE [dbo].[NashVilleHousing]
ADD SaleDateConverted DATE 

UPDATE NashVilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-- Populate PropertyAddress Column
select  PropertyAddress
from NashVilleHousing
where PropertyAddress is Null

select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashVilleHousing a
join NashVilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null
order by 1

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashVilleHousing a
join NashVilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
--where a.PropertyAddress is null
--order by 1


-- Breaking Address into (Adress, City and State) Columns

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM [dbo].[NashVilleHousing]

ALTER TABLE [dbo].[NashVilleHousing]
ADD SplitPropertyAddress Nvarchar(200)

UPDATE [dbo].[NashVilleHousing]
SET SplitPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 
FROM [dbo].[NashVilleHousing]


ALTER TABLE [dbo].[NashVilleHousing]
ADD SplitPropertyCity Nvarchar(200)

UPDATE [dbo].[NashVilleHousing]
SET SplitPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 
FROM [dbo].[NashVilleHousing]

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM NashVilleHousing

ALTER TABLE NashVilleHousing
ADD OwnerSplitAddress nvarchar(200)

UPDATE NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashVilleHousing
ADD OwnerSplitCity nvarchar(200)

UPDATE NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE NashVilleHousing
ADD OwnerSplitState nvarchar(200)


UPDATE NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

-- Change Y and N to Yes and No in 'SoldAsVacant' field

SELECT  Distinct (SoldAsVacant), count(SoldAsVacant)
FROM NashVilleHousing
group by SoldAsVacant


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='N' THEN 'No'
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END
FROM NashVilleHousing

UPDATE NashVilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant ='N' THEN 'No'
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference
	ORDER BY UniqueID) row_num
FROM NashVilleHousing
--order by ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num >1
order by PropertyAddress


--Delete unused columns

SELECT *
FROM NashVilleHousing

ALTER TABLE NashVilleHousing
DROP COLUMN SaleDate
--, PropertyAddress, OwnerAddress, TaxDistrict