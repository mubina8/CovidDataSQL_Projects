--Converting in a Date Format
Select * 
From DataCleaningProject..Sheet1$

Select SaleDate, cast(SaleDate as Date)
From DataCleaningProject..Sheet1$

Update DataCleaningProject..Sheet1$
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table DataCleaningProject..Sheet1$
Add SaleDateConverted Date

Update DataCleaningProject..Sheet1$
Set SaleDateConverted = Convert(Date,SaleDate)

--Populate Property Address data
Select PropertyAddress
From DataCleaningProject..Sheet1$
Where PropertyAddress is null

Select *
From DataCleaningProject..Sheet1$
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataCleaningProject..Sheet1$ a
JOIN DataCleaningProject..Sheet1$ b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null
--order by ParcelID

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataCleaningProject..Sheet1$ a
JOIN DataCleaningProject..Sheet1$ b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

--Breaking Down the Address(Address,City,state)
Select * 
From DataCleaningProject..Sheet1$

Select
SUBSTRING(PropertyAddress,1,Charindex(',',PropertyAddress)-1) 
as Address,
SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,
len(PropertyAddress)) as CityAddress
From DataCleaningProject..Sheet1$

Alter Table DataCleaningProject..Sheet1$
Add PropertySplitAddress Varchar(255)

Update DataCleaningProject..Sheet1$
set PropertySplitAddress = SUBSTRING
(PropertyAddress,1,Charindex(',',PropertyAddress)-1) 

Alter Table DataCleaningProject..Sheet1$
Add PropertyCityAddress Varchar(255)

Update DataCleaningProject..Sheet1$
set PropertyCityAddress= SUBSTRING(PropertyAddress,
Charindex(',',PropertyAddress)+1,
len(PropertyAddress)) 

--Breaking Down the Owner Address
Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From DataCleaningProject..Sheet1$

Alter Table DataCleaningProject..Sheet1$
Add OwnersplitAddress varchar(255)

Alter Table DataCleaningProject..Sheet1$
Add Ownersplitcity varchar(255)

Alter Table DataCleaningProject..Sheet1$
Add Ownersplitstate varchar(255)

Update DataCleaningProject..Sheet1$
set OwnersplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Update DataCleaningProject..Sheet1$
set Ownersplitcity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Update DataCleaningProject..Sheet1$
set Ownersplitstate = PARSENAME(Replace(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in SoldAsVacant Column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaningProject..Sheet1$
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
case when SoldAsvacant='Y' then 'Yes'
	when SoldAsvacant='N' then 'No'
	else SoldAsVacant
	END
From DataCleaningProject..Sheet1$

Update DataCleaningProject..Sheet1$
set SoldAsVacant= case when SoldAsvacant='Y' then 'Yes'
	when SoldAsvacant='N' then 'No'
	else SoldAsVacant
	END
From DataCleaningProject..Sheet1$

select * From DataCleaningProject..Sheet1$

--Remove Duplicate
With RowNumCTE AS(
		Select * , 
			ROW_NUMBER() OVER(
				Partition by ParcelID,
				PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From DataCleaningProject..Sheet1$
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From DataCleaningProject..Sheet1$

ALTER TABLE DataCleaningProject..Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate