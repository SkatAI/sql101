---
# Terminology


In a document-type NoSQL database like MongoDB

- A **collection** is a set of **documents**.
- A document is a combination of keys: values.
- Each collection has a unique key (the _id field)
- In a document, you can have nested sub-documents. For example: A person can have multiple phones, email addresses, jobs, ...

All documents in a collection are **similar in structure** but don't need to be exactly identical.

There is no concept of normalization.

---

# MongoDB Hierarchy - NoSQL Database - MongoDB

- A **database** contains **collections**
- A **collection** contains all **documents** ~~~ table
- A **document** is the entity that contains the data ~~~ record
- A sub-document (nested) is a document **inside** a parent document
- A **field** is an attribute or property of the document -> column

---

# MongoDB - SQL:

- A `document` is a record
- A `Collection` is a table
- A `Field` is a column

| MongoDB           | SQL Database |
| ----------------- | ------------ |
| database          | database     |
| Collection        | Table        |
| Document          | Record/Row   |
| Field             | Column       |
| Embedded Document | Foreign Key  |
| `_id`             | Primary Key  |
| `$lookup`         | JOIN         |

An `index` remains an `index`

## Schema-less - dynamic schema

In what situations do data change so often that we would need a special type of database?

The most common example of a NoSQL application is a social network.

- user profiles
- posts contain all sorts of content
- timeline, followers, etc.


### Nested Data

- To be efficient, an SQL database must be normalized. For complex data, we risk ending up with many tables.
- MongoDB allows **nesting** data naturally

A good example is a person's address

In the same database, we can have people who have no address, one address, or several. And these multiple addresses have different roles: primary residence, secondary, etc....

If we use a JSON format to represent these 3 cases, we naturally have

```json
// A person with no registered address
{
    "_id": "1",
    "name": "Anita Sharma",
    "age": 29,
    "email": "anita.sharma@example.com"
}

// A person with a single address as a simple dictionary
{
    "_id": "2",
    "name": "Rahul Verma",
    "age": 42,
    "email": "rahul.verma@example.com",
    "address": {
        "type": "home",
        "street": "12 MG Road",
        "locality": "Indiranagar",
        "city": "Bengaluru",
        "state": "Karnataka",
        "pincode": "560038",
        "country": "India"
    }
}

// A person with multiple addresses as a list of dictionaries
{
    "_id": "3",
    "name": "Priya Singh",
    "age": 35,
    "email": "priya.singh@example.com",
    "addresses": [
        {
            "type": "home",
            "street": "45/2 Lajpat Nagar",
            "locality": "Central Market",
            "city": "New Delhi",
            "state": "Delhi",
            "pincode": "110024",
            "country": "India"
        },
        {
            "type": "work",
            "street": "4th Floor, Tower B",
            "locality": "DLF Cyber City",
            "city": "Gurugram",
            "state": "Haryana",
            "pincode": "122002",
            "country": "India"
        }
    ]
}
```


In SQL, you would need to have an address table and a many-to-many relationship between the person table and the person table, so an intermediate table for the join.

### Consequences of Schema Flexibility

Schema flexibility impacts every stage of a database's lifecycle

- **Design**: without rules, everything becomes possible. Design choices are dictated by the application. The way data is _consumed_ dictates the structure of data in the database.
- **Development**: with a flexible schema, changes can be implemented more quickly.
- **Maintenance**: the downside is the need to manage historical data organization and types

Extra caution is necessary to avoid chaos and **data inconsistencies**. Query performance can be affected if changes in data structure lead to inefficient or inconsistent indexing.

With NoSQL databases, the cost of implementing changes in the nature of data is shifted from the database to the application level.

However, inconsistencies in the database can still occur if multiple applications interact differently with the same database.

> In short, schema flexibility should be used with caution and only when useful and justified.

## When to Choose NoSQL (Document Database) Rather Than SQL?

So when is a NoSQL document database a better choice than SQL?

- Your data naturally corresponds to a **document** structure rather than strict tables
  - You want to store related data together rather than spreading it across tables to speed up information retrieval: queries are simpler, there are fewer joins, and code simplicity.

- Rapid Iteration: Your schema needs to evolve quickly, and you prioritize development speed over strict data consistency
  - Rapidly changing applications and data requirements
  - Early-stage startups where the data model is not yet fully understood

- also: A/B testing of different features that may require different data structures

- Scalability and Performance
  - Designed for **horizontal scaling** with built-in support for **sharding** (distributing data across multiple servers).
  - Suitable for managing large-scale, high-throughput, and geographically distributed applications.

MongoDB scales out, while PostgreSQL scales up.

- Uses a flexible JSON-like document model (BSON), making it ideal for hierarchical or semi-structured data.
  - Reduces the need for complex joins, as related data can be embedded in a single document.

MongoDB excels in:

- Applications with unstructured or semi-structured data.
- High-velocity workloads requiring rapid schema changes.
- Use cases requiring horizontal scaling in distributed environments.

### Performance

In terms of performance, the comparison most often favors PostgreSQL over MongoDB.
see [MongoDB Vs PostgreSQL: A comparative study on performance aspects](https://link.springer.com/article/10.1007/s10707-020-00407-w)

And this other article, [MongoDB vs PostgreSQL: Choosing the Best Database for Your Needs](https://www.halfnine.com/blog/post/mongodb-vs-postgresql), summarizes it well:

> _MongoDB shines in scenarios requiring the development of software applications that process various types of data in a scalable manner. It is particularly suitable for projects that need to support rapid iterative development and facilitate the collaboration of many teams.

In [Postgres vs. MongoDB: a Complete Comparison in 2024](https://www.bytebase.com/blog/postgres-vs-mongodb/)

### In Brief

- Choose MongoDB if your application has a simple data model and handles a very large volume of data
- Choose PostgreSQL if your application has complex business logic that relies on transactions.
