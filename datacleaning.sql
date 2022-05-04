--data cleaning


--use to display all the records in table 
select *
from practice.dbo.housing$


--standardising date format YYYY-MM-DD
--adding saledateconverted column
alter table housing$
add saledateconverted date

--updating housing table with new column saledateconverted
update housing$
set saledateconverted = CONVERT(date,SaleDate)

--...............................................................

--populate property address data 
-- parcelid is same for propertyaddress so we can populate null propertyaddress values by parcelid
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from practice.dbo.housing$ a
join practice.dbo.housing$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--updating propertyaddress
update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from practice.dbo.housing$ a
join practice.dbo.housing$ b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--checking if any null value are present in propertyaddress column
select *
from practice.dbo.housing$
where PropertyAddress is null

--.................................................................

--breaking address into individual columns propertysplitaddress and propertysplitcity
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) as address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1 , LEN(PropertyAddress)) as Address
from practice.dbo.housing$

alter table practice.dbo.housing$
add PropertySplitAddress Nvarchar(255);

update practice.dbo.housing$
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1)

alter table practice.dbo.housing$
add PropertySplitCity Nvarchar(255);


update  practice.dbo.housing$
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1 , LEN(PropertyAddress))


--breaking owneraddress into OwnerSplitAddress, OwnerSplitCity,OwnerSplitState
select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from practice.dbo.housing$


alter table practice.dbo.housing$
add OwnerSplitAddress Nvarchar(255);
--
update practice.dbo.housing$
set  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

alter table practice.dbo.housing$
add OwnerSplitCity Nvarchar(255);
 
update  practice.dbo.housing$
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

alter table practice.dbo.housing$
add OwnerSplitState Nvarchar(255);

update  practice.dbo.housing$
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

--.......................
--changing y to yes and n to no in soldAsVacant populitng soldasvacant column
select distinct (SoldAsVacant),count(SoldAsVacant)
from practice.dbo.housing$
group by SoldAsVacant
order by SoldAsVacant

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'YES'
       when SoldAsVacant = 'N' then 'NO'
	   else SoldAsVacant
	   end
from portofolioproject.dbo.housing$

update  practice.dbo.housing$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

--...............

---delete unsused columns
 use practice
 alter table housing$
 drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

 select *
from practice.dbo.housing$