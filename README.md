# SQL Data Cleaning Project: Tech Layoffs Dataset

## Dataset Source
This dataset is the popular tech layoffs dataset (2020-2023) originally compiled from public layoff announcements. It's commonly used for data cleaning practice in the data community.

## Before Cleaning
- - Inconsistent country format: "United States" vs "United States." (with period)
- Inconsistent industry names: "Crypto" vs "Crypto Currency"
- Mixed date formats (MM/DD/YYYY and text)
- 150+ null values in key columns
- Duplicate records

## After Cleaning
- Standardized country names
- Proper DATE data type
- Filled missing industries where possible
- Removed 40+ duplicate rows
- Ready for analysis

## Files
- `layoffs.csv` - Raw dataset
- `script-file.sql` - MySQL cleaning script