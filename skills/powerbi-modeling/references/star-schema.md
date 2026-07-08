# Star schema

The star schema is the target shape for a Power BI model. It is a mature dimensional modeling
approach (Ralph Kimball) that the Power BI engine is built around. Get the shape right and the
rest of the model, the relationships, the measures, and the report, all get easier. Names here
are placeholders. Use `ABC Company` and generic column names in anything shared, not real ones.

## Dimensions vs facts

Every model table is either a dimension or a fact. Decide which before you do anything else.

- A dimension table describes a business entity: the things you filter and group by. Product,
  Customer, Store, Employee, and Date are dimensions. A dimension has one key column that
  uniquely identifies a row, plus descriptive columns (name, category, color, region) that
  people slice and group on.
- A fact table stores events or observations: the things you measure. A sale, an order line, a
  stock balance, a ticket. A fact holds the dimension key columns that point at the dimensions,
  plus the numeric columns you aggregate (quantity, amount, cost).

Dimensions filter and group. Facts summarize. A visual picks dimension columns for its axis and
legend, then sums or counts fact columns. Build the model to match that split. Do not mix the
two types in one table. The one narrow exception is a degenerate dimension, an attribute like an
order number that lives on the fact purely for filtering.

## Define the grain first

The grain is what one row of a fact table means. Write it in one plain sentence before you add
any column. "One row per sales order line." "One row per account per month end." "One row per
ticket state change."

Two rules follow from the grain:
- Every row sits at the same grain. Do not park an order total row next to order line rows in
  the same table.
- Every column must make sense at that grain. If a column only makes sense at a different level,
  it belongs in a different table.

If two sets of numbers have different grains, put them in two fact tables and let them share the
dimensions. A daily sales fact and a monthly budget fact do not go in one table. They each relate
to the Date and Product dimensions at their own grain.

## Why a star suits Power BI and VertiPaq

Power BI stores the model in VertiPaq, an in memory columnar engine that compresses each column
on its own. A star schema plays to that:

- Low repetition compresses well. A fact table of narrow integer keys plus numbers compresses
  hard. Descriptive text sits once in the dimension, not repeated on every fact row.
- Relationships match the engine. A one to many relationship from a dimension to a fact is
  exactly the filter path a visual needs. The "one" side (dimension) filters the "many" side
  (fact).
- Fewer, simpler paths. Filters travel a short, predictable route from dimension to fact, so
  queries are faster and results are easier to reason about.

Microsoft guidance is explicit: model as a star schema for performance and usability. See
`guidelines/sources.md` for the Microsoft Learn and SQLBI links.

## Star vs snowflake

A snowflake splits one dimension across several normalized tables (Product to Subcategory to
Category, as three tables). It is not wrong, but for Power BI prefer the flatter star. Collapse
the snowflake into a single dimension table with Category and Subcategory as columns on the
Product table.

Why flatter is usually better here:
- Fewer tables to load and fewer relationship hops for a filter to cross.
- The field list is cleaner, so report authors are not hunting through one column tables.
- You can build a Category to Subcategory to Product hierarchy inside a single table. You cannot
  build a hierarchy that spans several tables.

Keep a snowflake only when a dimension is genuinely huge and the normalized split saves real
size, or when the source already models it that way and flattening is expensive. That is the
exception, not the default.

## Why one flat table is usually worse than a star

The opposite mistake is dumping everything into one wide table. It feels simple, but it is
usually worse than a star:

- It repeats every dimension's text on every fact row, which compresses worse and grows the
  model.
- It cannot filter two different facts from one shared dimension. With a star, one Date table
  filters sales and budget together. One flat table cannot.
- Slicers get messy. The distinct values of a repeated column are scattered across millions of
  rows instead of sitting in a small clean dimension.
- Any change to a dimension attribute has to be rewritten across every row.

A star is a little more work up front and pays off in size, speed, and clarity. See the SQLBI
"star schema or single table" article in `guidelines/sources.md`.

## The three fact types

Kimball describes three kinds of fact table. Knowing which one you are building keeps the grain
honest.

1. Transaction fact. One row per event, at the moment it happens. A sales line, a payment, a
   ticket created. This is the most common type and the default you should reach for.
2. Periodic snapshot fact. One row per entity per regular time slot, capturing a state. An
   account balance at each month end, headcount per department per week. You take a picture at
   set intervals, whether or not anything changed.
3. Accumulating snapshot fact. One row per process instance, with several date columns for the
   milestones, updated in place as the instance moves along. An order with order date, ship
   date, and delivery date on one row, filled in as it progresses.

Do not blend types. A transaction fact and a monthly snapshot are two tables sharing the same
dimensions.

## Worked example: Sales

Say ABC Company wants to analyze sales. The raw export is one wide sheet with order line rows
and repeated customer and product text. Reshape it into a star.

Grain: one row per sales order line.

Fact table, `Sales`:
- Keys: `DateKey`, `ProductKey`, `CustomerKey` (whole number keys pointing at the dimensions).
- Numbers: `Quantity`, `UnitPrice`, `SalesAmount`, `Cost`.
- Degenerate dimension: `SalesOrderNumber` kept on the fact for filtering.

Dimension `Date`: one row per day, with `DateKey`, `Date`, `Year`, `Quarter`, `Month`,
`MonthNumber`, `DayName`. Marked as the model's date table.

Dimension `Product`: one row per product, with `ProductKey`, `ProductName`, `Category`,
`Subcategory`, `Color`. Category and Subcategory are folded in here, not snowflaked out.

Dimension `Customer`: one row per customer, with `CustomerKey`, `CustomerName`, `Segment`,
`City`, `Country`.

Relationships: one to many from each dimension into `Sales`, single cross filter direction, on
the key columns. Measures like `Total Sales = SUM ( Sales[SalesAmount] )` live in a `_Measures`
table, not on `Sales`. See `references/relationships.md` and `references/naming-and-measures.md`.

The result: three small dimensions, one narrow fact, clean one to many relationships, and a Date
table that filters everything. That is a star, and it is the shape the rest of the skills assume
you have built.

## Quick checklist

- Is every table clearly a dimension or a fact, with no mixing (bar a degenerate dimension).
- Is the grain of each fact written in one sentence, and does every row hold to it.
- Are dimensions flattened into a star, not left as a snowflake, unless there is a real reason.
- Is descriptive text living once in a dimension, not repeated across a wide flat table.
- Does each fact table hold a single fact type, not a blend of transaction and snapshot rows.
