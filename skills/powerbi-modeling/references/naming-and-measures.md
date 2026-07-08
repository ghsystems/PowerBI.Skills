# Naming and measures

A model that is correct can still be hard to use. Naming and organization are what make it usable
for the next person, including future you. These are house conventions. They are cheap to apply
and they pay off every time someone opens the field list.

## Put every measure in a `_Measures` table

Keep all measures in one dedicated holder table called `_Measures`. Not on the fact, not
scattered across data tables. One home.

Why a single measure table:
- People find measures in one place instead of hunting through data tables.
- The leading underscore sorts the table to the top of the field list.
- Measures stop moving around when you refactor the tables they read from.

How to make one in Power BI Desktop:
1. On the Home ribbon, choose Enter data, create a table with one throwaway column, and load it.
2. Rename it `_Measures`.
3. Create or move your measures into it.
4. Hide the throwaway column. Once a table holds only measures, Power BI shows it with a measure
   (calculator) icon and pins it near the top.

## Never name a table exactly `Measures` (reserved name trap)

Do not name the table `Measures`. The literal name `Measures` is reserved in the Power BI model.
A model that contains a table named exactly `Measures` can fail to open in Power BI Desktop with
an unsupported table name error, and it has caused service side breakage in the past. This is a
real trap, not a style nit.

Use `_Measures`. The leading underscore both avoids the reserved name and sorts the table to the
top. Avoid the old trick of a leading space (`" Measures"`) as well, since recent Desktop
validation rejects that too. See `guidelines/sources.md` for the write ups.

## Never attach measures to data tables

Even one measure sitting on a fact or dimension is a smell. It ties the measure to that table's
lifetime and buries it in the field list under the data columns. Move every measure to
`_Measures`. Report authors read numbers from the measure table and slice by columns on the data
tables. The two jobs stay separate.

## Naming conventions

- Friendly business names. Rename source columns to what the business calls them. `SalesAmount`
  becomes `Sales Amount`, `cust_nm` becomes `Customer Name`. Do this renaming in the model so
  every report inherits it.
- Consistent casing. Pick one style for user facing names (Title Case with spaces reads well on a
  visual) and apply it everywhere. Do not ship `Sales Amount` next to `unitprice`.
- Name measures for the business question. `Total Sales`, `Sales YTD`, `Open Tickets`, not
  `Measure 1`. A measure name shows up as a column header, so it has to read well.
- Keep raw technical names out of the report. If a column has to keep a technical name for a join,
  hide it (next section).

## Hide keys and technical columns

The field list should show only what a report author should touch.

- Hide every key column. Surrogate keys, `DateKey`, `ProductKey`, and the foreign keys on the
  fact table exist to power relationships, not to be dropped on a visual. Right click, Hide.
- Hide sort by columns and other helper columns (a `MonthNumber` used only to sort `Month`).
- On a fact table, hide all the foreign keys. An author almost never wants a raw key on a visual,
  they want a measure and a dimension attribute.
- What is left visible: the descriptive dimension columns to slice by, and the measures in
  `_Measures`. If a column is neither, hide it.

Hiding is not security. It only tidies the field list. It does not stop anyone who can edit the
model from seeing the column.

## One Date table, marked as a date table

Have exactly one Date dimension, built for the job, and mark it. In Power BI Desktop, select the
table, then Table tools, Mark as date table, and point it at the date column.

- One continuous Date table with no gaps across the range the facts cover.
- Relate each date key on the facts to it (order date active, other date roles inactive, per
  `references/relationships.md`).
- Marking it as a date table makes time intelligence (`TOTALYTD`, `SAMEPERIODLASTYEAR`, and so on)
  behave correctly. See `powerbi-dax`.
- Generate it in M or DAX. A DAX calculated Date table is fine and common, just keep it small. See
  `guidelines/pro-vs-premium-facts.md` and `powerbi-project-and-tools`.

## Page layout (house preference)

Report layout is the report-design skill's job, but the house default that pairs with this model
is worth stating so the model supports it:

- Page 1 is the summary: KPI cards plus a Year slicer and a Month slicer, nothing else.
- Page 2 is the supporting detail: the tables and the trend charts.

For the model, that means clean measures for the KPI cards and a proper marked Date table so the
Year and Month slicers work. For the actual layout, slicer choices, and visuals, see
`powerbi-report-design` and `guidelines/design-principles.md`.

## Quick checklist

- Are all measures in `_Measures`, and is that table named with the leading underscore, never the
  bare reserved word `Measures`.
- Are there zero measures sitting on fact or dimension tables.
- Are all key and foreign key columns hidden.
- Are user facing names friendly and consistently cased.
- Is there exactly one Date table, and is it marked as a date table.
