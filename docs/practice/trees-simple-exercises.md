# SQL Exercises: The Paris Trees Investigation
## A Data Quality Adventure

---

## The Story

You've just been hired by the Paris Parks Department. Your first day on the job, your manager drops a CSV file on your desk:

*"We have a problem. We're supposed to have a complete inventory of every tree in Paris, but nobody trusts our database. The city council wants to know how many trees we have, which species are most common, and which trees need maintenance. Can you help us figure out what's going on?"*

You open the file and see it's a mess. Time to investigate!

---

## Part 1: Loading the Suspicious Data

### Exercise 1.1: Create a Table That Accepts Everything

Your first instinct is to create a proper database table, but you quickly realize the data is too messy. You need to load it first, then clean it.

**Task:** Create a table that can accept ANY data from the CSV file.

```sql
-- Create a staging table with all TEXT columns (French column names)
CREATE TABLE arbres_raw (
    idbase TEXT,
    id_location TEXT,
    location_type TEXT,
    domain TEXT,
    arrondissement TEXT,
    name TEXT,
    genre TEXT,
    circonference TEXT,
    height TEXT
);
```

### Exercise 1.2: Load the Data

```sql
-- Load the CSV file
\COPY arbres_raw FROM 'trees_simple.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');

-- How many trees did we load?
SELECT COUNT(*) FROM arbres_raw;
```

**Expected Output:**
```
count
------
  99
```

---

## Part 2: The Investigation Begins

Your manager asks: *"So, how many trees do we actually have data for?"*

### Exercise 2.1: First Look at the Data

**Question:** What does our data actually look like?

```sql
-- Look at the first 5 trees
SELECT * FROM arbres_raw LIMIT 5;
```

**Hint:** Notice anything strange about the values? Some columns might be empty...

### Exercise 2.2: The Mystery of the IDs

**Question:** Are our tree IDs unique? Your manager insists every tree has a unique `idbase`.

```sql
-- Check if idbase values are unique
SELECT 
    idbase, 
    COUNT(*) as occurrences
FROM arbres_raw
GROUP BY idbase
HAVING COUNT(*) > 1;
```

**Expected Output:**
```
idbase | occurrences
-------+------------
(0 rows)  -- Good! They're unique
```

### Exercise 2.3: The Empty Names Mystery

A colleague mentions: *"I heard some trees don't even have names in our system!"*

**Question:** How many trees are missing their common name?

```sql
-- Count trees with no name
SELECT 
    COUNT(*) FILTER (WHERE name IS NULL OR name = '') as trees_without_names,
    COUNT(*) as total_trees,
    ROUND(100.0 * COUNT(*) FILTER (WHERE name IS NULL OR name = '') / COUNT(*), 1) as percentage
FROM arbres_raw;
```

**Expected Output:**
```
trees_without_names | total_trees | percentage
--------------------+-------------+-----------
                  2 |          99 |       2.0
```

---

## Part 3: The Scientific Names Problem

The botanist on your team complains: *"The database is useless! Some trees don't even have their scientific genus recorded!"*

### Exercise 3.1: Missing Scientific Information

**Question:** How many trees are missing their scientific genus?

```sql
-- Find trees without genre (scientific genus)
SELECT 
    COUNT(*) FILTER (WHERE genre IS NULL OR genre = '') as missing_genus,
    COUNT(*) as total
FROM arbres_raw;
```

### Exercise 3.2: Trees with Missing Data

**Question:** Which trees have no name AND no genus? These are basically unknown trees!

```sql
-- Find the phantom trees
SELECT 
    idbase,
    arrondissement,
    circonference,
    height
FROM arbres_raw
WHERE (name IS NULL OR name = '') 
  AND (genre IS NULL OR genre = '');
```

**Hint:** If you find any, these trees exist physically but we don't know what they are!

---

## Part 4: The Measurement Mysteries

The maintenance team calls: *"We need to know which trees to check, but the measurements in the database make no sense!"*

### Exercise 4.1: Exploring Tree Measurements

**Question:** What's the range of tree heights in our database?

```sql
-- Check height values
SELECT 
    MIN(height) as shortest,
    MAX(height) as tallest
FROM arbres_raw;
```

**Problem:** You get an unexpected result! The values are TEXT, so '9' > '10' alphabetically!

### Exercise 4.2: Trees with Zero Height

**Question:** Do we really have trees with height = 0?

```sql
-- Find trees with zero height
SELECT 
    idbase,
    name,
    height,
    circonference
FROM arbres_raw
WHERE height = '0';
```

**Expected Output:**
```
You'll find several trees with height = 0, which is impossible!
```

### Exercise 4.3: Converting to Numbers for Analysis

**Question:** What's the ACTUAL average height of our trees?

```sql
-- First attempt - this will fail!
SELECT AVG(height) FROM arbres_raw;
-- ERROR: function avg(text) does not exist

-- Second attempt - cast to numeric
SELECT 
    AVG(CAST(height AS INTEGER)) as average_height
FROM arbres_raw
WHERE height != '0';  -- Exclude the impossible zeros
```

**Problem:** But wait, what about NULL values?

---

## Part 5: The NULL Value Trap

Your manager asks: *"What's the average circumference of our trees? The mayor wants to know!"*

### Exercise 5.1: The Dangerous Average

**Question:** Calculate the average circumference. But be careful!

```sql
-- What happens with NULLs in calculations?
SELECT 
    COUNT(*) as total_trees,
    COUNT(circonference) as trees_with_circonference,
    COUNT(*) FILTER (WHERE circonference = '') as empty_circonference,
    AVG(CAST(NULLIF(circonference, '') AS INTEGER)) as avg_circonference
FROM arbres_raw;
```

**Important Discovery:** 
- COUNT(*) counts all rows
- COUNT(column) skips NULLs
- AVG() ignores NULLs completely!

### Exercise 5.2: The Missing Data Report

**Question:** Create a report showing how many trees have missing data for each measurement.

```sql
-- Missing data summary
SELECT 
    'circonference' as field,
    COUNT(*) FILTER (WHERE circonference IS NULL OR circonference = '') as missing,
    COUNT(*) FILTER (WHERE circonference = '0') as zeros,
    COUNT(*) as total
FROM arbres_raw
UNION ALL
SELECT 
    'height',
    COUNT(*) FILTER (WHERE height IS NULL OR height = ''),
    COUNT(*) FILTER (WHERE height = '0'),
    COUNT(*)
FROM arbres_raw;
```

---

## Part 6: Creating a Clean Table

Your manager is impressed: *"Now that you understand the problems, can you create a proper database?"*

### Exercise 6.1: Design a Better Table

**Task:** Create a new table with proper data types and constraints.

```sql
-- Create a clean table with constraints
CREATE TABLE arbres (
    -- Add a new primary key since idbase is weird
    tree_id SERIAL PRIMARY KEY,
    
    -- Original IDs for reference
    idbase INTEGER UNIQUE NOT NULL,
    id_location TEXT NOT NULL,
    
    -- Location info
    location_type TEXT NOT NULL,
    domain TEXT NOT NULL,
    arrondissement TEXT NOT NULL,
    
    -- Tree identification (allow NULL for unknown trees)
    name TEXT,
    genre TEXT,
    
    -- Measurements as numbers with constraints
    circonference INTEGER CHECK (circonference > 0),
    height INTEGER CHECK (height > 0)
);
```

### Exercise 6.2: Cleaning Data During Migration

**Question:** How do we handle the problematic zeros when migrating?

```sql
-- Migrate data, converting zeros to NULL
INSERT INTO arbres (
    idbase, id_location, location_type, 
    domain, arrondissement, name, genre,
    circonference, height
)
SELECT 
    CAST(idbase AS INTEGER),
    id_location,
    location_type,
    domain,
    arrondissement,
    NULLIF(name, ''),  -- Convert empty string to NULL
    NULLIF(genre, ''),
    NULLIF(CAST(circonference AS INTEGER), 0),  -- Convert 0 to NULL
    NULLIF(CAST(height AS INTEGER), 0)
FROM arbres_raw
WHERE idbase IS NOT NULL;  -- Safety check
```

---

## Part 7: Testing Our Constraints

### Exercise 7.1: Can We Insert Bad Data Now?

**Question:** Try to insert a tree with impossible measurements. What happens?

```sql
-- This should fail!
INSERT INTO arbres (idbase, id_location, location_type, domain, arrondissement, height)
VALUES (999999, 'TEST', 'Arbre', 'Test', 'PARIS', -5);
```

**Expected Output:**
```
ERROR: new row for relation "arbres" violates check constraint "arbres_height_check"
```

### Exercise 7.2: Working with NULL Values Safely

**Question:** Calculate the average height, handling NULLs properly.

```sql
-- Safe calculation with NULLs
SELECT 
    COUNT(*) as total_trees,
    COUNT(height) as trees_with_height,
    ROUND(AVG(height), 1) as avg_height_meters,
    MIN(height) as shortest,
    MAX(height) as tallest
FROM arbres
WHERE height IS NOT NULL;
```

---

## Part 8: The Final Report

Your manager needs a final report for the city council.

### Exercise 8.1: Data Quality Summary

**Task:** Create a summary showing how many trees have complete vs incomplete data.

```sql
-- Data completeness report
SELECT 
    COUNT(*) as total_trees,
    COUNT(*) FILTER (
        WHERE name IS NOT NULL 
        AND genre IS NOT NULL 
        AND circonference IS NOT NULL 
        AND height IS NOT NULL
    ) as complete_records,
    COUNT(*) FILTER (
        WHERE name IS NULL 
        OR genre IS NULL
    ) as unknown_species,
    COUNT(*) FILTER (
        WHERE circonference IS NULL 
        OR height IS NULL
    ) as missing_measurements
FROM arbres;
```

### Exercise 8.2: Species Distribution

**Question:** What are the most common tree genera in Paris?

```sql
-- Top 5 tree genera
SELECT 
    COALESCE(genre, 'Unknown') as genus,
    COUNT(*) as count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) as percentage
FROM arbres
GROUP BY genre
ORDER BY count DESC
LIMIT 5;
```

---

## Part 9: Reflection Questions

Now that you've cleaned the data, consider these questions:

### Question 1: The NULL Dilemma
Your colleague asks: *"Should we use 0 or NULL for missing measurements?"*

```sql
-- Compare the impact:
-- With NULL:
SELECT AVG(height) FROM arbres;  -- NULLs ignored

-- If we had used 0:
SELECT AVG(height) FROM arbres_raw WHERE CAST(height AS INTEGER) >= 0;  -- Zeros included!
```

**Answer:** NULL is better! Zero would incorrectly lower our averages.

### Question 2: Primary Key Choice
*"Why did we add tree_id instead of using idbase as primary key?"*

```sql
-- Check idbase values
SELECT 
    MIN(CAST(idbase AS INTEGER)) as min_id,
    MAX(CAST(idbase AS INTEGER)) as max_id,
    COUNT(DISTINCT idbase) as unique_values
FROM arbres_raw;
```

**Answer:** idbase has huge gaps (like 249403 to 2020183). SERIAL gives us clean, sequential IDs.

### Question 3: The Empty String Problem
*"What's the difference between NULL and empty string ('')?"*

```sql
-- Demonstrate the difference
SELECT 
    NULL = NULL as null_equals_null,        -- Returns NULL!
    '' = '' as empty_equals_empty,          -- Returns TRUE
    NULL IS NULL as null_is_null,           -- Returns TRUE
    '' IS NULL as empty_is_null;            -- Returns FALSE
```

**Answer:** They're different! That's why we converted empty strings to NULL for consistency.

---

## Conclusion: What You've Learned

Through this investigation, you've discovered:

1. **Real data is messy** - Empty strings, zeros, missing values everywhere
2. **TEXT columns accept anything** - But make analysis impossible
3. **NULLs affect calculations** - COUNT(*) vs COUNT(column), AVG ignores NULLs
4. **Constraints prevent future messes** - CHECK constraints stop bad data
5. **Primary keys matter** - SERIAL is cleaner than weird existing IDs
6. **Data cleaning requires decisions** - Convert 0 to NULL? Empty string to NULL?

Your manager is thrilled: *"Excellent work! The city council finally trusts our tree inventory. You've turned chaos into clarity!"*

---

## Bonus Challenge

If you finish early, try this:

**Question:** Find trees that might be data entry errors (suspiciously large or small).

```sql
-- Find outliers
SELECT 
    tree_id,
    name,
    genre,
    height,
    circonference,
    ROUND(circonference::NUMERIC / height, 1) as circ_height_ratio
FROM arbres
WHERE height IS NOT NULL 
  AND circonference IS NOT NULL
  AND height > 0
ORDER BY circ_height_ratio DESC
LIMIT 5;
```

**Hint:** A ratio > 20 might indicate swapped values or typos!