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
validation rejects that too.

## Never attach measures to data tables

Even one measure sitting on a fact or dimension is a smell. It ties the measure to that table's
lifetime and buries it in the field list under the data columns. Move every measure to
`_Measures`. Report authors read numbers from the measure table and slice by columns on the data
tables. The two jobs stay separate.

## Prefix every table with its role

Column and measure names get all the attention, and table names get none. Give tables a prefix
taxonomy that doubles as a pipeline. This one comes from a production model:

| Prefix | Holds |
| --- | --- |
| `stg_` | raw pull from one source, load disabled |
| `int_` | intermediate transform, load disabled |
| `xform_` | a union or reshape that several tables build on |
| `dim_` | dimension |
| `fact_` | fact |
| `cfg_` | config read only by DAX, hidden |
| `_Measures` | the measure holder |

The payoff is plain. The field list sorts into pipeline order instead of alphabetical soup, and
you can tell from the name alone what a table is and whether it should be visible to a report
author. A `stg_` table showing up in the field list is a bug you can spot without opening
anything.

Mirror the same taxonomy in the Power Query query groups so the editor matches the model. In
TMDL, a backslash makes a nested group:

```tmdl
queryGroup 00_Admin
	annotation PBI_QueryGroupOrder = 0
queryGroup 02_Staging
	annotation PBI_QueryGroupOrder = 2
queryGroup 04_Model\Dimensions
	annotation PBI_QueryGroupOrder = 0
```

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

## Give every measure a display folder, a description, and a format string

Three properties turn a flat list of measures into something a report author can actually
navigate, and they cost seconds per measure in the Properties pane:

- `DisplayFolder`, so related measures group together in the field list instead of one long
  alphabetical list. Group by subject, for example `Sales`, `Sales\YoY`, `Capacity`.
- `Description`, a one line note on what the measure does and any assumption it bakes in. It
  shows as a tooltip when a report author hovers the measure, which saves them a trip to ask
  you what it means.
- `FormatString`, set explicitly rather than left to the default. A percent measure with no
  format string looks like a raw decimal on a card until someone fixes it after the fact.

Set these before a measure ships in a report, not after someone asks why it looks wrong. This
is a standard Analysis Services modeling practice, not a house quirk, and it is cheap insurance
against a report that reads sloppy.

A rule shown zero times keeps losing. In one production model, of 48 measures, 0 had a display
folder, 0 had a description, and 2 had an explicit format string. So here is the TMDL, with no
excuse left to skip it:

```tmdl
	measure 'Effort Ratio' = DIVIDE ( [Total Effort], [Estimated Effort] )
		displayFolder: Ratios
		formatString: 0.0%
		description: Actual logged effort over the company month estimate. Returns 0, not blank, when no estimate exists.
		lineageTag: 7d000001-0000-4000-8000-000000000001
```

One warning worth its own paragraph. `annotation PBI_FormatHint = {"isGeneralNumber":true}` is
not a format string. It is Desktop recording that the format was left on the default. An audit
that greps for any formatting at all will count those lines as formatted and hand back a clean
report on a model that has none. Grep for `formatString:` specifically.

## A measure name taxonomy that survives missing folders

Display folders get skipped, as the numbers above show. A naming pattern does not get skipped,
because the name is the thing people read. Use one that carries the same grouping in the name,
so the list still reads well with no folders and maps straight onto folders the day you add
them. From the same model:

| Pattern | Returns | Folder it maps to |
| --- | --- | --- |
| `Title <Visual>` | a string for a dynamic visual title | `Titles` |
| `<X> Color`, `<X> Heat Font` | a hex string | `Formatting` |
| `<X> %`, `<X> Ratio` | a ratio | `Ratios` |
| `<X> Hours` | a quantity | `Effort` |

Two of these are rules, not preferences:

- One title measure per visual, named after the visual it titles, not after the number it
  computes. When someone deletes the visual, the measure to delete is obvious.
- Never ship a background color measure without its paired font color measure. On the dark end
  of a color ramp, dark text on that background is unreadable, so the pair always travels
  together.

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

### `changedProperty = IsHidden` does not hide anything

In TMDL, a line reading `changedProperty = IsHidden` only records that the property was touched
at some point. It does not set it. Without a separate `isHidden` line on the column, the column
is visible. In a production model an entire 24 column dimension read as hidden in a diff and
shipped fully exposed in the field list.

Count the real hides and compare that count against what you expect:

```powershell
Select-String -Path .\*.SemanticModel\definition\tables\*.tmdl -Pattern "^\s*isHidden\s*$" |
  Measure-Object
```

Trust that number. A scan for `changedProperty` tells you nothing about what is actually
hidden.

## One Date table, marked as a date table

Have exactly one Date dimension, built for the job, and mark it. In Power BI Desktop, select the
table, then Table tools, Mark as date table, and point it at the date column.

- One continuous Date table with no gaps across the range the facts cover.
- Relate each date key on the facts to it (order date active, other date roles inactive, per
  `references/relationships.md`).
- Marking it as a date table makes time intelligence (`TOTALYTD`, `SAMEPERIODLASTYEAR`, and so on)
  behave correctly. See `powerbi-dax`.
- Generate it in M or DAX. A DAX calculated Date table is fine and common, just keep it small. See
  `pro-vs-premium-facts.md` in the `powerbi-project-and-tools` skill.

### When a marked Date table genuinely does not apply

That rule is right by default and wrong for one real shape. If the fact grain is a period the
business names, a sprint, a cycle, a billing period, rather than a date, then a marked date
table and time intelligence may not apply at all. In a production model the grain is the
sprint. Its date table is deliberately not marked, it carries 2 of 25 relationships, and not
one of its 48 measures calls a time intelligence function.

What replaces it:
- A period dimension with a start date and an end date, so a visual can still answer "when".
- Period comparison by an explicit key, a composite month or sprint key, not
  `SAMEPERIODLASTYEAR`.
- Cumulative windows written over an ordered column, `FILTER ( ALLSELECTED ( col ), col <= MAX
  ( col ) )`. See the `powerbi-dax` skill.

Two things hold either way:
- Turn auto date/time off regardless. In `model.tmdl` that is
  `annotation __PBI_TimeIntelligenceEnabled = 0`.
- Do not let an agent or a reviewer "fix" this by marking the date table. It will not make a
  single measure better and it adds a date hierarchy nobody uses.

## Page layout (house preference)

Report layout is the report-design skill's job, but the house default that pairs with this model
is worth stating so the model supports it:

- Page 1 is the summary: KPI cards plus one Date slicer (a Year, Quarter, Month hierarchy, not
  separate Year and Month slicers), nothing else.
- Page 2 is the supporting detail: the tables and the trend charts.

For the model, that means clean measures for the KPI cards and a proper marked Date table with a
Year, Quarter, Month hierarchy so the Date slicer works. For the actual layout, slicer choices,
and visuals, see
the `powerbi-report-design` skill and its `design-principles.md` reference.

## Quick checklist

- Are all measures in `_Measures`, and is that table named with the leading underscore, never the
  bare reserved word `Measures`.
- Are there zero measures sitting on fact or dimension tables.
- Does every table name carry its role prefix (`stg_`, `int_`, `xform_`, `dim_`, `fact_`,
  `cfg_`).
- Does every shipped measure really have a display folder, a description, and a format string,
  checked by grepping for `formatString:` and not for a format hint annotation.
- Are all key, foreign key, and sort by columns hidden with a real `isHidden` line, not just a
  `changedProperty` entry.
- Are user facing names friendly and consistently cased.
- Is the Date table decision made deliberately, either exactly one marked date table, or a
  period dimension with auto date/time off and no time intelligence.
