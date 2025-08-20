# SQL
## Structured Query Language
### The Universal Language of Data

---

# What is SQL?

**SQL** = Structured Query Language

- Born in 1974 at IBM (50 years old and still essential!)
- The **universal language** for talking to databases
- English-like syntax (SELECT, FROM, WHERE)
- Every tech company uses it: Google, Meta, Spotify, Netflix

*If databases are restaurants, SQL is how you order*

---

# Why SQL Survived 50 Years

```python
# Python changes every few years
print "Hello"     # Python 2 (dead)
print("Hello")    # Python 3

# JavaScript changes constantly
var x = 5;        // Old way
let x = 5;        // New way
const x = 5;      // Newer way
```

```sql
-- SQL from 1990s still works today!
SELECT * FROM users WHERE age > 18;
```

**SQL is the COBOL that actually stayed relevant**

---

# SQL is Everywhere

**Your Phone:**
- WhatsApp messages: SQLite
- Instagram cache: SQLite
- iPhone photos metadata: SQLite

**Your Favorite Services:**
- Netflix recommendations: PostgreSQL
- Spotify playlists: PostgreSQL
- Reddit comments: PostgreSQL
- Uber rides: MySQL

*You've probably triggered millions of SQL queries today*

---

# SQL vs Programming Languages

**Imperative** (Python/Java/C++): "HOW to do it"
```python
results = []
for user in users:
    if user.age > 21 and user.country == 'France':
        results.append(user.name)
return sorted(results)
```

**Declarative** (SQL): "WHAT you want"
```sql
SELECT name FROM users
WHERE age > 21 AND country = 'France'
ORDER BY name;
```

*You describe the result, the database figures out HOW*

---

# The SQL Family Tree

```
SQL
├── DDL (Data Definition Language)
│   └── CREATE, ALTER, DROP
├── DML (Data Manipulation Language)
│   └── SELECT, INSERT, UPDATE, DELETE
├── DCL (Data Control Language)
│   └── GRANT, REVOKE
└── TCL (Transaction Control Language)
    └── COMMIT, ROLLBACK, BEGIN
```

**You'll use DML 90% of the time**

---

# DDL: Building the House
## Data Definition Language

```sql
-- Create the structure
CREATE TABLE songs (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    artist TEXT NOT NULL,
    duration_seconds INTEGER,
    release_date DATE
);

-- Modify the structure
ALTER TABLE songs ADD COLUMN genre TEXT;

-- Destroy the structure
DROP TABLE songs;  -- ⚠️ Everything gone!
```

*Think of it as: Architect's blueprints*

---

# DML: Living in the House
## Data Manipulation Language

```sql
-- Create: Add new data
INSERT INTO songs (title, artist, duration_seconds)
VALUES ('Flowers', 'Miley Cyrus', 200);

-- Read: Query data
SELECT title, artist FROM songs WHERE duration_seconds < 180;

-- Update: Modify existing data
UPDATE songs SET genre = 'Pop' WHERE artist = 'Taylor Swift';

-- Delete: Remove data
DELETE FROM songs WHERE release_date < '2000-01-01';
```

*The everyday SQL you'll write*

---

# The SELECT Statement
## Your Swiss Army Knife

```sql
SELECT     -- What columns?
FROM       -- What table?
WHERE      -- What rows?
GROUP BY   -- How to group?
HAVING     -- Filter groups?
ORDER BY   -- What order?
LIMIT      -- How many?
```

**This pattern solves 80% of your data questions**

---

# SQL Reads Like English

```sql
-- Almost natural language
SELECT name, age
FROM students
WHERE grade > 15
ORDER BY age DESC
LIMIT 10;
```

**Translates to:**
"Show me the names and ages of students with grades above 15, sorted by age (oldest first), but only the top 10"

*This is why SQL survived: humans can read it*

---

# The Power of JOINs
## SQL's Superpower

Without JOIN (multiple queries):
```python
# Get user
user = db.query("SELECT * FROM users WHERE id = 42")
# Get their orders
orders = db.query(f"SELECT * FROM orders WHERE user_id = {user.id}")
# Get order details
for order in orders:
    items = db.query(f"SELECT * FROM items WHERE order_id = {order.id}")
```

With JOIN (one query):
```sql
SELECT u.name, o.date, i.product
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN items i ON o.id = i.order_id
WHERE u.id = 42;
```

---

# SQL is Set-Based
## Think in Groups, Not Loops

❌ **Procedural thinking:**
"For each user, check their age, if > 18, add to results..."

✅ **Set thinking:**
"Give me all users over 18"

```sql
-- SQL operates on entire sets at once
UPDATE products SET price = price * 1.1;  -- All products, one statement!

-- Not row by row like:
for product in products:
    product.price = product.price * 1.1
```

---

# SQL Dialects
## Same Language, Different Accents

| Standard SQL | PostgreSQL | MySQL | SQL Server |
|-------------|------------|-------|------------|
| `SUBSTRING()` | `SUBSTRING()` | `SUBSTRING()` | `SUBSTRING()` |
| ❌ | `LIMIT 10` | `LIMIT 10` | `TOP 10` |
| ❌ | `STRING_AGG()` | `GROUP_CONCAT()` | `STRING_AGG()` |
| ❌ | `::TEXT` | ❌ | `CAST AS VARCHAR` |

**Core SQL (90%) is identical everywhere**
*Fancy features (10%) vary*

---

# NoSQL Tried to Kill SQL

**2010s: "SQL is dead! NoSQL is the future!"**

MongoDB, Cassandra, Redis promised:
- No schemas!
- Web scale!
- Modern!

**2020s Reality:**
- MongoDB added... SQL support
- Cassandra added... CQL (basically SQL)
- Everyone realized: SQL is actually good

---

# SQL's Modern Renaissance

**Old SQL** (2000s):
```sql
SELECT * FROM users WHERE age > 21;
```

**Modern SQL** (2020s):
```sql
WITH user_metrics AS (
  SELECT user_id,
         COUNT(*) OVER (PARTITION BY country) as country_users,
         RANK() OVER (ORDER BY created_at) as user_rank
  FROM users
)
SELECT * FROM user_metrics
WHERE country_users > 1000;
```

**SQL keeps evolving: Window functions, CTEs, JSON support, Arrays**

---

# SQL + Modern Tools

SQL isn't just for database admins anymore:

- **Data Scientists**: SQL + Python/R
- **Analysts**: SQL + Tableau/PowerBI
- **Engineers**: SQL + ORMs
- **Product Managers**: SQL + Metabase
- **Machine Learning**: SQL + Feature stores

```python
# Modern data stack
df = pd.read_sql("SELECT * FROM events WHERE date > '2024-01-01'", conn)
model.train(df)
```

---

# Common SQL Mistakes

```sql
-- 🐛 Forgetting WHERE in UPDATE
UPDATE users SET status = 'deleted';  -- Deletes EVERYONE!

-- 🐛 NULL comparisons
SELECT * FROM users WHERE age = NULL;  -- Wrong!
SELECT * FROM users WHERE age IS NULL;  -- Correct!

-- 🐛 JOIN explosion
SELECT * FROM orders o, products p;  -- Cartesian product disaster!

-- 🐛 GROUP BY confusion
SELECT name, MAX(salary) FROM employees;  -- Which name?!
```

---

# SQL Performance Matters

**Bad query (10 seconds):**
```sql
SELECT * FROM orders
WHERE YEAR(order_date) = 2024;  -- Function on column = no index
```

**Good query (10 milliseconds):**
```sql
SELECT * FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01';  -- Index-friendly
```

**1000x difference with one small change!**

---

# SQL Security: Bobby Tables

![xkcd SQL injection](https://imgs.xkcd.com/comics/exploits_of_a_mom.png)

```sql
-- NEVER do this
query = f"SELECT * FROM users WHERE name = '{user_input}'"

-- User enters: '; DROP TABLE users; --
-- Becomes: SELECT * FROM users WHERE name = ''; DROP TABLE users; --'
```

**Always use parameterized queries!**

---

# Why Learn SQL in 2025?

1. **Universal**: Every database speaks SQL
2. **Stable**: Skills last your entire career
3. **Powerful**: Complex operations in few lines
4. **Required**: Every tech job posting mentions it
5. **Gateway**: Opens doors to data science, analytics, engineering

*GPT-4 can write Python for you. But YOU need to know if the SQL is correct.*

---

# SQL Career Paths

**Data Analyst**: 90% SQL
- Business intelligence
- Report generation
- KPI tracking

**Data Engineer**: 70% SQL
- ETL pipelines
- Data warehousing
- Performance optimization

**Backend Developer**: 40% SQL
- Application databases
- API development
- Query optimization

**Data Scientist**: 50% SQL
- Feature engineering
- Data exploration
- Training set creation

---

# The SQL Mindset

Stop thinking in loops ➰
Start thinking in sets 📊

**Question**: "Find duplicate emails"

❌ **Loop mindset**:
```
for each email:
    count = 0
    for each other email:
        if same: count++
    if count > 1: it's duplicate
```

✅ **Set mindset**:
```sql
SELECT email, COUNT(*)
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
```

---

# Quick Quiz

**What type of SQL statement?**

1. `CREATE INDEX idx_email ON users(email);` → **?**
2. `GRANT SELECT ON orders TO analyst_role;` → **?**
3. `ROLLBACK;` → **?**
4. `SELECT COUNT(*) FROM products;` → **?**
5. `ALTER TABLE songs ADD COLUMN plays INTEGER;` → **?**

---

# Quiz Answers

1. `CREATE INDEX` → **DDL** (Data Definition)
2. `GRANT SELECT` → **DCL** (Data Control)
3. `ROLLBACK` → **TCL** (Transaction Control)
4. `SELECT COUNT(*)` → **DML** (Data Manipulation)
5. `ALTER TABLE` → **DDL** (Data Definition)

---

# Remember

- SQL is **50 years old** and getting stronger
- It's **declarative**: say what you want, not how
- **Every database** speaks SQL (with slight accents)
- Think in **sets**, not loops
- It's a **career skill**, not just academic

*Master SQL, and you'll never lack job opportunities*