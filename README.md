# World Life Expectancy: Data Cleaning and EDA

**Table of Contents**

-   [Project Overview](#project-overview)
-   [Part 1: Data Cleaning](#part-1-data-cleaning)
    - [Step 1: Identifying Duplicates in the Data](#step-1-identifying-duplicates-in-the-data)
    - [Step 2: Removing Duplicates From the Data](#step-2-removing-duplicates-from-the-data)
    - [Step 3: Investigating the Blank Values in the Status Column](#step-3-investigating-the-blank-values-in-the-status-column)
    - [Step 4: Filling in the Blank Values in the Status Column](#step-4-filling-in-the-blank-values-in-the-status-column)
    - [Step 5: Investigating the Blank Values in the Life Expectancy Column](#step-5-investigating-the-blank-values-in-the-life-expectancy-column)
    - [Step 6: Filling in the Blank Values in the Life Expectancy Column](#step-6-filling-in-the-blank-values-in-the-life-expectancy-column)
-   [Part 2: Exploratory Data Analysis](#part-2-exploratory-data-analysis)


# Project Overview



<br>
<br>

------------------------------------------------------------------------

# Part 1: Data Cleaning

### Step 1: Identifying Duplicates in the Data
While there isn't a unique identifier column in this dataset, looking at the **Country** and **Year** fields together will help identify duplicates. Each country should only have one row in the dataset per year.
- Using the CONCAT() function to combine the country and year creates a field that has (or at least should have) unique values for each row. Using the COUNT() function on the result tells us how many times each combination appears.
- Grouping on country and year will then output a count for each row. We can then use the HAVING keyword to filter on the aggregation - any row that has a count greater than 1 is a duplicate.

``` SQL
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
 ```
    
Output Table:
| country  | year | duplicates |
| :------- | :--- | :--------- |
| Ireland  | 2022 | 2          |
| Senegal  | 2009 | 2          |
| Zimbabwe | 2019 | 2          |

<br>

### Step 2: Removing Duplicates From the Data
There are only three duplicates in the data, so it would be very easy to identify the **Row_ID** of each and simply drop them. However, when dealing with millions of rows of data where there could be hundreds or thousands of duplicates, this is not a feasible solution. Instead, a query can be written to identify all the duplicate rows and delete them from the table.
- The innermost query is using the ROW_NUMBER() window function to assign a row number to each combination of country/year, which we achieved with the CONCAT() function. A non-duplicate record will have a row number of 1, while any duplicate records will be assigned a row number greater than 1.
- To filter to records where the row number is greater than 1, the query where we assigned the row numbers must be used as a subquery. We SELECT the row_id from that query, but only WHERE the row number is greater than 1.
- Finally, the outermost query deletes records from world_life_expectancy where the row_id of the record is found within the queries that check for duplicates - this deletes the 3 duplicate records, and would delete any others if there had been more.

``` SQL
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
```

<br>

### Step 3: Investigating the Blank Values in the Status Column
While glancing over the dataset, I noticed a blank value in the **Status** column. Let's identify all the rows that are missing a status.

``` SQL
SELECT 
    country,
    year,
    status
FROM 
    world_life_expectancy
WHERE 
    status = '';
```

Output Table:
| country                  | year | status |
| :----------------------- | :--- | :----- |
| Afghanistan              | 2014 |        |
| Albania                  | 2021 |        |
| Georgia                  | 2012 |        |
| Georgia                  | 2010 |        |
| United States of America | 2021 |        |
| Vanuatu                  | 2020 |        |
| Zambia                   | 2016 |        |
| Zambia                   | 2012 |        |

There are a good chunk of rows missing a status. Let's see what type of data goes into the **Status** column to see if we might be able to fill those missing values in.

``` SQL
SELECT
    DISTINCT(status)
FROM 
    world_life_expectancy
WHERE 
    status <> '';
```

Output Table:

| status     |
| :--------- |
| Developing |
| Developed  |

<br>

### Step 4: Filling in the Blank Values in the Status Column
We've discovered that the **Status** column keeps track of whether a country is developing or developed - it should be possible to fill in those blank values by looking at a country's status from previous years.
- I originally attempted to accomplish this with a subquery, but ended up getting the desired output by self-joining the data on country instead. I set the status of the first table equal to developing, but only on the condition that in the second table, there existed a record where status was not blank, and also equal to developing.
- To summarize, the query is connecting the country in both tables - if the country has a value for the **Status** column in the second table, it can fill in the blanks in the first table with that same value. I used a similar query to fill in the developed countries as well, so the **Status** column now has zero blanks.

``` SQL
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
```

``` SQL
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
```

<br>

### Step 5: Investigating the Blank Values in the Life Expectancy Column
While looking over the dataset, I also noticed a blank in the **Life Expectancy** column. Let's take a look at all of the rows missing a life expectancy value.

``` SQL
SELECT 
    country,
    year,
    `Life expectancy`
FROM 
    world_life_expectancy
WHERE 
    `Life expectancy` = '';
```

Output Table:

| country     | year | Life expectancy |
| :---------- | :--- | :-------------- |
| Afghanistan | 2018 |                 |
| Albania     | 2018 |                 |

There's only a couple rows missing values for **Life Expectancy**, but this one won't be as straight forward to fill in as **Status** was. Let's take a look at the life expectancy values for both countries to see if the values follow a pattern.

``` SQL
SELECT 
    country,
    year,
    `Life expectancy`
FROM 
    world_life_expectancy
WHERE
    country = 'Afghanistan'
LIMIT 
    10
```

Output Table:

| country     | year | Life expectancy |
| :---------- | :--- | :-------------- |
| Afghanistan | 2022 | 65              |
| Afghanistan | 2021 | 59.9            |
| Afghanistan | 2020 | 59.9            |
| Afghanistan | 2019 | 59.5            |
| Afghanistan | 2018 |                 |
| Afghanistan | 2017 | 58.8            |
| Afghanistan | 2016 | 58.6            |
| Afghanistan | 2015 | 58.1            |
| Afghanistan | 2014 | 57.5            |
| Afghanistan | 2013 | 57.3            |

``` SQL
SELECT 
    country,
    year,
    `Life expectancy`
FROM 
    world_life_expectancy
WHERE
    country = 'Albania'
LIMIT 
    10
```

Output Table:

| country | year | Life expectancy |
| :------ | :--- | :-------------- |
| Albania | 2022 | 77.8            |
| Albania | 2021 | 77.5            |
| Albania | 2020 | 77.2            |
| Albania | 2019 | 76.9            |
| Albania | 2018 |                 |
| Albania | 2017 | 76.2            |
| Albania | 2016 | 76.1            |
| Albania | 2015 | 75.3            |
| Albania | 2014 | 75.9            |
| Albania | 2013 | 74.2            |

<br>

### Step 6: Filling in the Blank Values in the Life Expectancy Column
While filling in blank values with estimations is not always advisable, it makes sense to do it here. There are only a couple blank rows, and the life expectancy values are following a consistent pattern - they tick up slightly over the years. To estimate the missing value, we can add the life expectancy from the prior year to the life expectancy from the following year and divide by two to calculate the average. This will get us a value directly in between those two values - it may not be exact, but it will be a good estimate of the missing life expectancy value.
- I did a double self join to solve this problem. The first table is the base table with the blank, while the second table subtracts 1 from the year, meaning it has the life expectancy value from the previous year rather than a blank. The third table adds 1 to the year, meaning it has the life expectancy value from the following year rather than a blank.
- I added the life expectancy values from the second and third tables and divided by 2 to get the average of the two values - I also used the ROUND() function to round to 1 decimal place, making our new value uniform with the rest of the life expectancy values in the table. Finally, I updated the table and set the **Life Expectancy** column in the first table equal to the new value we just calculated - of course, I only applied the calculation to rows that had blanks. This filled in all the blanks in the **Life Expectancy** column.

``` SQL
UPDATE world_life_expectancy AS wle1
INNER JOIN world_life_expectancy AS wle2
    ON wle1.country = wle2.country
    AND wle1.year = wle2.year - 1
INNER JOIN world_life_expectancy AS wle3
    ON wle1.country = wle3.country
    AND wle1.year = wle3.year + 1
SET wle1.`Life expectancy` = ROUND((wle2.`Life expectancy` + wle3.`Life expectancy`) / 2, 1)
WHERE wle1.`Life expectancy` = ''
```

<br>
<br>

------------------------------------------------------------------------

# Part 2: Exploratory Data Analysis
