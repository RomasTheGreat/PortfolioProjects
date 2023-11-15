Select *
From [Data Cleansing Project].dbo.NashvilleHousing


-- Standardize Date Format

Select NewSaleDate, CONVERT(Date, SaleDate)
From [Data Cleansing Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add NewSaleDate Date;

Update NashvilleHousing
SET NewSaleDate = CONVERT(Date,SaleDate)


-- Populate Property Address Data
Select *
From [Data Cleansing Project].dbo.NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Data Cleansing Project].dbo.NashvilleHousing a
JOIN [Data Cleansing Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Data Cleansing Project].dbo.NashvilleHousing a
JOIN [Data Cleansing Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


	-- Breaking out Address into Individual Columns (Address, City, State)

	Select PropertyAddress
From [Data Cleansing Project].dbo.NashvilleHousing


Select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City

From [Data Cleansing Project].dbo.NashvilleHousing


ALTER TABLE [Data Cleansing Project].dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [Data Cleansing Project].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE [Data Cleansing Project].dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update [Data Cleansing Project].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




Select OwnerAddress
From [Data Cleansing Project].dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From [Data Cleansing Project].dbo.NashvilleHousing





ALTER TABLE [Data Cleansing Project].dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [Data Cleansing Project].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)



ALTER TABLE [Data Cleansing Project].dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update [Data Cleansing Project].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)



ALTER TABLE [Data Cleansing Project].dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update [Data Cleansing Project].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

From [Data Cleansing Project].dbo.NashvilleHousing


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)

From [Data Cleansing Project].dbo.NashvilleHousing
Group BY SoldAsVacant
Order By 2 


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End

From [Data Cleansing Project].dbo.NashvilleHousing

Update [Data Cleansing Project].dbo.NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End



	-- Remove Duplicates


With RowNumCTE as(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By 
					ParcelID
					) row_num

From [Data Cleansing Project].dbo.NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns


Select * 
From [Data Cleansing Project].dbo.NashvilleHousing

Alter Table [Data Cleansing Project].dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict,PropertyAddress, SaleDate

Alter Table [Data Cleansing Project].dbo.NashvilleHousing
Drop Column SaleDate