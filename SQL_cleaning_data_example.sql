select *
from Nash_Housing


---------- Change date format in SaleDate column 

select SaleDate_converted, convert (Date, SaleDate)
from Nash_Housing

update Nash_Housing
set SaleDate = convert (Date, SaleDate)

alter table Nash_Housing
add SaleDate_converted Date;

update Nash_Housing
set SaleDate_converted = convert (Date, SaleDate)

--check it 
select SaleDate_converted
from Nash_Housing



---------- Fix Property Address column 

select *
from Nash_Housing
order by ParcelID
--we see that there are some rows with the same ParcelId but Adress is null on one of them 
-- so we should fix that 

select f.ParcelID, f.PropertyAddress, s.ParcelID, s.PropertyAddress, 
       ISNULL(f.PropertyAddress, s.PropertyAddress)
from Nash_Housing as f
join Nash_Housing as s
     on f.ParcelID = s.ParcelID
	 and f.[UniqueID ] <> s.[UniqueID ]
where f.PropertyAddress is null

update f
set PropertyAddress = ISNULL(f.PropertyAddress, s.PropertyAddress)
from Nash_Housing as f
join Nash_Housing as s
     on f.ParcelID = s.ParcelID
	 and f.[UniqueID ] <> s.[UniqueID ]
where f.PropertyAddress is null



---------- We have different types of info in Address column. Let's separate each part

select PropertyAddress
from Nash_Housing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as City
from Nash_Housing

alter table Nash_Housing
add Property_split_Address nvarchar(255);

update Nash_Housing
set Property_split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table Nash_Housing
add Property_split_City nvarchar(255);

update Nash_Housing
set Property_split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))


--check it
select *
from Nash_Housing



----------  Analogically we have different types of info in OwnerAddress column

select OwnerAddress
from Nash_Housing

select 
parsename (replace(OwnerAddress, ',', '.'), 3) as Address,
parsename (replace(OwnerAddress, ',', '.'), 2) as City,
parsename (replace(OwnerAddress, ',', '.'), 1) as State
from Nash_Housing


alter table Nash_Housing
add Owner_Address nvarchar(255);

update Nash_Housing
set Owner_Address = parsename (replace(OwnerAddress, ',', '.'), 3)


alter table Nash_Housing
add Owner_City nvarchar(255);

update Nash_Housing
set Owner_City = parsename (replace(OwnerAddress, ',', '.'), 2)


alter table Nash_Housing
add Owner_State nvarchar(255);

update Nash_Housing
set Owner_State = parsename (replace(OwnerAddress, ',', '.'), 1)

--check it
select *
from Nash_Housing



----------  We need to fix Y & N in SoldAsVacant and replace them to 'Yes' and 'No'

select distinct(SoldAsVacant), count (SoldAsVacant) as count
from Nash_Housing
group by SoldAsVacant
order by count desc 


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Nash_Housing

update Nash_Housing
set SoldAsVacant = case 
     when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
-- for checking just execute the first part with distinct function



----------  Delete duplicates - action that is possible only if it's ok for your db. It's ok for our example :)

-- identify duplicates in dt
with Rows_CTE as(
select *,
       ROW_NUMBER() over (
	   partition by ParcelID, PropertyAddress, SaleDate, SalePrice, OwnerName, LegalReference
	   order by UniqueID) as row_num
from Nash_Housing
)

--select *
--from Rows_CTE
--where row_num > 1
--order by PropertyAddress

--now we have table with duplicates - 104 rows 

delete 
from Rows_CTE
where row_num > 1
-- so we delete 104 rows of duplicates



----------  Delete unused columns 

select *
from Nash_Housing

alter table Nash_Housing
drop column PropertyAddress, OwnerAddress, TaxDistrict

alter table Nash_Housing
drop column SaleDate

--now all selected columns have been removed 