# Titanic Dataset: SELECT Query Exercises

## The Story

It's April 15, 1912. The RMS Titanic has just sunk in the North Atlantic Ocean. As a data analyst for the White Star Line shipping company, you've been tasked with analyzing passenger data to understand survival patterns. Your findings will influence future safety regulations and procedures.

The dataset contains information about 891 passengers, including whether they survived, their class, age, fare paid, and family relationships aboard the ship.

---

## Setup: Loading the Data

### Download the Dataset
```
https://raw.githubusercontent.com/datasciencedojo/datasets/master/titanic.csv
```

### Create the Table
Run the SQL script provided: `titanic_table.sql`

### Load Data - Option A: psql
```sql
\COPY titanic FROM 'titanic.csv' WITH CSV HEADER;
```

### Load Data - Option B: pgAdmin
1. Right-click `titanic` table → Import/Export Data
2. Select your CSV file
3. Format: CSV, Header: ON
4. Click OK

---

## Part 1: Basic Filtering
*Understanding who was on board*

**Exercise 1.1** - Show all passengers (just to see the data structure)
- Limit to 5 rows

**Exercise 1.2** - Find all survivors
- Filter where survived = 1

**Exercise 1.3** - Find all male passengers

**Exercise 1.4** - Find all first-class passengers

**Exercise 1.5** - Find children under 10 years old

**Exercise 1.6** - Find passengers who embarked at Southampton (S)

---

## Part 2: Combined Filters
*Narrowing down the search*

**Exercise 2.1** - Find all women who survived

**Exercise 2.2** - Find all first-class male passengers

**Exercise 2.3** - Find children under 18 who did NOT survive

**Exercise 2.4** - Find passengers who paid more than 50 for their fare

**Exercise 2.5** - Find third-class passengers between ages 20 and 40

**Exercise 2.6** - Find passengers with no cabin information (cabin IS NULL)

---

## Part 3: Ordering and Limiting
*Finding the extremes*

**Exercise 3.1** - Show the 10 oldest passengers

**Exercise 3.2** - Show the 5 most expensive tickets

**Exercise 3.3** - List all children (age < 18) from youngest to oldest

**Exercise 3.4** - Show the 10 cheapest first-class tickets

**Exercise 3.5** - Find the 20 youngest survivors

---

## Part 4: Projection
*Selecting specific information*

**Exercise 4.1** - Show only names and ages of all passengers

**Exercise 4.2** - Show passenger names with their survival status and class

**Exercise 4.3** - For women only, show name, age, and fare paid

**Exercise 4.4** - Create a passenger list showing: name, sex, age for all children

**Exercise 4.5** - Show name and embarkation port for first-class passengers

---

## Part 5: Using Column Aliases
*Making output readable*

**Exercise 5.1** - Show passenger names as "Passenger" and age as "Years"

**Exercise 5.2** - Show survival status as "Rescued" (1) or not (0)

**Exercise 5.3** - Display class as "Ticket_Class" and fare as "Price_Paid"

---

## Part 6: String Operations (CONCAT)
*Combining information*

**Exercise 6.1** - Create a full description: name followed by their sex in parentheses
- Example: "Braund, Mr. Owen Harris (male)"

**Exercise 6.2** - Combine age and sex into one column
- Example: "22 year old male"

**Exercise 6.3** - Create a passenger summary: "Name - Class X"
- Example: "Allen, Mr. William - Class 3"

**Exercise 6.4** - Show port names with text: "Embarked from: X"

---

## Part 7: Handling NULL Values (COALESCE)
*Dealing with missing data*

**Exercise 7.1** - Show all ages, replacing NULL with 0

**Exercise 7.2** - Show cabin numbers, replacing NULL with 'No Cabin'

**Exercise 7.3** - Display age, but show 'Unknown' for missing ages

**Exercise 7.4** - Create a report showing fare, but display 0.00 for NULL fares

---

## Part 8: Type Casting (CAST)
*Converting data types*

**Exercise 8.1** - Convert survived (integer) to text for concatenation

**Exercise 8.2** - Round ages to nearest integer and cast as INTEGER

**Exercise 8.3** - Convert fare to text and add '$' prefix

**Exercise 8.4** - Cast passenger_id to text for string operations

---

## Part 9: Complex Queries
*Putting it all together*

**Exercise 9.1** - Create a survivor report showing:
- Full description: "Name (Age years old)"
- Replace NULL ages with "Unknown age"
- Only show survivors
- Order by age (youngest first)

**Exercise 9.2** - Create a first-class passenger manifest:
- Format: "Mr/Mrs. Name - Cabin X"
- Replace NULL cabin with "No cabin assigned"
- Order alphabetically by name

**Exercise 9.3** - Find families (passengers with same last name):
- Hint: Use SPLIT_PART(name, ',', 1) to extract last name
- Show passengers who share surnames with others

**Exercise 9.4** - Create a children's safety report:
- Show: "Child: [name], Age: [age], Survived: Yes/No"
- Only passengers under 16
- Order by survival status, then age

**Exercise 9.5** - Expensive tickets analysis:
- Show top 20 most expensive tickets
- Format: "[Name] paid $[fare] for [class] class"
- Include embarkation port

---

## Part 10: Investigation Queries
*Answer these questions about the tragedy*

**Exercise 10.1** - Which passenger paid the highest fare?

**Exercise 10.2** - How many children under 10 were in third class?

**Exercise 10.3** - List all passengers with the title "Master" (young boys)
- Hint: name LIKE '%Master%'

**Exercise 10.4** - Find all passengers traveling alone (sibsp = 0 AND parch = 0)

**Exercise 10.5** - Who were the youngest and oldest survivors?

---

## Bonus Challenges

**Challenge 1** - Create a formatted passenger card:
```
"PASSENGER CARD
Name: [name]
Class: [class] | Sex: [sex] | Age: [age or 'Unknown']
Fare: $[fare] | Cabin: [cabin or 'Not assigned']
Status: [SURVIVED or PERISHED]"
```

**Challenge 2** - Find potential families by identifying:
- Passengers with same ticket number
- Order by ticket number, then by age

**Challenge 3** - Create age groups and analyze:
- Infant (0-2), Child (3-12), Teen (13-17), Adult (18-59), Senior (60+)
- Use CASE WHEN statements

---

## Answer Verification

To check your query results:
- Exercise 1.2 should return 342 rows (survivors)
- Exercise 1.3 should return 577 rows (male passengers)
- Exercise 3.2 highest fare should be 512.3292
- The oldest passenger was 80 years old
- The youngest passenger was 0.42 years old (5 months)

---

## Tips
- Remember: survived (0 = No, 1 = Yes)
- Remember: pclass (1 = First, 2 = Second, 3 = Third)
- Remember: embarked (C = Cherbourg, Q = Queenstown, S = Southampton)
- Use `\d titanic` in psql to see column types
- Start simple, then add complexity
- Test with LIMIT 10 first to verify your logic