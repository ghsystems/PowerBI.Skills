# Measures vs calculated columns vs calculated tables

Three things in DAX look similar and are not. Picking the wrong one is the most common way a
model gets slow and bloated. The short rule: default to a measure, compute columns upstream,
and keep calculated tables small.

## Measure

A measure is a calculation run at query time inside the current filter context. It stores no
data and adds nothing to the model file. It recomputes for every cell of every visual as the
user filters.

- Use it for anything that aggregates or reacts to slicing: sums, ratios, counts, time
  intelligence, ranking, running totals.
- A measure has no row it belongs to. It reads the filter context, not "this row".
- The cost is CPU at query time, not model size. This is the cheap option. Reach for it first.

## Calculated column

A calculated column is a DAX expression evaluated once per row during refresh and stored on
the table, like any other column.

- It runs in row context. It sees the current row and can reference other columns on it.
- It is stored, so it costs model size and refresh time. DAX calculated columns also do not
  compress as well in VertiPaq as columns that arrive with the data.
- Prefer computing the column upstream in M (Power Query) or at the source. Those columns
  compress better and do not recompute on every refresh. See
  `guidelines/pro-vs-premium-facts.md`.
- Use a calculated column only when the value must physically exist on the row (to group by it,
  relate on it, or slice on it) AND it needs model or row context that M cannot give. An
  example is a value pulled across a relationship with RELATED, or a rank within the row's
  group.

Rule of thumb: if you can compute it in M, do it in M. If you can express it as a measure, do
that instead. A calculated column is the last resort of the three.

## Calculated table

A calculated table is a table whose rows come from a DAX expression, evaluated on refresh.

- It is common and fine for a Date table (CALENDAR or CALENDARAUTO plus added columns), a small
  bridge or disconnected table, or a filtered copy for a specific need.
- It recomputes on every refresh and does not fold to any source. It is pure model compute.
- Keep it small. A Date table over your real date range is fine. Do not build a giant
  calculated table when the source could deliver the rows already shaped.
- For the Date table specifically, build it once and mark it as a date table. See
  `powerbi-modeling`.

## Row context vs filter context, in plain terms

Two different contexts drive every DAX result.

- Filter context is the set of filters active right now: the row and column of a matrix, a
  slicer, a page filter, or a filter you passed to CALCULATE. Measures live here. A measure
  sees the current slice and aggregates over the rows that survive it.
- Row context is the current row while a calculation scans a table. A calculated column has a
  row context automatically (the row it is computing). Iterators like SUMX, AVERAGEX, and RANKX
  create a row context as they walk their table.
- Row context does NOT filter the model by itself. Being on a row does not restrict what a
  measure inside that row can see. That surprises people.

## Context transition, what CALCULATE does

CALCULATE takes the current row context and turns it into filter context. That is context
transition. It is the single most important idea in DAX.

- Inside an iterator, wrapping an expression in CALCULATE makes the current row become a filter
  on the whole model for that one evaluation.
- Every measure reference carries an implicit CALCULATE. So calling a measure from inside SUMX
  already applies context transition on each row. This is why a measure called row by row can
  give a different, usually correct, answer than the same raw expression.
- Practical effect: if a total does not equal the sum of the visible rows, context transition
  (or the lack of it) is usually why. Decide whether you want the measure evaluated per row and
  then combined, or evaluated once over the whole visible set.

Keep the wording simple when you explain it. CALCULATE says "take where I am right now and
treat it as a filter".

## The import to calculated table trap

You cannot convert an existing imported (M) table into a calculated table by editing the pbip
or TMDL files by hand. Power BI Desktop validates the partition type on open and rejects the
change with this error.

```
PFE_TM_DDL_CHANGED_PARTITION_FROM_OR_TO_CALC
```

Swapping a table's partition from an M partition to a calculated (DAX) partition, or back, is
blocked. The project will not open until you revert the edit.

To turn logic into a calculated table, do it inside Power BI Desktop instead.

1. Create a new calculated table with the DAX you want. Give it a fresh name.
2. Move relationships, measures, and dependent visuals onto the new table.
3. Delete the old imported table.

See `powerbi-project-and-tools` for the pbip and TMDL details and why hand editing the
partition type fails.
