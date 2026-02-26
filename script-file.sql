-- in this data cleaning project we will go through four steps :

-- 1. removing duplicates
-- 2. standardizing the data
-- 3. fixing null values or blank values
-- 4. removing unecessary columns or rows if possible


SELECT * FROM layoffs;

-- we duplicate the layoffs table
CREATE TABLE layoffs_staging LIKE layoffs ; 
INSERT layoffs_staging SELECT * FROM layoffs;

-- the new table is empty
SELECT * FROM layoffs_staging;




-- 1.remove duplicates

-- this CTE shows us the duplicates in the table
-- we use row_number to assign a number to each row, we want to check for duplicates
WITH duplicate_cte AS
(
	SELECT * ,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num 
	FROM layoffs_staging
)
-- we filter for rows that have a row number greater than 1 which means they are duplicates
SELECT * 
FROM duplicate_cte
WHERE row_num > 1 ;
 
-- MySQL does not allow you to delete directly from a CTE so we create a second table
CREATE TABLE layoffs_staging2 LIKE layoffs_staging;
ALTER TABLE layoffs_staging2 ADD COLUMN row_num INT;
INSERT INTO layoffs_staging2
SELECT * ,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num 
	FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1 ;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1 ;







-- 2. standardizing data

SELECT company , TRIM(company)
FROM layoffs_staging2;
-- we remove leading and trailing spaces from the company column
UPDATE layoffs_staging2 SET company=TRIM(company);

SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY 1;
-- foudn crypto/crypto currencies
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location FROM layoffs_staging2 ORDER BY 1;
-- found no issues

SELECT DISTINCT country FROM layoffs_staging2 ORDER BY 1;
-- found united states/ united states. 
UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE 'United States%';

SELECT `date` FROM layoffs_staging2;
-- we change the date format to the standard date format in mysql which is YYYY-MM-DD
UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- date is still text
ALTER TABLE layoffs_staging2  
MODIFY COLUMN `date` DATE;






-- 3. null values or blank values

-- we check for null or empty values in the industry column
SELECT * 
FROM layoffs_staging2 
WHERE industry IS NULL
OR industry = '';

-- we check if there are any companies that have the same name but one has an industry and the other does not, this will help us fill in the missing values
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL; 

-- we set the industry to null if it is blank bc mysql treat empty values and actual values the same   
UPDATE layoffs_staging2 
SET industry = NULL
WHERE industry = ''; 

-- we update the industry column with the industry from the other row if it is null and there is a match on the company name
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;





-- 4. remove unecessary columns or rows
SELECT * FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;