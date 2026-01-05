#LOADING MY DATA
SELECT * FROM data.`nashville housing data for data cleaning (reuploaded)`;

#RENAMING THE TABLE
RENAME TABLE data.`nashville housing data for data cleaning (reuploaded)`
TO SQL_Data_cleaning;

##MOVING THE TABLE TO IT INITIAL SCHEMA
RENAME TABLE `DATABASE`.SQL_Data_cleaning
TO data.`nashville housing data`;

# STANDERDISE DATE FORMAT
SELECT saledate
FROM data.`nashville housing data`;
DESCRIBE data.`nashville housing data`;

#SELECT saledate,CAST (saledate AS DATE) AS saledateconverted
#FROM data.`nashville housing data`;

#UPDATE data.`nashville housing data`
#SET saledateconverted = CAST(saledate AS DATE);

#UPDATE `nashville housing data`
#SET saledate= CONVERT(Date,salesdate);

SELECT saledate,
STR_TO_DATE(saledate, '%M %d, %Y') AS saledateconverted
FROM data.`nashville housing data`
WHERE  UniqueID IS NOT NULL;


#ALTER TABLE `nashville housing data`
#ADD saledateconverted DATE;

#UPDATE data.`nashville housing data`
#SET saledateconverted = STR_TO_DATE(saledate, '%M %d, %Y')
#WHERE  UniqueID IS NOT NULL;

#UPDATE data.`nashville housing data`
#SET saledateconverted = STR_TO_DATE(TRIM(saledate), '%M %d, %Y')
#WHERE UniqueID > 0;

ALTER TABLE data.`nashville housing data`
ADD PRIMARY KEY (UniqueID);
SHOW KEYS FROM data.`nashville housing data`;

SELECT saledate,saledateconverted
FROM data.`nashville housing data`
ORDER BY saledate;

#PROPERTY ADDRESS 
SELECT PropertyAddress
FROM data.`nashville housing data`
WHERE PropertyAddress IS NOT NULL;

SELECT a.ParcelID,a.PropertyAddress,b.PropertyAddress,b.ParcelID#IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM data.`nashville housing data` a
JOIN data.`nashville housing data` b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID!= b.UniqueID
WHERE a.PropertyAddress IS NOT NULL;

#UPDATE data.`nashville housing data` a
#JOIN data.`nashville housing data` b
   # ON a.ParcelID = b.ParcelID
  # AND a.UniqueID != b.UniqueID
#SET a.PropertyAddress = b.PropertyAddress
#WHERE a.PropertyAddress IS NULL;

#BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN
SELECT PropertyAddress
FROM data.`nashville housing data`;

SELECT PropertyAddress,
SUBSTRING_INDEX (PropertyAddress,',',+1) AS ADDRESS 
FROM data.`nashville housing data`;

SELECT 
    PropertyAddress,
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Street,
    SUBSTRING_INDEX(PropertyAddress, ',', -1) AS City
FROM data.`nashville housing data`;

ALTER TABLE data.`nashville housing data`
ADD propertysplitaddress VARCHAR (225);

UPDATE data.`nashville housing data`
SET propertysplitaddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);


ALTER TABLE data.`nashville housing data`
ADD propertysplitCity VARCHAR (225);

UPDATE data.`nashville housing data`
SET propertysplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);


#TRYING THIS COS THE ABOVE(UPDATE) DOES WORK DUE TO SAFE MODE

#ALTER TABLE data.`nashville housing data`
#ADD PRIMARY KEY (UniqueID); PRIMARY KEY ALREADY EXIST

SHOW KEYS FROM data.`nashville housing data`
WHERE Key_name = 'PRIMARY';

UPDATE data.`nashville housing data`
SET propertysplitaddress = SUBSTRING_INDEX(PropertyAddress, ',', 1)
WHERE UniqueID > 0; 

UPDATE data.`nashville housing data`
SET propertysplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1)
WHERE UniqueID > 0; 

SELECT *
FROM data.`nashville housing data`;

#SPLITTTING OWNERS ADDRESS
SELECT 
    OwnerAddress,
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Street,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS City
FROM data.`nashville housing data`;

#SAVE IT 
ALTER TABLE data.`nashville housing data`
ADD OwnersplitCity VARCHAR (225);

UPDATE data.`nashville housing data`
SET OwnersplitCity = SUBSTRING_INDEX(OwnerAddress, ',', -1)
WHERE UniqueID > 0;

ALTER TABLE data.`nashville housing data`
ADD OwnersplitStreet VARCHAR (225);

UPDATE data.`nashville housing data`
SET OwnersplitStreet = SUBSTRING_INDEX(OwnerAddress, ',', 1)
WHERE UniqueID > 0;

SELECT *
FROM data.`nashville housing data`;


#TABLE SOLD AS VACANT
SELECT DISTINCT (SoldAsVacant)
FROM data.`nashville housing data`;

# CHANGE Y AND N TO YES AND NO IN TABLE SOLD AS VACANT
SELECT DISTINCT (SoldAsVacant),COUNT(SoldAsVacant)
FROM data.`nashville housing data`
GROUP BY SoldAsVacant 
ORDER BY 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END AS SoldAsVacantUpdated
FROM data.`nashville housing data`;


UPDATE data.`nashville housing data`
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
WHERE UniqueID > 0;

SELECT *
FROM data.`nashville housing data`;
 
 
 
 
 # REMOVE DUPLICATE
 #CHECKING 
 SELECT ParcelID, COUNT(*) AS count_rows
FROM data.`nashville housing data`
GROUP BY ParcelID
HAVING count_rows > 1;

SELECT *
FROM data.`nashville housing data`
WHERE (ParcelID, PropertyAddress) IN (
    SELECT ParcelID, PropertyAddress
    FROM data.`nashville housing data`
    GROUP BY ParcelID, PropertyAddress
    HAVING COUNT(*) > 1
)
ORDER BY ParcelID, PropertyAddress;

 
 SELECT *,
 ROW_NUMBER () OVER (
 PARTITION BY ParcelID,
			  PropertyAddress,
              SaleDate,
              SalePrice,
              LegalReference
              ORDER BY UniqueID) row_num
FROM data.`nashville housing data`
              