/****** Script for SelectTopNRows command from SSMS  ******/
  SELECT *
  FROM PortfolioProject..NashvilleHousing

  ------------Cleaning Data in SQL Queries------------------------
  ------------standardize Date Format--------------------------

 

  Update PortfolioProject..NashvilleHousing
  SET SaleDate = CONVERT(Date,SaleDate) 

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update PortfolioProject..NashvilleHousing
 SET SaleDateConverted = CONVERT(Date,SaleDate) 

 SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
 FROM PortfolioProject..NashvilleHousing 

 -- To Drop The column SaleDate
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

--------Populate Property address Data------------

 SELECT *
  FROM PortfolioProject..NashvilleHousing
  --WHERE PropertyAddress is null
  order by ParcelID

  ---Join the table to itself so that we compare id's and make the rows with same id have same address---

   SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress ,ISNULL (a.PropertyAddress,b.PropertyAddress)--if the value in a is null replace it with the value in b--
  FROM PortfolioProject..NashvilleHousing a
  join PortfolioProject..NashvilleHousing b
  on a.ParcelID= b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ] 
  --where a.PropertyAddress is null

  Update a
  SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
   FROM PortfolioProject..NashvilleHousing a
  join PortfolioProject..NashvilleHousing b
  on a.ParcelID= b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ] 
  where a.PropertyAddress is null


  --------Break Out address into individual column----------

  SELECT
  --looking at property address going till the comma(,) then get rid of the comma by doing -1
  SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
  ---Here we don't want to start where at the 1st word but at the (,) that's why we are deleting the 1 to get rid of the (+1)
  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
  FROM PortfolioProject..NashvilleHousing


ALTER TABLE  PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

 ALTER TABLE  PortfolioProject..NashvilleHousing
Add PropertySplitCity  Nvarchar(255);

Update PortfolioProject..NashvilleHousing
 SET PropertySplitCity =  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) 

 ---let's separate again owner address USING PARSENAME  the difference is it looks for (.) so we will have to replace it with (,)
 ---since it goes backwards will start counting from 3 //desc
 SELECT 
 PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
 ,PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
 ,PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
 FROM  PortfolioProject..NashvilleHousing

 ALTER TABLE  PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

 ALTER TABLE  PortfolioProject..NashvilleHousing
Add OwnerSplitCity  Nvarchar(255);

Update PortfolioProject..NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

 ALTER TABLE  PortfolioProject..NashvilleHousing
Add OwnerSplitState  Nvarchar(255);

Update PortfolioProject..NashvilleHousing
 SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
 ----------------------------------------------------------------------------------------------
 ---Change Y and N to Yes and No of SoldAsVacant-------------
 SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
  FROM PortfolioProject..NashvilleHousing
   GROUP by SoldAsVacant
  order by 2

   SELECT  SoldAsVacant
,CASE When SoldAsVacant = 'Y' then 'Yes'
      When SoldAsVacant = 'N' then 'No'
	  ELSE SoldAsVacant
	  END
  FROM PortfolioProject..NashvilleHousing

  UPDATE  PortfolioProject..NashvilleHousing
  SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
      When SoldAsVacant = 'N' then 'No'
	  ELSE SoldAsVacant
	  END


----------------------------------------------------------------------
---Remove Duplicate-----------

-- we are gonna find where they are duplicate values

WITH RowNumCTE As(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY  ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDateConverted,
			  LegalReference
			  ORDER BY UniqueID
)  row_num
  FROM PortfolioProject..NashvilleHousing 
  --order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num >1 
--Order by PropertyAddress


SELECT *
  FROM PortfolioProject..NashvilleHousing
  -------------------------------------------------
  ---------Delete unused columns

SELECT *
From  PortfolioProject..NashvilleHousing

ALTER TABLE  PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

