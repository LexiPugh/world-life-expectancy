SELECT 
    country, 
    year,
    COUNT(CONCAT(country, year)) AS duplicates
FROM 
    world_life_expectancy
GROUP BY
    country, 
    year
HAVING 
    duplicates > 1;

DELETE FROM world_life_expectancy
WHERE row_id IN (
    SELECT 
        row_id
    FROM (
        SELECT
            row_id,
            CONCAT(country, year),
            ROW_NUMBER() OVER(PARTITION BY CONCAT(country, year) ORDER BY CONCAT(country, year)) AS row_num
        FROM 
            world_life_expectancy
        ) AS unique_row_table
    WHERE row_num > 1
);

SELECT 
    country,
    year,
    status
FROM 
    world_life_expectancy
WHERE 
    status = '';

SELECT
    DISTINCT(status)
FROM 
    world_life_expectancy
WHERE 
    status <> '';

UPDATE
    world_life_expectancy AS wle1
INNER JOIN 
    world_life_expectancy AS wle2
    ON wle1.country = wle2.country
SET
    wle1.status = 'Developing'
WHERE
    wle1.status = ''
    AND wle2.status <> ''
    AND wle2.status = 'Developing';

UPDATE
    world_life_expectancy AS wle1
INNER JOIN 
    world_life_expectancy AS wle2
    ON wle1.country = wle2.country
SET
    wle1.status = 'Developed'
WHERE
    wle1.status = ''
    AND wle2.status <> ''
    AND wle2.status = 'Developed';

SELECT 
    country,
    year,
    `Life expectancy`
FROM 
    world_life_expectancy
WHERE 
    `Life expectancy` = '';

SELECT 
    country,
    year,
    `Life expectancy`
FROM 
    world_life_expectancy
WHERE
    country = 'Afghanistan'
LIMIT 
    10;

SELECT 
    country,
    year,
    `Life expectancy`
FROM 
    world_life_expectancy
WHERE
    country = 'Albania'
LIMIT 
    10;

UPDATE world_life_expectancy AS wle1
INNER JOIN world_life_expectancy AS wle2
    ON wle1.country = wle2.country
    AND wle1.year = wle2.year - 1
INNER JOIN world_life_expectancy AS wle3
    ON wle1.country = wle3.country
    AND wle1.year = wle3.year + 1
SET wle1.`Life expectancy` = ROUND((wle2.`Life expectancy` + wle3.`Life expectancy`) / 2, 1)
WHERE wle1.`Life expectancy` = '';

SELECT 
    country,
    MIN(`Life expectancy`) AS min_life_expectancy,
    MAX(`Life expectancy`) AS max_life_expectancy,
    ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS life_increase_15_years
FROM 
    world_life_expectancy
GROUP BY
    country
HAVING
    min_life_expectancy <> 0
    AND max_life_expectancy <> 0
ORDER BY
    life_increase_15_years DESC
LIMIT 
    5;

SELECT 
    country,
    MIN(`Life expectancy`) AS min_life_expectancy,
    MAX(`Life expectancy`) AS max_life_expectancy,
    ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS life_increase_15_years
FROM 
    world_life_expectancy
GROUP BY
    country
HAVING
    min_life_expectancy <> 0
    AND max_life_expectancy <> 0
ORDER BY
    life_increase_15_years ASC
LIMIT 
    5;

SELECT
    year,
    ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy
FROM
    world_life_expectancy
WHERE
    `Life expectancy` <> 0
GROUP BY
    year
ORDER BY
    year;

SELECT 
    country,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy,
    ROUND(AVG(GDP), 1) AS avg_gdp
FROM 
    world_life_expectancy
GROUP BY
    country
HAVING
    avg_life_expectancy <> 0
    AND avg_gdp <> 0
ORDER BY
    avg_gdp DESC
LIMIT
    5;

SELECT 
    country,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy,
    ROUND(AVG(GDP), 1) AS avg_gdp
FROM 
    world_life_expectancy
GROUP BY
    country
HAVING
    avg_life_expectancy <> 0
    AND avg_gdp <> 0
ORDER BY
    avg_gdp ASC
LIMIT
    5;

SELECT
    GDP
FROM
    world_life_expectancy
WHERE
    GDP <> 0
ORDER BY
    GDP
LIMIT
    1
OFFSET
    1244;

SELECT 
    SUM(CASE WHEN GDP >= 1765 THEN 1 ELSE 0 END) AS high_GDP,
    ROUND(AVG(CASE WHEN GDP >= 1765 THEN `Life expectancy` ELSE NULL END), 1) AS high_GDP_life_expectancy,
    SUM(CASE WHEN GDP < 1765 THEN 1 ELSE 0 END) AS low_GDP,
    ROUND(AVG(CASE WHEN GDP < 1765 THEN `Life expectancy` ELSE NULL END), 1) AS low_GDP_life_expectancy
FROM 
    world_life_expectancy
WHERE 
    GDP <> 0
    AND `Life expectancy` <> 0;

SELECT 
    status,
    COUNT(DISTINCT country) AS number_of_countries,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy
FROM 
    world_life_expectancy
WHERE
    `Life expectancy` <> 0
GROUP BY
    status;

SELECT 
    country,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy,
    ROUND(AVG(BMI), 1) AS avg_BMI
FROM 
    world_life_expectancy
WHERE
    BMI <> 0
    AND `Life expectancy` <> 0
GROUP BY
    country
ORDER BY
    avg_BMI DESC
LIMIT
    10;

SELECT 
    country,
    ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy,
    ROUND(AVG(BMI), 1) AS avg_BMI
FROM 
    world_life_expectancy
WHERE
    BMI <> 0
    AND `Life expectancy` <> 0
GROUP BY
    country
ORDER BY
    avg_BMI ASC
LIMIT
    10;

SELECT
    country,
    SUM(`Adult Mortality`) AS 15_year_adult_mortality
FROM
    world_life_expectancy
WHERE
    `Adult Mortality` <> 0
GROUP BY
    country
ORDER BY
    15_year_adult_mortality ASC
LIMIT
    1

SELECT
    country,
    SUM(`Adult Mortality`) AS 15_year_adult_mortality
FROM
    world_life_expectancy
WHERE
    `Adult Mortality` <> 0
GROUP BY
    country
ORDER BY
    15_year_adult_mortality DESC
LIMIT
    1

SELECT 
    country,
    year,
    `Life expectancy`,
    `Adult Mortality`,
    SUM(`Adult Mortality`) OVER(PARTITION BY country ORDER BY year) AS rolling_total
FROM 
    world_life_expectancy
WHERE
    `Life expectancy` <> 0
    AND country = 'Tunisia';

SELECT 
    country,
    year,
    `Life expectancy`,
    `Adult Mortality`,
    SUM(`Adult Mortality`) OVER(PARTITION BY country ORDER BY year) AS rolling_total
FROM 
    world_life_expectancy
WHERE
    `Life expectancy` <> 0
    AND country = 'Lesotho';
