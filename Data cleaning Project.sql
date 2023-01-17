

/*
Cleaning Data in SQL Queries
*/


SELECT*
From [Nashville Housing Data for Data Cleaning]

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Nashville Housing Data for Data Cleaning]


Update [Nashville Housing Data for Data Cleaning]
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add SaleDateConverted Date;

Update [Nashville Housing Data for Data Cleaning]
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
Select *
From [Nashville Housing Data for Data Cleaning]
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Nashville Housing Data for Data Cleaning] a
JOIN [Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Nashville Housing Data for Data Cleaning] a
JOIN [Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From [Nashville Housing Data for Data Cleaning]
--Where PropertyAddress is null
--order by ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add PropertySplitCity Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



Select *
From [Nashville Housing Data for Data Cleaning]

Select OwnerAddress
From[Nashville Housing Data for Data Cleaning]


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Nashville Housing Data for Data Cleaning]



ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From [Nashville Housing Data for Data Cleaning]

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Nashville Housing Data for Data Cleaning]
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant, REPLACE(SoldAsVacant, '1', 'Y') as SoldAsVacantFixed
from [Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add SoldAsVacantFixed Nvarchar(255);


Update [Nashville Housing Data for Data Cleaning]

SET SoldAsVacantFixed= REPLACE(SoldAsVacant,'0', 'N')

SELECT*
From [Nashville Housing Data for Data Cleaning]







Select SoldAsVacantFixed
, CASE When SoldAsVacantFixed = '1' THEN 'Yes'
	   When SoldAsVacantFixed = 'N' THEN 'No'
	   ELSE SoldAsVacantFixed
	   END
From [Nashville Housing Data for Data Cleaning]


Update [Nashville Housing Data for Data Cleaning]

SET SoldAsVacantFixed = CASE When SoldAsVacantFixed = '1' THEN 'Yes'
	   When SoldAsVacantFixed = 'N' THEN 'No'
	   ELSE SoldAsVacantFixed
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Nashville Housing Data for Data Cleaning]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--- Delete Unused Columns



Select *
From [Nashville Housing Data for Data Cleaning]

ALTER TABLE[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


