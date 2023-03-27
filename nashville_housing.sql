/*

Cleaning Data in SQL Queries

*/

SELECT * FROM NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Standardized date format 

SELECT SaleDateConverted,CONVERT(date,SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Populate porperty address data

SELECT * FROM NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null  


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null  


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------



--Breaking out address into individual columns(address,city,state)

SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',' , PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress)) AS address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',' , PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))





SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2), 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1) 
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------



--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelId,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			   UniqueID
			   )row_num

FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Delete Unused Columns


SELECT * FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate