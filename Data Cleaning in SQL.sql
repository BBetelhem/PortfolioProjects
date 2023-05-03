select *
from PortfolioProject.dbo.NashvilleHousing

-- Standardize date format

select SaleDateConverted, CONVERT(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set saledate = CONVERT(date,SaleDate)

ALTER TABLE Nashvillehousing 
Add SaleDateConverted Date;

update NashvilleHousing
set saledateconverted = CONVERT(date,SaleDate)

-- Populate property address data 

select *
from PortfolioProject.dbo.NashvilleHousing
-- where propertyaddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual columns (Address, City, State) 

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
-- where propertyaddress is null
-- order by ParcelID

select 
substring (propertyaddress, 1, CHARINDEX(',',propertyaddress) -1) as address
, substring(propertyaddress, CHARINDEX(',', propertyaddress) + 1, len(propertyaddress)) as address
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring (propertyaddress, 1, CHARINDEX(',',propertyaddress) -1)

ALTER TABLE Nashvillehousing 
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(propertyaddress, CHARINDEX(',', propertyaddress) + 1, len(propertyaddress)) 

select *
From PortfolioProject.dbo.NashvilleHousing



select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


select 
parsename (replace(owneraddress, ',', '.'), 3) 
, parsename (replace(owneraddress, ',', '.'), 2) 
, parsename (replace(owneraddress, ',', '.'), 1) 
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename (replace(owneraddress, ',', '.'), 3) 

ALTER TABLE Nashvillehousing 
Add  OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename (replace(owneraddress, ',', '.'), 2) 

ALTER TABLE NashvilleHousing
Add  OwnerSplitState Nvarchar(255);

update NashvilleHousing
set  OwnerSplitState = parsename (replace(owneraddress, ',', '.'), 1)



-- CHange Y and N to Yes and No in "Sold as Vacant" field 

select distinct (SoldAsVacant), count(soldasvacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2 



select SoldAsVacant 
, case when soldasvacant = 'Y' then 'Yes' 
		when soldasvacant = 'N' then 'No'
		else soldasvacant
		END 
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes' 
		when soldasvacant = 'N' then 'No'
		else soldasvacant
		END




-- Remove duplicates 

WITH RowNumCTE AS (
select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing
-- order by ParcelID
)

select * 
from RowNumCTE
where row_num > 1 
-- order by PropertyAddress


select * 
from PortfolioProject.dbo.NashvilleHousing


-- Delete unused columns 


select * 
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

Alter table PortfolioProject.dbo.NashvilleHousing
drop column saledate

