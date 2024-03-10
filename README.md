# World Life Expectancy: Data Cleaning and EDA

**Table of Contents**

-   [Project Overview](#project-overview)
-   [Part 1: Data Cleaning](#part-1-data-cleaning)
    - [Step 1: Identifying Duplicates in the Data](#step-1-identifying-duplicates-in-the-data)
    - [Step 2: Removing Duplicates From the Data](#step-2-removing-duplicates-from-the-data)
    - [Step 3: Investigating Blank Values in the Status Column](#step-3-investigating-blank-values-in-the-status-column)
    - [Step 4: Filling in Blank Values in the Status Column](#step-4-filling-in-blank-values-in-the-status-column)
-   [Part 2: Exploratory Data Analysis](#part-2-exploratory-data-analysis)


# Project Overview



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

### Step 3: Investigating Blank Values in the Status Column
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

### Step 4: Filling in Blank Values in the Status Column

We've discovered that the **Status** column keeps track of whether a country is developing or developed - it should be possible to fill in those blank values by looking at a country's status from previous years.

<br>

------------------------------------------------------------------------

# Part 2: Exploratory Data Analysis
