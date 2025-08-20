---

# How the guardian moved from MongoDB to postgres

**Why and how did the Guardian move from MongoDB to Postgres**

1. Take a few minutes to read the article

https://www.theguardian.com/info/2018/nov/30/bye-bye-mongo-hello-postgres

2. if you have any, write down your questions

---

# How the guardian moved from MongoDB to postgres

**Reasons for Moving from MongoDB to PostgreSQL:**
1. **Operational Challenges**: The Guardian faced significant issues with MongoDB's OpsManager, including time-consuming upgrades, lack of effective support during outages, and the need for extensive custom scripting and management.
2. **Cost and Efficiency**: The high cost of MongoDB's support contract combined with the ongoing operational burden led them to seek a more manageable and cost-effective solution.
3. **Feature Limitations**: Alternatives like DynamoDB were considered but lacked essential features like encryption at rest, which Postgres on AWS RDS provided.

**Migration Process:**
1. **Parallel APIs**: They created a new API using PostgreSQL and ran it in parallel with the old MongoDB API to ensure a smooth transition.
2. **Data Migration**: Content was migrated using a script that compared and validated data between the two databases.
3. **Proxy Usage**: A proxy was employed to replicate traffic to both databases, ensuring consistency and allowing for real-time testing.
4. **Gradual Switchover**: The team gradually shifted traffic to the new Postgres API, eventually decommissioning MongoDB without causing downtime.

