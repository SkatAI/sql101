# SELECT Queries
## Mastering Data Retrieval with IMDB Top 1000

---

# The SELECT Statement
## Your Data Swiss Army Knife

```sql
SELECT    -- What columns to show (Projection)
FROM      -- Which table to query
WHERE     -- Which rows to include (Filtering)
ORDER BY  -- How to sort results
LIMIT     -- How many rows to return
```

**We'll explore each piece using real movie data**

---

# Our Dataset: IMDB Top 1000

**Columns:**
- `Series_Title`: Movie name
- `Released_Year`: When it came out
- `Runtime`: Duration in minutes
- `Genre`: Movie categories
- `IMDB_Rating`: Score (0-10)
- `Director`: Who directed it
- `Star1, Star2, Star3, Star4`: Main actors
- `No_of_Votes`: How many people rated
- `Gross`: Box office earnings

*Real movies, real data, real queries*

---

# Projection: Choosing Your Columns
## SELECT Specific Fields

**Projection** = Selecting which columns to display

Like choosing camera angles in filmmaking:
- Wide shot: `SELECT *` (all columns)
- Close-up: `SELECT title` (one column)
- Multiple angles: `SELECT title, director, year` (specific columns)

*Don't fetch data you don't need!*

---

# Demo: Projection

```sql
-- Get everything (memory heavy, often unnecessary)
SELECT * FROM movies;

-- Just the essentials
SELECT Series_Title, Released_Year, IMDB_Rating
FROM movies;

-- Director's filmography view
SELECT Series_Title, Director, Released_Year
FROM movies;

-- Quick rating check
SELECT Series_Title AS "Movie",
       IMDB_Rating AS "Score"
FROM movies;
```

---

# Filtering: Finding the Right Rows
## WHERE Clause

**Filtering** = Selecting which rows to include

Like Netflix filters:
- By genre: `WHERE Genre LIKE '%Action%'`
- By year: `WHERE Released_Year > 2000`
- By rating: `WHERE IMDB_Rating >= 8.0`

*The WHERE clause is your search bar*

---

# Demo: Filtering Basics

```sql
-- Modern classics (2000s and later)
SELECT Series_Title, Released_Year, IMDB_Rating
FROM movies
WHERE Released_Year >= 2000;

-- Highly rated films
SELECT Series_Title, IMDB_Rating, Director
FROM movies
WHERE IMDB_Rating > 8.5;

-- Christopher Nolan films
SELECT Series_Title, Released_Year, IMDB_Rating
FROM movies
WHERE Director = 'Christopher Nolan';

-- Long epics (3+ hours)
SELECT Series_Title, Runtime, Director
FROM movies
WHERE Runtime >= 180;
```

---

# Filtering: Comparison Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | Equals | `WHERE Director = 'Spielberg'` |
| `!=` or `<>` | Not equals | `WHERE Certificate != 'R'` |
| `>`, `>=` | Greater than (or equal) | `WHERE IMDB_Rating >= 8.0` |
| `<`, `<=` | Less than (or equal) | `WHERE Released_Year <= 1980` |
| `BETWEEN` | Range | `WHERE Released_Year BETWEEN 1990 AND 2000` |
| `IN` | List of values | `WHERE Director IN ('Nolan', 'Spielberg')` |
| `LIKE` | Pattern match | `WHERE Genre LIKE '%Sci-Fi%'` |

---

# Demo: Advanced Filtering

```sql
-- 90s movies (using BETWEEN)
SELECT Series_Title, Released_Year
FROM movies
WHERE Released_Year BETWEEN 1990 AND 1999;

-- Multiple directors (using IN)
SELECT Series_Title, Director, IMDB_Rating
FROM movies
WHERE Director IN ('Quentin Tarantino', 'Martin Scorsese', 'Christopher Nolan');

-- Sci-Fi movies (using LIKE with wildcards)
SELECT Series_Title, Genre, IMDB_Rating
FROM movies
WHERE Genre LIKE '%Sci-Fi%';

-- Movies with Tom Hanks in any role
SELECT Series_Title, Star1, Star2, Star3, Star4
FROM movies
WHERE Star1 = 'Tom Hanks'
   OR Star2 = 'Tom Hanks'
   OR Star3 = 'Tom Hanks'
   OR Star4 = 'Tom Hanks';
```

---

# Combining Filters: AND, OR, NOT

**AND**: All conditions must be true
**OR**: At least one condition must be true
**NOT**: Inverts the condition

```sql
-- Parentheses control precedence!
WHERE (condition1 AND condition2) OR condition3

-- Different from:
WHERE condition1 AND (condition2 OR condition3)
```

---

# Demo: Complex Filtering

```sql
-- Recent AND highly rated
SELECT Series_Title, Released_Year, IMDB_Rating
FROM movies
WHERE Released_Year >= 2010
  AND IMDB_Rating >= 8.0;

-- Action OR Adventure movies from the 2000s
SELECT Series_Title, Genre, Released_Year
FROM movies
WHERE (Genre LIKE '%Action%' OR Genre LIKE '%Adventure%')
  AND Released_Year >= 2000;

-- NOT a sequel (no numbers in title)
SELECT Series_Title
FROM movies
WHERE Series_Title NOT LIKE '%2%'
  AND Series_Title NOT LIKE '%II%'
  AND Series_Title NOT LIKE '%Part%';

-- High-rated dramas that aren't too long
SELECT Series_Title, Genre, Runtime, IMDB_Rating
FROM movies
WHERE Genre LIKE '%Drama%'
  AND IMDB_Rating >= 8.0
  AND Runtime < 150;
```

---

# ORDER BY: Sorting Your Results
## Control the Sequence

Default order is unpredictable - ORDER BY gives you control:
- `ASC`: Ascending (A→Z, 0→9) - Default
- `DESC`: Descending (Z→A, 9→0)

Can sort by multiple columns (like sorting Excel)

---

# Demo: ORDER BY

```sql
-- Top rated movies first
SELECT Series_Title, IMDB_Rating
FROM movies
ORDER BY IMDB_Rating DESC;

-- Oldest movies first
SELECT Series_Title, Released_Year
FROM movies
ORDER BY Released_Year ASC;  -- ASC is optional (default)

-- Alphabetical by title
SELECT Series_Title, Director
FROM movies
ORDER BY Series_Title;

-- Multi-level sort: Year (newest first), then rating (highest first)
SELECT Series_Title, Released_Year, IMDB_Rating
FROM movies
ORDER BY Released_Year DESC, IMDB_Rating DESC;

-- Director's best work (sort by director, then their best films)
SELECT Director, Series_Title, IMDB_Rating
FROM movies
ORDER BY Director, IMDB_Rating DESC;
```

---

# LIMIT: Controlling Result Size
## Don't Drown in Data

LIMIT restricts how many rows are returned:
- Useful for previews
- Essential for performance
- Perfect for "Top N" queries

**PostgreSQL**: `LIMIT n`
**SQL Server**: `TOP n`
**Oracle**: `FETCH FIRST n ROWS ONLY`

---

# Demo: LIMIT

```sql
-- Top 10 highest rated movies
SELECT Series_Title, IMDB_Rating
FROM movies
ORDER BY IMDB_Rating DESC
LIMIT 10;

-- 5 most recent movies
SELECT Series_Title, Released_Year
FROM movies
ORDER BY Released_Year DESC
LIMIT 5;

-- Preview the data (common for exploration)
SELECT * FROM movies
LIMIT 3;

-- Page 2 of results (items 11-20) using OFFSET
SELECT Series_Title, IMDB_Rating
FROM movies
ORDER BY IMDB_Rating DESC
LIMIT 10 OFFSET 10;

-- Bottom 5 rated movies (combine ORDER BY and LIMIT)
SELECT Series_Title, IMDB_Rating
FROM movies
ORDER BY IMDB_Rating ASC
LIMIT 5;
```

---

# String Operations: CONCAT
## Combining Text Fields

`||` or `CONCAT()` joins strings together:

```sql
-- PostgreSQL/SQLite
column1 || ' ' || column2

-- MySQL
CONCAT(column1, ' ', column2)

-- SQL Server
column1 + ' ' + column2
```

*Like using + for strings in Python*

---

# Demo: String Concatenation

```sql
-- Create a "Movie (Year)" format
SELECT Series_Title || ' (' || Released_Year || ')' AS movie_info
FROM movies
LIMIT 10;

-- Build a credits line
SELECT Series_Title,
       'Directed by ' || Director AS credits
FROM movies
LIMIT 10;

-- Create a star list
SELECT Series_Title,
       Star1 || ', ' || Star2 || ', ' || Star3 AS main_cast
FROM movies
LIMIT 10;

-- Make a movie description
SELECT Series_Title || ': A ' || Runtime || ' minute ' || Genre || ' film' AS description
FROM movies
WHERE IMDB_Rating > 8.5
LIMIT 5;

-- PostgreSQL also supports CONCAT function
SELECT CONCAT(Director, ' directed ', Series_Title) AS movie_fact
FROM movies
LIMIT 10;
```

---

# COALESCE: Handling NULL Values
## Your NULL Safety Net

`COALESCE(value1, value2, ...)` returns the first non-NULL value:

```sql
COALESCE(phone, email, 'No contact')
-- Returns phone if not NULL
-- Otherwise email if not NULL
-- Otherwise 'No contact'
```

*Essential for dealing with missing data*

---

# Demo: COALESCE

```sql
-- Replace NULL gross earnings with 'Not Available'
SELECT Series_Title,
       COALESCE(Gross, 'Not Available') AS box_office
FROM movies
LIMIT 20;

-- Handle missing Metascores
SELECT Series_Title,
       IMDB_Rating,
       COALESCE(Meta_score, 0) AS critic_score
FROM movies;

-- Fallback for missing cast members
SELECT Series_Title,
       COALESCE(Star4, Star3, Star2, Star1, 'No cast info') AS supporting_actor
FROM movies
LIMIT 20;

-- Calculate revenue with NULL handling
SELECT Series_Title,
       COALESCE(Gross, '0') AS revenue,
       No_of_Votes
FROM movies
ORDER BY No_of_Votes DESC
LIMIT 10;

-- Smart NULL replacement for display
SELECT Series_Title,
       Director,
       COALESCE(Certificate, 'Unrated') AS rating
FROM movies
WHERE Released_Year > 2010;
```

---

# CAST: Converting Data Types
## Shape-Shifting Your Data

`CAST(expression AS type)` or `::type` (PostgreSQL)

Common conversions:
- String to number: `CAST('123' AS INTEGER)`
- Number to string: `CAST(2024 AS TEXT)`
- String to date: `CAST('2024-01-15' AS DATE)`

*Like int() or str() in Python*

---

# Demo: Type Casting

```sql
-- Convert year to text for concatenation
SELECT Series_Title || ' from the ' || CAST(Released_Year AS TEXT) || 's' AS movie_era
FROM movies
WHERE Released_Year < 1990;

-- PostgreSQL shorthand with ::
SELECT Series_Title || ' (' || Released_Year::TEXT || ')' AS movie_label
FROM movies
LIMIT 10;

-- Convert runtime to hours (decimal)
SELECT Series_Title,
       Runtime,
       CAST(Runtime AS FLOAT) / 60 AS hours
FROM movies
WHERE Runtime > 180;

-- Clean up Gross (remove commas, convert to numeric)
-- Note: Gross might have commas that need cleaning first
SELECT Series_Title,
       Gross,
       CAST(REPLACE(Gross, ',', '') AS BIGINT) AS gross_numeric
FROM movies
WHERE Gross IS NOT NULL
LIMIT 10;

-- Convert rating to integer for grouping
SELECT Series_Title,
       IMDB_Rating,
       CAST(IMDB_Rating AS INTEGER) AS rating_bucket
FROM movies
ORDER BY IMDB_Rating DESC
LIMIT 20;
```

---

# Combining It All Together
## The Power of SELECT

```sql
-- Find top modern action movies with complete info
SELECT
    Series_Title || ' (' || Released_Year::TEXT || ')' AS movie,
    'Dir: ' || Director AS director,
    COALESCE(Star1, 'Unknown') || ', ' || COALESCE(Star2, '') AS stars,
    CAST(Runtime AS FLOAT) / 60 AS hours,
    IMDB_Rating
FROM movies
WHERE Genre LIKE '%Action%'
    AND Released_Year >= 2000
    AND IMDB_Rating >= 7.0
ORDER BY IMDB_Rating DESC, Released_Year DESC
LIMIT 15;
```

**This one query uses everything we learned!**

---

# Common Patterns

```sql
-- Pattern 1: Top N by category
SELECT * FROM movies
WHERE Genre LIKE '%Horror%'
ORDER BY IMDB_Rating DESC
LIMIT 10;

-- Pattern 2: NULL-safe concatenation
SELECT COALESCE(Star1, 'Unknown') || ' in ' || Series_Title
FROM movies;

-- Pattern 3: Year range analysis
SELECT * FROM movies
WHERE CAST(Released_Year AS INTEGER) BETWEEN 2010 AND 2020
ORDER BY Released_Year;

-- Pattern 4: Multi-condition filtering
SELECT * FROM movies
WHERE Runtime < 120
  AND IMDB_Rating > 8.0
  AND Released_Year >= 2000;
```

---

# Exercise Ideas

1. **Find all 90s comedies over 8.0 rating**
2. **List Spielberg movies sorted by year**
3. **Top 20 longest movies with their runtime in hours**
4. **Movies with Leonardo DiCaprio (check all 4 star columns)**
5. **Create a "movie card" with title, year, director, and stars concatenated**

---

# Remember

- **Projection** (`SELECT`): Choose your columns
- **Filtering** (`WHERE`): Choose your rows
- **Ordering** (`ORDER BY`): Control the sequence
- **Limiting** (`LIMIT`): Control the quantity
- **String ops** (`||`, `CONCAT`): Combine text
- **COALESCE**: Handle NULLs gracefully
- **CAST**: Convert between types

*Master these, and you can answer 80% of data questions*