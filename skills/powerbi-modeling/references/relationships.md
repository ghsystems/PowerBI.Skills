# Relationships

Relationships are the model. They decide how a filter on one table reaches another, and they are
what makes a table a dimension or a fact. Get them right and the numbers are predictable. Get
them wrong and you get blanks, doubled totals, or filters that do nothing.

## Cardinality: one to many is the default and the goal

Cardinality is how many rows on each side of a relationship share a key value.

- One to many is what you want almost every time. The "one" side is a dimension with unique keys.
  The "many" side is a fact where the key repeats. The dimension filters the fact. A star schema
  is a set of one to many relationships from dimensions into facts.
- One to one is rare. It usually means two tables should be one, or that you are looking at a
  degenerate dimension. Merge them unless you have a specific reason.
- Many to many cardinality (both sides non unique) is a warning sign, not a tool to reach for.
  It has real pitfalls (see below). Prefer a bridge table.

Power BI decides the table type from cardinality. The "one" side is always a dimension, the
"many" side is always a fact. If a relationship you expected to be one to many comes up many to
many, your "one" side has duplicate or blank keys. Fix the key, do not accept the many to many.

## Cross filter direction: single is safer than both

Every relationship has a cross filter direction, single or both.

- Single means the filter flows one way, from the "one" side (dimension) to the "many" side
  (fact). This is the safe default and it is what a star schema wants. A slice on Product filters
  Sales. That is all you usually need.
- Both (bidirectional) lets the filter flow the other way too, from the fact back up into the
  dimension. It is occasionally useful but dangerous as a default.

Why single is safer:
- Predictable numbers. Filters travel one known path, so a measure returns what you expect.
- No ambiguity. With several dimensions on one fact, bidirectional filters can create more than
  one path between two tables. The engine then cannot tell which path to use, and you get
  ambiguous or wrong results. Power BI will even block some bidirectional relationships that
  would make the model ambiguous.
- Speed. Every extra filter direction is more work per query.

Leave cross filter direction on single. Turn on both only for a deliberate reason, almost always
a bridge table for a genuine many to many, and only once you know the filter paths it opens. Do
not flip a dimension to fact relationship to both just to make one visual work. That fix usually
breaks another number quietly.

## Active vs inactive relationships and USERELATIONSHIP

Between any two tables, only one relationship can be active at a time. The active one is the
default filter path (a solid line in the diagram). Extra relationships between the same two
tables must be inactive (a dashed line).

The classic case is role playing dates. A `Sales` fact has an order date, a ship date, and a
delivery date, all pointing at one `Date` table. Only one of those relationships can be active,
usually order date. The others sit inactive.

To use an inactive relationship, turn it on for a single measure with `USERELATIONSHIP`:

```dax
Sales by Ship Date =
CALCULATE (
    [Total Sales],
    USERELATIONSHIP ( Sales[ShipDateKey], 'Date'[DateKey] )
)
```

Two ways to handle role playing dimensions:
- Keep one Date table and write a measure per role with `USERELATIONSHIP`. Fewer tables, but a
  measure for every date role.
- Add a separate dimension table per role (a `Ship Date` table, a `Delivery Date` table), each
  with its own active relationship. More tables, but no special measures, and you can filter by
  two roles at once.

Pick per model. For DAX detail on `USERELATIONSHIP` and measure patterns, see `powerbi-dax`.

## Many to many and bridge tables

Sometimes two entities relate many to many by nature. A salesperson covers many regions, and a
region has many salespeople. A product belongs to many campaigns, and a campaign holds many
products.

Do not wire this as a direct many to many relationship. Add a bridge table (Kimball calls it a
factless fact table). It holds one row per valid pair of keys:

- `Bridge` table columns: `SalespersonKey`, `RegionKey`. One row per real assignment.
- One to many from `Salesperson` into `Bridge`, and one to many from `Region` into `Bridge`.

The bridge turns one awkward many to many into two clean one to many relationships. To make a
filter cross the bridge from one dimension to the other you may need bidirectional filtering on
one leg, or a measure using `CROSSFILTER`. Turn that on deliberately and test the totals. See the
Microsoft many to many guidance in `guidelines/sources.md`.

Why the bridge beats a direct many to many relationship:
- You control exactly where filters cross, one leg at a time.
- Totals are easier to keep correct. Direct many to many relationships are prone to overcounting
  and surprising blank handling.
- The model stays a set of one to many relationships, which is easier to read and maintain.

## Relationship columns must be clean keys

A relationship is only as good as the columns it joins on. The key on the "one" side must be:
- Unique. No duplicate values. Duplicates force the relationship to many to many and break
  filtering.
- Non blank. Blank or null keys drop rows or bucket them into a single blank member.
- One data type on both ends. A text key on one side and a number on the other will not match, or
  will match slowly. Whole number keys are best, they compress and join fastest.

Practical habits:
- Join on a dedicated key column, not on a display name. Two customers can share a name.
- Build surrogate integer keys upstream in M or at the source when the source has no clean key.
- Check the fact for orphan keys (a key with no matching dimension row). Those show up as a blank
  member in visuals and are usually a data load bug.
- Keep the key work in M or the source, not in DAX calculated columns. See
  `guidelines/pro-vs-premium-facts.md`.

## Quick checklist

- Is every relationship one to many from a dimension into a fact.
- Is cross filter direction single everywhere, except a deliberate, tested bridge.
- Does any table pair have more than one relationship. If so, is the right one active, and are the
  others driven by `USERELATIONSHIP`.
- Is every "one" side key unique, non blank, and a single data type.
- Is any many to many wired through a bridge table, not a direct many to many relationship.
- Are there orphan keys on the facts showing up as a blank member.
