-- Update SaleDate to standardized date format
UPDATE NashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate, '%Y-%m-%d');

-- If column SaleDateConverted doesn't exist, add it first
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

-- Update SaleDateConverted
UPDATE NashvilleHousing
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%Y-%m-%d');

-- Select data to compare PropertyAddresses
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Update PropertyAddress
UPDATE NashvilleHousing a
JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Break out addresses
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255),
    PropertySplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1),
    PropertySplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(PropertyAddress, ',', -2), ',', 1);

-- Update SoldAsVacant values from 'Y'/'N' to 'Yes'/'No'
UPDATE NashvilleHousing
SET SoldAsVacant = CASE
                       WHEN SoldAsVacant = 'Y' THEN 'Yes'
                       WHEN SoldAsVacant = 'N' THEN 'No'
                       ELSE SoldAsVacant
                   END;

-- Remove duplicates based on certain criteria
DELETE n1 FROM NashvilleHousing n1
JOIN NashvilleHousing n2
WHERE n1.UniqueID > n2.UniqueID
  AND n1.ParcelID = n2.ParcelID
  AND n1.PropertyAddress = n2.PropertyAddress
  AND n1.SalePrice = n2.SalePrice
  AND n1.SaleDate = n2.SaleDate
  AND n1.LegalReference = n2.LegalReference;

-- Drop unnecessary columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;




