### Yuka and Food Products

Let's take the example of a startup like [Yuka](https://yuka.io/en/)

![Yuka](./img/yuka-screenshot.png)

In their own words: _Yuka deciphers product labels and analyzes the health impact of food and cosmetic products._

Its underlying database is the [open food facts database](https://world.openfoodfacts.org/), a food product database made by everyone, for everyone, with more than 3.5 million food products.

Look, for example, at the information for [Nutella](https://uk.openfoodfacts.org/product/3017620422003/nutella) and that for... [Baguette](https://world.openfoodfacts.org/product/3250393046940/baguette-constance-cereales-250g-la-campaniere)

Also see this article exploring the dataset with python pandas: <https://medium.com/@achrafelkhanjari99/a-deep-dive-into-the-open-food-facts-dataset-56259b162ac5> (available as pdf in the Github repo)

With so many products, the available information and associated information (Packaging, Carbon Impact) as well as the diversity of regulations (EU, US, UK, ... etc.) constantly vary.

The data is constantly updated while the history of changes and new additions must be preserved.

- new data becomes available as actors set up data collection. Think traceability, security, etc.
- new regulations require more data
- current events, social trends, and interests change rapidly (gluten-free, tuna and mercury, pesticides, ...)

So you start your database with a simple schema that includes:

- name, definition, image, description
- nutritional values
- ingredients

But the schema becomes increasingly complex as the data, products, and company services evolve.

#### Nutriscore

Take for example, the Nutriscore label:

<img src="../img/nutri-score-f_1200x800.jpg" width='50%' style='display: block; margin: auto; padding-bottom: 30px;' alt= "Nutriscore">

The [Nutriscore](https://nutriscore.blog/2022/08/04/report-of-the-european-scientific-committee-in-charge-of-updating-the-nutri-score-changes-to-the-algorithm-for-solid-foods/) has recently evolved with a stricter new version. So you need the new Nutriscore labels while keeping the old one because not all products implement the new Nutriscore. Some companies have even completely abandoned labeling.

You started with a Nutriscore table in an SQL database:

```sql
product_id: key
nutriscore_label : array[A,B, .., E]
```

so your Nutriscore table requires a new column:

```sql
product_id: key
nutriscore_label: array[A,B, .., E]
nutriscore_new_label: array[A,B, .., E]
```

However, most products don't yet have a new Nutriscore label.

And you end up with a lot of null values in this `nutriscore_new_label` column, and null values should be avoided 👹👹👹.

![NULL values headache](./img/memes/null-values-headache.png)

You can also normalize the table and introduce a Nutriscore version column to help with Null values.

```sql
product_id: key
nutriscore_label: array[A,B, .., E]
nutriscore_version: Int
```

In both cases, you have to change all your SQL queries in your codebase.

Pain, worries, migraines, bugs, and additional costs ＄＄＄.

## Introduction to Schema Flexibility

**Schema Flexibility** in MongoDB and other NoSQL databases refers to the ability to store data without requiring a predefined schema. This means that documents in the same collection can have different fields/attributes, structures, and data types.

Schema Flexibility helps manage **unknown unknowns** in a rapidly changing world.

### Data Presence and Type

In MongoDB: You can simply add a new Nutriscore element to food products:

No Nutriscore

```json
{
  "product_id": 198273,
  "name": "Chocapic",
}
```

Nutriscore is added, just add a field to the product document

```json
{
  "product_id": 198273,
  "name": "Chocapic",
  "Nutriscore": "C"
}
```

A new version of Nutriscore arrives, just add the Nutriscore label as a dictionary with versions as keys:

```json
{
  "product_id": 198273,
  "name": "Chocapic",
  "Nutriscore": {
    "v1": C,
    "v2": D,
  }
}
```

Several representations can therefore **coexist** in the same database:

- No Nutriscore
- A single Nutriscore as a _string_
- A Nutriscore dictionary as a nested/embedded document
