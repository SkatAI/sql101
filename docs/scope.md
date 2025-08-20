# Scope for IPSA Fall 2025 SQL101

##  Module 1: Why Databases Matter

- Welcome slides

Overview of databases
- what is a database
- why do we need databases
- history
- ecosystem
- actors

- From Spreadsheets to Databases: When Excel Isn't Enough
- Real-world Database Applications (Spotify, Netflix, Climate Monitoring)
- Database vs File Storage: Performance, Consistency, Concurrency
- you will use a database not directly but with a wrapper depending on the language you use.

Why use postgres ?

practice: small quizz, not graded, fun


## Module 2: Tables and Basic Queries

minimal properties of a  database.

- atomicity, consistency, isolation, durability (ACID)

SQL language


getting data out of the database

- Intro on set theory, algebra, with filtering and projections

- Creating Your First Table: Music Track Database
- SELECT Fundamentals: Retrieving Data
- WHERE Clauses: Filtering Results
- ORDER BY and LIMIT: Controlling Output
- projections and operators on projections (concat, coalesce)

## Module 3: Data Manipulation

- INSERT: Adding New Records
- UPDATE: Modifying Existing Data
- DELETE: Removing Records Safely
- Transactions: All or Nothing Operations

- inserting from a csv file with psql




## Module 4: Data Types and Constraints

what is data, what is dirty data

- Understanding Data Types (TEXT, INTEGER, REAL, BLOB)
- Primary Keys: Why Every Row Needs an Identity
- NOT NULL, UNIQUE, CHECK Constraints
- nightmare of NULL values
- DEFAULT Values and Auto-increment



## Module 5: Multi-Table Operations

Moving on to multi tables

- foreign keys

- JOIN Basics: Connecting Related Data
- INNER JOIN: Finding Matches
- LEFT/RIGHT JOIN: Handling Missing Data
- Self-Joins: When a Table References Itself

### Module 6: Aggregation and Grouping (2h)
- COUNT, SUM, AVG, MIN, MAX Functions
- GROUP BY: Summarizing Data Categories
- HAVING: Filtering Grouped Results
- Combining Aggregates with JOINs

### Module 7: Database Design and Normalization (3h)
- First Normal Form: Eliminating Repeating Groups
- Second Normal Form: Removing Partial Dependencies
- Third Normal Form: Eliminating Transitive Dependencies
- Denormalization: When and Why to Break Rules

case: yuka and nutriscore.

### Module 8: Data Modeling
- Entity-Relationship Diagrams
- One-to-One, One-to-Many, Many-to-Many Relationships
- Foreign Keys and Referential Integrity
- Designing Efficient Schema

### Module 9: Performance and Real-World Applications (1h)
- Indexes: Making Queries Faster
- Query Optimization Basics
- When to Use SQL vs NoSQL
- Migration to PostgreSQL: Next Steps

- execution plan analysis: EXPLAIN, EXPLAIN ANALYZE