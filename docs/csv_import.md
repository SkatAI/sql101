# Loading CSV Files into PostgreSQL
## From Spreadsheet to Database

---

# The CSV Import Challenge

**Common Problems You'll Face:**
- 🔤 Character encoding (é, à, ñ, 中文)
- ❌ Missing values (empty cells, NULL, N/A)
- 📊 Wrong separators (`;` instead of `,`)
- 🔢 Type mismatches ("123" as text vs 123 as number)
- 📅 Date formats (DD/MM/YYYY vs MM/DD/YYYY)

*We'll handle all of these!*

---

# Two Paths to Import

## 1. **psql** (Command Line)
- ✅ Fast and scriptable
- ✅ Good for automation
- ❌ No visual feedback
- 💻 For terminal lovers

## 2. **pgAdmin** (GUI)
- ✅ Visual and intuitive
- ✅ Preview before import
- ❌ More clicks required
- 🖱️ For GUI fans

---

# Method 1: Using psql
## The Power User Way

```bash
# Connect to your database
psql -U username -d database_name

# Inside psql, use COPY command
\COPY table_name FROM 'path/to/file.csv' WITH (options);
```

**Note**: `\COPY` runs client-side (your computer)
`COPY` runs server-side (database server)

---

# Basic psql Import

```sql
-- Assuming table 'movies' exists
\COPY movies FROM '/home/user/imdb_top_1000.csv' 
WITH (
    FORMAT CSV,
    HEADER true,
    DELIMITER ','
);
```

**What this means:**
- `FORMAT CSV`: It's a CSV file
- `HEADER true`: First row contains column names
- `DELIMITER ','`: Columns separated by commas

---

# Handling French CSVs (Semicolon)

```sql
-- French Excel exports with semicolons
\COPY movies FROM '/home/user/films_francais.csv'
WITH (
    FORMAT CSV,
    HEADER true,
    DELIMITER ';'  -- Semicolon separator!
);
```

**Pro tip**: Open CSV in text editor first to check delimiter!

---

# Character Encoding Issues

```sql
-- UTF-8 (handles é, à, ñ, etc.)
\COPY movies FROM '/home/user/imdb_top_1000.csv'
WITH (
    FORMAT CSV,
    HEADER true,
    DELIMITER ',',
    ENCODING 'UTF8'
);

-- Windows Latin-1 encoding (older files)
\COPY movies FROM '/home/user/old_movies.csv'
WITH (
    FORMAT CSV,
    HEADER true,
    DELIMITER ',',
    ENCODING 'LATIN1'
);

-- When in doubt, convert file first:
-- Linux/Mac: iconv -f ISO-8859-1 -t UTF-8 input.csv > output.csv
-- Or use: file -i yourfile.csv to check encoding
```

---

# Handling NULL/Missing Values

```sql
-- Tell PostgreSQL what represents NULL in your CSV
\COPY movies FROM '/home/user/imdb_top_1000.csv'
WITH (
    FORMAT CSV,
    HEADER true,
    DELIMITER ',',
    NULL ''  -- Empty string means NULL
);

-- Multiple NULL representations
\COPY movies FROM '/home/user/movies_messy.csv'
WITH (
    FORMAT CSV,
    HEADER true,
    DELIMITER ',',
    NULL 'N/A'  -- Treats 'N/A' as NULL
);

-- Common NULL values: '', 'NULL', 'N/A', 'None', '#N/A'
```

---

# Escaping Special Characters

```sql
-- CSV with quotes in data
\COPY movies FROM '/home/user/movies_with_quotes.csv'
WITH (
    FORMAT CSV,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',  -- Character used for quoting
    ESCAPE '\'  -- Escape character
);

-- Example CSV content:
-- "The \"Godfather\"",1972,"Crime, Drama"
-- "Mary's Movie",2020,"Romance"
```

---

# Complete psql Import Example

```sql
-- Real-world import with all safety measures
\COPY movies FROM '/home/user/imdb_top_1000.csv'
WITH (
    FORMAT CSV,
    HEADER true,
    DELIMITER ',',
    NULL '',
    ENCODING 'UTF8',
    QUOTE '"',
    ESCAPE '"'
);

-- Check what was imported
SELECT COUNT(*) FROM movies;

-- Verify encoding worked
SELECT * FROM movies 
WHERE series_title LIKE '%é%' 
   OR series_title LIKE '%ñ%';
```

---

# Method 2: Using pgAdmin
## The Visual Way

1. Right-click on your table
2. Select "Import/Export Data..."
3. Configure import settings
4. Preview and import

*Let's see each step in detail*

---

# pgAdmin Step 1: Access Import

![pgAdmin Table Menu](image-placeholder)

1. Connect to your database
2. Navigate: Servers → Your Server → Databases → Your DB → Schemas → public → Tables
3. **Right-click** on your table
4. Select **"Import/Export Data..."**

---

# pgAdmin Step 2: File Selection

**Options tab:**
- Import/Export: Choose **Import**
- Filename: Browse to your CSV file
- Format: **CSV**
- Encoding: **UTF-8** (or match your file)

```
✅ Import
📁 Filename: /path/to/imdb_top_1000.csv
📊 Format: CSV
🔤 Encoding: UTF-8
```

---

# pgAdmin Step 3: CSV Options

**Options tab (continued):**
```
✅ Header: Yes (first row has column names)
📝 Delimiter: , (or ; for French CSVs)
💬 Quote character: "
🔧 Escape character: "
```

**NULL Strings section:**
```
NULL Strings: (empty)
or
NULL Strings: N/A
```

---

# pgAdmin Step 4: Column Mapping

**Columns tab:**
- Shows source CSV columns → target table columns
- Uncheck columns you don't want to import
- Reorder if needed

```
CSV Column          →  Table Column
"Series_Title"      →  series_title
"Released_Year"     →  released_year
"IMDB_Rating"       →  imdb_rating
```

---

# pgAdmin: Common Issues & Solutions

**Issue: "ERROR: invalid input syntax for type integer"**
```sql
-- Solution: Import to temp table first
CREATE TABLE movies_temp (
    series_title TEXT,
    released_year TEXT,  -- Import as TEXT first
    runtime TEXT,         -- Import as TEXT first
    imdb_rating TEXT      -- Import as TEXT first
);

-- After import, convert and move:
INSERT INTO movies 
SELECT 
    series_title,
    CAST(NULLIF(released_year, '') AS INTEGER),
    CAST(NULLIF(runtime, '') AS INTEGER),
    CAST(NULLIF(imdb_rating, '') AS DECIMAL)
FROM movies_temp;
```

---

# The Staging Table Strategy
## When Direct Import Fails

```sql
-- 1. Create staging table (all TEXT columns)
CREATE TABLE movies_staging (
    series_title TEXT,
    released_year TEXT,
    runtime TEXT,
    imdb_rating TEXT,
    gross TEXT
);

-- 2. Import CSV to staging (no type errors!)
\COPY movies_staging FROM 'movies.csv' WITH CSV HEADER;

-- 3. Clean and transfer to final table
INSERT INTO movies (series_title, released_year, runtime, imdb_rating, gross)
SELECT 
    series_title,
    CASE 
        WHEN released_year ~ '^\d{4}$' THEN released_year::INTEGER
        ELSE NULL 
    END,
    REPLACE(runtime, ' min', '')::INTEGER,
    imdb_rating::DECIMAL,
    REPLACE(REPLACE(gross, '$', ''), ',', '')::BIGINT
FROM movies_staging;
```

---

# Data Cleaning During Import

```sql
-- Common cleaning operations during transfer
INSERT INTO movies_clean
SELECT 
    TRIM(series_title),                    -- Remove spaces
    UPPER(certificate),                     -- Standardize
    REGEXP_REPLACE(gross, '[^0-9]', '', 'g')::BIGINT,  -- Extract numbers
    TO_DATE(release_date, 'DD/MM/YYYY'),   -- Parse dates
    COALESCE(meta_score, 0),                -- Default values
    CASE 
        WHEN runtime LIKE '%h%' THEN        -- Handle "2h 30min" format
            SPLIT_PART(runtime, 'h', 1)::INT * 60 + 
            COALESCE(
                REGEXP_REPLACE(SPLIT_PART(runtime, 'h', 2), '[^0-9]', '', 'g')::INT, 
                0
            )
        ELSE 
            REGEXP_REPLACE(runtime, '[^0-9]', '', 'g')::INT
    END as runtime_minutes
FROM movies_staging;
```

---

# Pre-Import Checklist

**Before importing, check your CSV:**

```bash
# Check encoding
file -i movies.csv

# Preview first lines
head -n 5 movies.csv

# Check delimiter
head -n 1 movies.csv | tr ',' '\n' | wc -l  # comma count
head -n 1 movies.csv | tr ';' '\n' | wc -l  # semicolon count

# Check for BOM (Byte Order Mark)
hexdump -C movies.csv | head -n 1
# If starts with EF BB BF, it has BOM - remove it!
```

---

# Troubleshooting Guide

| Error | Cause | Solution |
|-------|-------|----------|
| "ERROR: invalid byte sequence" | Wrong encoding | Check file encoding, use correct ENCODING option |
| "ERROR: extra data after last expected column" | Delimiter in data | Use QUOTE option or clean data |
| "ERROR: missing data for column" | Wrong delimiter | Check CSV delimiter (`,` vs `;`) |
| "ERROR: invalid input syntax for type" | Type mismatch | Use staging table approach |
| "ERROR: value too long for type" | Column too small | Increase column size or truncate |

---

# Performance Tips

```sql
-- For large files (>100MB)

-- 1. Drop indexes before import
DROP INDEX IF EXISTS idx_movie_rating;

-- 2. Import data
\COPY movies FROM 'huge_file.csv' WITH CSV HEADER;

-- 3. Recreate indexes after
CREATE INDEX idx_movie_rating ON movies(imdb_rating);

-- 4. Update statistics
ANALYZE movies;

-- 5. For HUGE files, increase memory
SET maintenance_work_mem = '1GB';  -- Temporary for session
```

---

# Quick Reference: psql

```sql
-- Basic import
\COPY table FROM 'file.csv' WITH CSV HEADER;

-- French CSV with all options
\COPY table FROM 'file.csv' 
WITH (
    FORMAT CSV,
    HEADER true,
    DELIMITER ';',
    NULL '',
    ENCODING 'UTF8'
);

-- Check import
\d table  -- Structure
SELECT COUNT(*) FROM table;  -- Row count
```

---

# Quick Reference: pgAdmin

1. **Right-click table** → Import/Export Data
2. **Select file** and encoding
3. **Set delimiter** (`,` or `;`)
4. **Handle NULLs** (empty string or 'N/A')
5. **Map columns** if needed
6. **Click OK** and monitor Messages tab

---

# Best Practices

1. **Always backup** before bulk imports
2. **Test with 10 rows** first
3. **Use staging tables** for messy data
4. **Check encoding** before import
5. **Verify row counts** after import
6. **Document your import process**

```sql
-- Quick test import
\COPY movies FROM 'test_10_rows.csv' WITH CSV HEADER;
SELECT * FROM movies;  -- Verify it looks correct
TRUNCATE movies;  -- Clear test data
\COPY movies FROM 'full_file.csv' WITH CSV HEADER;
```

---

# Remember

- **psql**: Fast, scriptable, command-line
- **pgAdmin**: Visual, friendly, good for beginners
- **Staging tables**: Your safety net for messy data
- **Encoding matters**: UTF-8 for modern files
- **Delimiters vary**: Check if `,` or `;`
- **NULL handling**: Define what empty means

*Clean data at import time saves hours of debugging later!*