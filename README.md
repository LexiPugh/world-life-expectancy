# World Life Expectancy: Data Cleaning and EDA

**Table of Contents**

-   [Project Overview](#project-overview)
-   [Part 1: Data Cleaning](#part-1-data-cleaning)
    - [Step 1: Identifying Duplicates in the Data](#step-1-identifying-duplicates-in-the-data)
    - [Step 2: Removing Duplicates From the Data](#step-2-removing-duplicates-from-the-data)
-   [Part 2: Exploratory Data Analysis](#part-2-exploratory-data-analysis)


# Project Overview



<br>

------------------------------------------------------------------------

# Part 1: Data Cleaning

### Step 1: Identifying Duplicates in the Data
- While there isn't a unique identifier column such as a customer_id, looking at the **Country** and **Year** fields together will help identify duplicates. Each country should only have one row in the dataset per year.

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
- There are only three duplicates in the data, so it would be very easy to identify the **row_id** of each and simply drop them. However, when dealing with millions of rows of data where there could be hundreds or thousands of duplicates, this is not a feasible solution. Instead, a query can be written to identify all the duplicate rows and delete them from the table.

    ``` SQL
    DELETE FROM world_life_expectancy
    WHERE row_id IN (
        SELECT 
            row_id
        FROM (
            SELECT
                row_id,
                CONCAT(country, year),
                ROW_NUMBER() OVER(PARTITION BY CONCAT(country, year) ORDER BY CONCAT(country, year)) AS unique_row_num
            FROM 
                world_life_expectancy
    		) AS unique_row_table
        WHERE unique_row_num > 1
    );
    ```
 - Query Breakdown
     - The innermost query is using the ROW_NUMBER() window function to


<br>

------------------------------------------------------------------------

# Part 2: Exploratory Data Analysis
