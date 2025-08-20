---

# Common Table Expressions

---

# More complex queries with CTEs

define temporary result sets that can be referenced within another SQL statement

```sql
WITH cte_name (column_list) AS (
  CTE_query_definition
)
statement;
```

https://www.geeksforgeeks.org/postgresql-cte/

---

# More complex queries with CTEs

find the average circumference and height of trees in each arrondissement and then filter for arrondissements where the average circumference is greater than 100.

find the most common tree species in each arrondissement and then filter to only show arrondissements where the most common species accounts for more than 30% of the total trees.

identifying the top 5 tallest trees in each arrondissement. We'll use a CTE to first rank the trees by height within each arrondissement and then filter to get only the top 5 tallest trees per arrondissement.

---

# More complex queries with CTEs

**find the average circumference and height of trees in each arrondissement**
**then filter for arrondissements where the average circumference is greater than 100.**

```sql
WITH arrondissement_stats AS (
  SELECT
    arrondissement,
    AVG(circumference) AS avg_circumference,
    AVG(height) AS avg_height,
    COUNT(*) AS tree_count
  FROM
    trees
  GROUP BY
    arrondissement
)
SELECT
  arrondissement,
  avg_circumference,
  avg_height,
  tree_count
FROM
  arrondissement_stats
WHERE
  avg_circumference > 100
ORDER BY
  avg_circumference DESC;
```

**CTE Definition (arrondissement_stats):**
- This CTE calculates the average circumference (avg_circumference) and average height (avg_height) of trees for each arrondissement.
- It also counts the number of trees in each arrondissement (tree_count).
- The results are grouped by the arrondissement.

**Main Query:**
- The main query selects data from the CTE arrondissement_stats.
- It filters arrondissements where the average circumference is greater than 100.
- Finally, it orders the results by avg_circumference in descending order.

---

# More complex queries with CTEs

find the most common tree species in each arrondissement and then filter to only show arrondissements where the most common species accounts for more than 30% of the total trees.

use the following window function:
```sql
COUNT(*)::decimal / SUM(COUNT(*)) OVER (PARTITION BY arrondissement) AS species_percentage
```

---

# More complex queries with CTEs

```sql
WITH species_count AS (
  SELECT
    arrondissement,
    species,
    COUNT(*) AS species_count,
    COUNT(*)::decimal / SUM(COUNT(*)) OVER (PARTITION BY arrondissement) AS species_percentage
  FROM
    trees
  GROUP BY
    arrondissement, species
),
most_common_species AS (
  SELECT
    arrondissement,
    species,
    species_count,
    species_percentage
  FROM
    species_count
  WHERE
    species_percentage > 0.30
)
SELECT
  arrondissement,
  species,
  species_count,
  species_percentage
FROM
  most_common_species
ORDER BY
  arrondissement, species_percentage DESC;
```

**CTE Definition (species_count):**
- This CTE calculates the number of trees of each species within each arrondissement (species_count).
- It also calculates the percentage of trees of that species relative to the total number of trees in that arrondissement (species_percentage).
- The percentage is calculated using a COUNT(*)::decimal divided by the sum of COUNT(*) over the partitioned rows for each arrondissement.

**CTE Definition (most_common_species):**
- This CTE filters the results from species_count to only include species that account for more than 30% of the total trees in an arrondissement.

**Main Query:**
- The main query selects the filtered data from most_common_species.
- It orders the results by arrondissement and then by species_percentage in descending order.

---

# More complex queries with CTEs

**identify the top 5 tallest trees in each arrondissement. We'll use a CTE to first rank the trees by height within each arrondissement and then filter to get only the top 5 tallest trees per arrondissement.**

```sql
WITH tree_ranks AS (
  SELECT
    idbase,
    arrondissement,
    name,
    genre,
    species,
    height,
    ROW_NUMBER() OVER (PARTITION BY arrondissement ORDER BY height DESC) AS rank
  FROM
    trees
  WHERE
    height > 0
)
SELECT
  idbase,
  arrondissement,
  name,
  genre,
  species,
  height,
  rank
FROM
  tree_ranks
WHERE
  rank <= 5
ORDER BY
  arrondissement,
  rank;
```

**CTE Definition (tree_ranks):**
- The CTE calculates the rank of each tree within its arrondissement based on its height.
- **ROW_NUMBER() OVER (PARTITION BY arrondissement ORDER BY height DESC)**:
  - **PARTITION BY arrondissement**: Divides the data into partitions by arrondissement.
  - **ORDER BY height DESC**: Orders the trees in each arrondissement by their height in descending order.
  - **ROW_NUMBER()**: Assigns a unique sequential integer to rows within each partition (arrondissement) based on the order specified.
- This CTE only includes trees with a positive height (WHERE height > 0).

**Main Query:**
- The main query selects all columns from the tree_ranks CTE.
- It filters to include only the top 5 tallest trees in each arrondissement (WHERE rank <= 5).
- The results are ordered by arrondissement and then by rank within each arrondissement.
