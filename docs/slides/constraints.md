---
marp: true
theme: default
paginate: true
backgroundColor: #4f7cff
color: white
header: 'SQL 101'
footer: 'Alexis Perrier'
style: |
  h1, h2, h3 {
    color: white;
  }
  .lead {
    font-size: 1.5em;
  }
---

# Module 3: Data Types and Constraints
## Building Robust Database Tables

---

## Today's Journey

1. **The Real World is Messy** - Why data needs structure
2. **PostgreSQL Data Types** - Choosing the right container
3. **Creating Tables** - Building with `CREATE TABLE`
4. **Constraints** - Your data quality guardians
5. **The NULL Problem** - When nothing means something
6. **Schema Evolution** - Changing tables after creation
7. **Safe Operations** - IF EXISTS pattern

---

## The Reality of Dirty Data

### What Actually Happens in Production

When Spotify ingests track data from record labels, distributors, and independent artists, the data arrives in countless formats. One label sends track duration as "3:45", another as "225" (seconds), and yet another as "3 minutes 45 seconds". Song titles come with leading spaces, trailing newlines, mixed capitalizations, and sometimes Unicode characters that look identical but aren't.

Without database constraints, your application code becomes a nightmare of validation logic. Every single function needs to check: Is this value present? Is it the right type? Is it within reasonable bounds? Did someone accidentally enter a negative duration? This defensive programming spreads like a virus through your codebase.

The worst part? Even with careful application code, one developer forgetting one validation in one API endpoint can corrupt your entire dataset. Imagine discovering that 10,000 tracks have been stored with duration as strings instead of integers. Now every calculation breaks, every average is wrong, and your recommendation algorithm crashes.

```sql
-- Real data found in production systems without constraints:
track_id | title                  | duration        | play_count
---------|------------------------|-----------------|------------
1        | 'Bohemian Rhapsody'    | 355            | 1000000
2        | 'bohemian rhapsody '   | '5:55'         | 1000000
3        | 'BOHEMIAN RHAPSODY'    | '355 seconds'  | '1 million'
4        | NULL                   | -999           | NULL
```

---

## What Are Constraints in a Database?

### The Database as Guardian

Constraints are rules enforced by the database engine itself, not by your application. They're like a security checkpoint that every piece of data must pass through before being stored. When you declare a column as NOT NULL, PostgreSQL literally will not allow any INSERT or UPDATE that would put a NULL there - it doesn't matter if the request comes from your web app, a data migration script, or a direct SQL injection attack.

Think of constraints as promises about your data that are mathematically guaranteed. When you query a column with a NOT NULL constraint, you never need to check for NULL. When you JOIN on a foreign key, you know the reference is valid. This isn't hope or convention - it's enforced by the database engine at the lowest level.

The beauty of constraints is that they're declarative, not procedural. You don't write code saying "check if this value is positive" - you declare "this column must be positive" and PostgreSQL figures out how to enforce it. This means the rule is enforced consistently, immediately, and with optimal performance.

Most importantly, constraints make invalid states impossible to represent. A track can't have a negative duration. A play count can't be the string "a lot". These aren't just validation rules that might be bypassed - they're fundamental properties of your data model.

---

## Why Is Choosing the Right Data Type Important?

### Storage, Performance, and Correctness

Every data type in PostgreSQL has specific storage characteristics, operations, and constraints. Choosing TEXT for a play count might seem harmless - after all, '1000' as text stores the same information as 1000 as an integer, right? Wrong.

First, there's storage: an INTEGER takes exactly 4 bytes, while '1000' as TEXT takes 4 bytes plus a length header. For a billion tracks, that's gigabytes of wasted space. But storage is the least of your problems.

Performance is where wrong types hurt. Want to find tracks with over a million plays? With INTEGER, PostgreSQL uses efficient numeric comparison. With TEXT, it's doing string comparison - '2' is greater than '1000000' alphabetically! Want the average play count? With INTEGER, it's a simple arithmetic operation. With TEXT, every value needs parsing, and one non-numeric value crashes the entire query.

But the real killer is correctness. Mathematical operations on TEXT fields produce nonsense. Sorting TEXT numbers gives you 1, 10, 100, 2, 20, 200. Date arithmetic on TEXT requires parsing every single value. And when you inevitably get a value like 'many' in your numeric TEXT field, your entire data pipeline breaks.

```sql
-- With wrong data type (TEXT for numbers):
SELECT * FROM tracks WHERE play_count > '1000000';
-- Returns nothing because '9' > '1000000' in string comparison!

-- With correct data type (INTEGER):
SELECT * FROM tracks WHERE play_count > 1000000;
-- Works as expected, uses index, performs 1000x faster
```

---

## Creating Your First Table - The Naive Approach

### Problem: "Just store everything about Spotify tracks"

```sql
CREATE TABLE tracks (
    track_id INTEGER,
    title TEXT,
    artist TEXT,
    album TEXT,
    duration_seconds INTEGER,
    release_date DATE,
    explicit_content BOOLEAN,
    popularity_score REAL,
    play_count INTEGER
);
```

### This Table Is A Disaster Waiting To Happen

Let's examine why this seemingly reasonable table will destroy your application:

**Problem 1: No Primary Key**
Without a primary key, you can insert the same track infinite times. Your database has no concept of identity. Queries have no efficient way to locate specific tracks. Updates might modify multiple rows accidentally. JOINs become ambiguous nightmares.

**Problem 2: Everything is Nullable**
Every single column can be NULL. You can insert a track with no title, no artist, no anything - just a row of NULLs. Your application now needs to handle the possibility that ANY field might be missing. Every calculation, every display, every query needs NULL checks.

**Problem 3: No Uniqueness Guarantees**
Two tracks can have the same ID. In fact, a million tracks could all have track_id = 1. Your foreign keys become meaningless. Your lookups return random results. Your entire relational model collapses.

**Problem 4: No Data Validation**
Duration can be negative. Popularity can be 999999. Release date can be in the year 3000. Play count can be negative billions. Every single piece of application code needs to validate these impossible values.

**Problem 5: No Defaults**
Every INSERT needs to specify every value. Forgot explicit_content? It's NULL, not false. Forgot play_count? It's NULL, not 0. Your data becomes inconsistent based on which fields different applications remember to set.

---

## Problem: "How do I ensure every track has a unique identifier?"

### The Challenge
Spotify has millions of tracks. Each needs a unique identifier that never changes, never conflicts, and can be generated without coordination between different systems adding tracks simultaneously.

### Solution: PRIMARY KEY with SERIAL

```sql
CREATE TABLE tracks (
    track_id SERIAL PRIMARY KEY,
    title TEXT,
    artist TEXT
    -- other columns...
);
```

### What PRIMARY KEY Gives You

A PRIMARY KEY is actually three constraints in one:
1. **UNIQUE** - No two rows can have the same value
2. **NOT NULL** - The value must always exist
3. **INDEX** - Automatically creates an index for fast lookups

The SERIAL type is PostgreSQL's auto-incrementing integer. Behind the scenes, it creates a sequence (a counter) that automatically provides the next value. You never specify track_id in your INSERT statements - PostgreSQL handles it.

```sql
-- You insert without specifying track_id:
INSERT INTO tracks (title, artist)
VALUES ('Shape of You', 'Ed Sheeran');

-- PostgreSQL automatically assigns track_id = 1

INSERT INTO tracks (title, artist)
VALUES ('Blinding Lights', 'The Weeknd');

-- PostgreSQL automatically assigns track_id = 2
```

---

## Why Is It OK to Have Non-Consecutive Keys?

### The Mystery of Missing Numbers

You might notice your track_ids go: 1, 2, 3, 7, 8, 9, 15... Where did 4, 5, 6 go? This is perfectly normal and actually desirable.

When PostgreSQL generates a SERIAL value, it increments the sequence immediately and never reuses that number - even if the INSERT fails. Why? Consider what happens when two users simultaneously add tracks:

1. User A starts INSERT, gets track_id = 4
2. User B starts INSERT, gets track_id = 5
3. User A's INSERT fails (maybe invalid data)
4. User B's INSERT succeeds

If PostgreSQL reused 4, User C would get it next. But what if User A's transaction isn't fully rolled back yet? What if there are foreign keys pointing to the failed track_id = 4? Reusing IDs would create chaos.

Non-consecutive IDs are a feature, not a bug. They guarantee:
- **No conflicts** during concurrent inserts
- **No confusion** about which row foreign keys reference
- **No rewriting** of related data if a transaction fails
- **Simple generation** without checking existing values

Your PRIMARY KEY is an internal identifier, not a display value. If you need consecutive numbering for display (like track numbers on an album), use a separate column.

```sql
-- DON'T try to "fix" gaps:
-- WRONG: UPDATE tracks SET track_id = 4 WHERE track_id = 7;

-- DO accept gaps as normal:
-- track_id: 1, 2, 3, 7, 8, 15, 16, 23...  ✓ Perfectly fine
```

---

## Problem: "Some tracks are missing critical information"

### The Challenge
You discover that 15% of your tracks have NULL artist fields, 30% have NULL albums, and some even have NULL titles. Your music player crashes when trying to display these. How do you prevent incomplete data from entering your database?

### Solution: NOT NULL Constraint

```sql
CREATE TABLE tracks (
    track_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,        -- Must have a title
    artist TEXT NOT NULL,       -- Must have an artist
    duration_seconds INTEGER,   -- OK to be unknown
    album TEXT                  -- Singles might not have albums
);
```

### How NOT NULL Works

When you declare a column as NOT NULL, PostgreSQL checks every INSERT and UPDATE. If the value would be NULL, the operation fails immediately with an error. This happens before the data is written, so your table never contains invalid data.

```sql
-- This INSERT fails immediately:
INSERT INTO tracks (title) VALUES ('Hello');
-- ERROR: null value in column "artist" violates not-null constraint

-- This works:
INSERT INTO tracks (title, artist)
VALUES ('Hello', 'Adele');

-- This UPDATE fails:
UPDATE tracks SET artist = NULL WHERE track_id = 1;
-- ERROR: null value in column "artist" violates not-null constraint
```

The key insight: NOT NULL moves validation from your application (where it might be forgotten) to the database (where it's always enforced).

---

## Problem: "Users keep creating duplicate Spotify accounts with the same email"

### The Challenge
Your users table has 50,000 accounts with 'john@example.com'. Password resets are chaos. Login is ambiguous. Data integrity is destroyed. How do you ensure certain values never repeat?

### Solution: UNIQUE Constraint

```sql
CREATE TABLE tracks (
    track_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    artist TEXT NOT NULL,
    isrc VARCHAR(12) UNIQUE,  -- International Standard Recording Code
    spotify_uri TEXT UNIQUE   -- Spotify's internal identifier
);
```

### How UNIQUE Works

UNIQUE creates an index and checks every INSERT and UPDATE. If the value already exists in another row, the operation fails. NULL values are considered distinct (two NULLs don't violate UNIQUE).

```sql
-- First insert succeeds:
INSERT INTO tracks (title, artist, isrc)
VALUES ('Bohemian Rhapsody', 'Queen', 'GBUM71505078');

-- Second insert with same ISRC fails:
INSERT INTO tracks (title, artist, isrc)
VALUES ('Bohemian Rhapsody Live', 'Queen', 'GBUM71505078');
-- ERROR: duplicate key value violates unique constraint

-- But NULL is allowed (and doesn't conflict):
INSERT INTO tracks (title, artist, isrc)
VALUES ('Underground Track', 'Indie Artist', NULL);
```

---

## Problem: "Tracks are being created with impossible values"

### The Challenge
Your database contains tracks with negative duration, popularity scores of 999, and release dates in the year 3050. The recommendation algorithm crashes on these impossible values. How do you ensure data makes logical sense?

### Solution: CHECK Constraint

```sql
CREATE TABLE tracks (
    track_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    artist TEXT NOT NULL,
    duration_seconds INTEGER CHECK (duration_seconds > 0),
    popularity INTEGER CHECK (popularity BETWEEN 0 AND 100),
    release_date DATE CHECK (release_date <= CURRENT_DATE),
    tempo REAL CHECK (tempo > 0 AND tempo < 500)  -- BPM realistic range
);
```

### How CHECK Works

CHECK constraints are boolean expressions that must evaluate to TRUE for the data to be accepted. They're evaluated on every INSERT and UPDATE. If the expression returns FALSE or NULL, the operation fails.

```sql
-- This fails - negative duration:
INSERT INTO tracks (title, artist, duration_seconds)
VALUES ('Test', 'Artist', -10);
-- ERROR: new row violates check constraint

-- This fails - future release date:
INSERT INTO tracks (title, artist, release_date)
VALUES ('Future Hit', 'Time Traveler', '2030-01-01');
-- ERROR: new row violates check constraint

-- This succeeds - all constraints satisfied:
INSERT INTO tracks (title, artist, duration_seconds, popularity)
VALUES ('Real Song', 'Real Artist', 180, 75);
```

---

## Problem: "Most tracks should be non-explicit, but developers forget to set the flag"

### The Challenge
When adding tracks, developers often forget to set explicit_content. Instead of defaulting to false (safe assumption), it becomes NULL, breaking parental control filters. How do you provide sensible defaults?

### Solution: DEFAULT Values

```sql
CREATE TABLE tracks (
    track_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    artist TEXT NOT NULL,
    explicit_content BOOLEAN NOT NULL DEFAULT false,
    play_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    popularity INTEGER NOT NULL DEFAULT 50  -- Start at medium popularity
);
```

### How DEFAULT Works

When you INSERT without specifying a column, PostgreSQL uses the DEFAULT value. This happens before constraint checking, so a DEFAULT can satisfy a NOT NULL constraint.

```sql
-- Insert without specifying defaulted columns:
INSERT INTO tracks (title, artist)
VALUES ('Clean Song', 'Family Band');

-- PostgreSQL automatically fills in:
-- explicit_content = false
-- play_count = 0
-- created_at = '2025-01-20 10:30:00'
-- popularity = 50

-- You can still override defaults:
INSERT INTO tracks (title, artist, explicit_content, play_count)
VALUES ('Explicit Song', 'Edgy Band', true, 1000);
```

---

## The NULL Nightmare

### Problem: "Why do my track counts keep being wrong?"

You run `SELECT COUNT(album) FROM tracks` expecting the total number of tracks, but get a smaller number. You calculate average duration but tracks with NULL duration silently disappear from the calculation. Your WHERE clauses miss rows. What's going on?

### The Three-Valued Logic Problem

In SQL, NULL isn't a value - it's the absence of a value. This creates three-valued logic: TRUE, FALSE, and NULL (unknown). Every comparison with NULL returns NULL, not FALSE. This breaks intuition and creates subtle bugs.

```sql
-- Assume we have tracks with NULL genre
CREATE TABLE tracks (
    track_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    genre TEXT  -- can be NULL
);

-- This returns NOTHING, even if genre is NULL:
SELECT * FROM tracks WHERE genre = NULL;  -- WRONG!

-- Because:
SELECT NULL = NULL;  -- Returns NULL, not TRUE
SELECT NULL != NULL; -- Returns NULL, not FALSE

-- Correct way:
SELECT * FROM tracks WHERE genre IS NULL;
SELECT * FROM tracks WHERE genre IS NOT NULL;
```

### NULL in Aggregations

NULLs are silently ignored in aggregate functions (except COUNT(*)). This leads to surprising results:

```sql
-- Sample data:
INSERT INTO tracks (title, duration_seconds) VALUES
    ('Song A', 180),
    ('Song B', NULL),
    ('Song C', 240),
    ('Song D', NULL),
    ('Song E', 300);

SELECT COUNT(*) FROM tracks;                -- 5 (counts all rows)
SELECT COUNT(duration_seconds) FROM tracks; -- 3 (skips NULLs!)
SELECT AVG(duration_seconds) FROM tracks;   -- 240, not 144!
-- Average is (180+240+300)/3, not /5

SELECT SUM(duration_seconds) FROM tracks;   -- 720 (ignores NULLs)
SELECT MAX(duration_seconds) FROM tracks;   -- 300 (ignores NULLs)
```

---

## Handling NULL Values

### Problem: "How do I deal with these NULL values breaking my queries?"

### Strategy 1: Prevention with NOT NULL
```sql
-- Don't allow NULLs in the first place:
CREATE TABLE tracks (
    track_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    artist TEXT NOT NULL,
    genre TEXT NOT NULL DEFAULT 'Unknown'
);
```

### Strategy 2: COALESCE - Your NULL Safety Net
COALESCE returns the first non-NULL value from a list. It's your primary tool for handling NULLs in queries.

```sql
-- COALESCE(value, fallback)
SELECT
    title,
    COALESCE(genre, 'Uncategorized') AS genre,
    COALESCE(play_count, 0) AS plays
FROM tracks;

-- Cascading fallbacks:
SELECT
    title,
    COALESCE(album, artist || ' - Singles', 'Unknown Album') AS album_name
FROM tracks;

-- Safe arithmetic:
SELECT
    title,
    COALESCE(play_count, 0) * COALESCE(royalty_rate, 0.001) AS earnings
FROM tracks;
```

### Strategy 3: Explicit NULL Handling
```sql
-- Find incomplete records:
SELECT * FROM tracks WHERE album IS NULL;

-- Exclude incomplete records:
SELECT * FROM tracks WHERE album IS NOT NULL;

-- Include NULLs in NOT conditions:
SELECT * FROM tracks
WHERE genre IS NULL OR genre != 'Pop';
```

---

## Modifying Tables After Creation

### Problem: "We need to add a genre column to our existing tracks table with millions of rows"

You have a production table with data. You need to add columns, modify constraints, or change data types. How do you evolve your schema safely?

### Solution: ALTER TABLE

```sql
-- Basic syntax for adding a column:
ALTER TABLE table_name
ADD COLUMN column_name data_type constraints;

-- Add genre to existing tracks table:
ALTER TABLE tracks
ADD COLUMN genre TEXT;

-- Add with constraints and default:
ALTER TABLE tracks
ADD COLUMN is_instrumental BOOLEAN NOT NULL DEFAULT false;
```

### The Process

When you ADD COLUMN with a DEFAULT to a table with existing rows, PostgreSQL:
1. Adds the column to the table structure
2. Sets the default value for all existing rows
3. Applies any constraints

If you ADD COLUMN with NOT NULL but no DEFAULT, the operation fails if the table has data (you can't have NOT NULL with no value!).

---

## Safe Schema Changes with IF EXISTS

### Problem: "Our migration scripts fail when run twice"

Your deployment script tries to add a column that already exists, and the entire migration fails. You need operations that are safe to run multiple times (idempotent).

### Solution: IF EXISTS / IF NOT EXISTS

```sql
-- Safe column addition:
ALTER TABLE tracks
ADD COLUMN IF NOT EXISTS genre TEXT;

-- Safe column removal:
ALTER TABLE tracks
DROP COLUMN IF EXISTS temporary_field;

-- Safe constraint addition:
ALTER TABLE tracks
DROP CONSTRAINT IF EXISTS check_positive_duration;

ALTER TABLE tracks
ADD CONSTRAINT check_positive_duration
CHECK (duration_seconds > 0);

-- Safe table creation:
CREATE TABLE IF NOT EXISTS tracks (
    track_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL
);

-- Safe index creation:
CREATE INDEX IF NOT EXISTS idx_tracks_artist
ON tracks(artist);
```

### Why IF EXISTS Matters

In production, you often run migrations multiple times:
- Development, staging, production environments
- Failed deployments that need re-running
- Multiple developers running same migrations

IF EXISTS makes operations idempotent - safe to run multiple times with the same result. This prevents errors and makes deployments more robust.

---

## Changing Columns in Production

### Problem: "We need to make the genre column required for all tracks"

You have a table with NULL genres. You want to make genre NOT NULL. How do you handle existing NULL values?

### Step-by-Step Migration

```sql
-- Step 1: Update existing NULLs
UPDATE tracks
SET genre = 'Unknown'
WHERE genre IS NULL;

-- Step 2: Add the NOT NULL constraint
ALTER TABLE tracks
ALTER COLUMN genre SET NOT NULL;

-- Or combine with a DEFAULT:
ALTER TABLE tracks
ALTER COLUMN genre SET DEFAULT 'Unknown';

ALTER TABLE tracks
ALTER COLUMN genre SET NOT NULL;
```

### Removing Constraints

```sql
-- Remove NOT NULL:
ALTER TABLE tracks
ALTER COLUMN genre DROP NOT NULL;

-- Remove DEFAULT:
ALTER TABLE tracks
ALTER COLUMN play_count DROP DEFAULT;
```

---

## Complete Example: Building a Production-Ready Tracks Table

### Problem: "Design a bulletproof tracks table for Spotify's scale"

```sql
-- Start with the complete structure:
CREATE TABLE IF NOT EXISTS tracks (
    -- Identity
    track_id SERIAL PRIMARY KEY,

    -- Core fields that must exist
    title TEXT NOT NULL,
    artist TEXT NOT NULL,

    -- Duration must be positive
    duration_seconds INTEGER NOT NULL CHECK (duration_seconds > 0),

    -- Optional but constrained fields
    album TEXT,
    genre TEXT DEFAULT 'Unknown',

    -- Flags with sensible defaults
    explicit_content BOOLEAN NOT NULL DEFAULT false,
    is_instrumental BOOLEAN NOT NULL DEFAULT false,

    -- Metrics with bounds
    popularity INTEGER DEFAULT 50
        CHECK (popularity BETWEEN 0 AND 100),

    -- Temporal data with validation
    release_date DATE CHECK (release_date <= CURRENT_DATE),

    -- Analytics with defaults
    play_count BIGINT NOT NULL DEFAULT 0
        CHECK (play_count >= 0),

    -- Automatic timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Unique external identifier
    isrc VARCHAR(12) UNIQUE
);

-- Add an index for common queries (we'll cover this in detail later):
CREATE INDEX IF NOT EXISTS idx_tracks_artist ON tracks(artist);
CREATE INDEX IF NOT EXISTS idx_tracks_genre ON tracks(genre);
```

---

## Summary: Your Data Integrity Toolkit

### Constraints Are Your Safety Net

1. **PRIMARY KEY** - Every table needs identity
2. **NOT NULL** - Require essential data
3. **UNIQUE** - Prevent duplicates
4. **CHECK** - Enforce business rules
5. **DEFAULT** - Provide sensible fallbacks

### Remember

- **Constraints are cheap** - Let the database enforce rules
- **NULLs are dangerous** - Minimize them with NOT NULL and DEFAULT
- **Types matter** - INTEGER for numbers, TEXT for strings, no compromises
- **Gaps are normal** - Non-consecutive IDs are a feature
- **IF EXISTS is your friend** - Make migrations idempotent

### The Golden Rule

It's easier to relax a constraint later than to add one to dirty data. Start strict, loosen carefully.

---

## Practice Exercises

1. Create a tracks table that prevents duplicate songs (same title + artist)
2. Add a constraint ensuring tempo is between 40 and 200 BPM
3. Write a query that safely handles NULL play_counts in calculations
4. Create a migration script that adds a 'energy_level' column with constraints

## Next Module: Multi-Table Operations

Now that you can build robust single tables, we'll learn how to connect them with foreign keys and JOINs.

## Resources

- [PostgreSQL Constraints Documentation](https://www.postgresql.org/docs/current/ddl-constraints.html)
- [PostgreSQL Data Types](https://www.postgresql.org/docs/current/datatype.html)
- [ALTER TABLE Reference](https://www.postgresql.org/docs/current/sql-altertable.html)