# Query folding and the duplication trap

Two ideas explain most Power BI refresh performance: whether work folds to the source, and
whether the source gets read more than once.

## Query folding

Folding means Power Query pushes your steps (filter, group, select) back to the source as a
single native query, so the source does the work and returns less data. When folding stops,
everything after that point runs locally in the mashup engine, on all the rows.

- Check it: in the Power Query editor right click a step and look for "View Native Query".
  If it is available, steps up to there fold. If it is greyed out, folding stopped at or
  before that step. There are also step folding indicators in current Power Query.
- Things that usually break folding: custom M functions, `Table.Buffer`, adding an index,
  many kinds of merge, changing types in awkward ways, and any source that cannot fold at
  all (a plain REST call, a workbook, most file sources).
- On a non folding source (REST, SharePoint file), you cannot make it fold. Instead, filter
  at the source itself. For a REST API, put the filter in the request (a date clause in the
  query string), do not pull everything and filter in M.

Order of preference: filter and reduce at the source, then in a folding step, and only as a
last resort in a non folding local step.

## The duplication trap: a referenced query runs again

In an import model, each loaded table is evaluated on its own. When one query references
another by name, for example `Source = stg_incident`, Power Query does not reuse the other
query's result. It re-executes that query's full M, including its API calls. There is no
shared cache between tables during refresh.

This is worse in the Service than on your machine, which is why a model can refresh fine in
Desktop and fail on a schedule. Desktop refreshes all tables against a single shared cache. The
Service gives every query its own cache, so nothing is reused across tables. Microsoft: "In a
cloud environment, each query is refreshed using its own separate cache. So a query can't
benefit from the same request having already been cached for a different query."

Consequences:
- If three loaded tables each reference the same expensive staging query, that staging
  query, and its network calls, run three times.
- Chains multiply. If `staging` is referenced by `fact`, and `fact` is referenced by an
  `aggregate` table, and all three are loaded, then `staging` can run once for itself, again
  inside `fact`, and again inside `aggregate`. A slow API pull can therefore happen several
  times in one refresh, which is a classic cause of an 8 or 9 hour refresh.

See Chris Webb, "Why does Power BI query my data source more than once".

## How to reduce it on Pro

There is no free shared cache on Pro. The levers are:

1. Make each pull cheap. Fold or filter at the source, use modest REST page sizes, read
   SharePoint files directly. A pull that runs three times but is fast is fine.
2. Reduce fan out. Do not have many loaded tables each re-derive from the same expensive
   staging query. Where you can, load the staging result once and let the model relate to it,
   rather than re-shaping it again in three more loaded tables.
3. `Table.Buffer` helps reuse a result WITHIN a single query evaluation (for example a lookup
   used many times in the same query). It does not help across separate loaded tables.
4. A DAX calculated table can aggregate or reshape tables that are already loaded in memory, with
   no source calls, so a pure roll up of already loaded tables does not re-run the pipeline. This is
   often the single biggest refresh win: converting a derivative M table that re-runs its upstream
   pulls into a calculated table that computes in memory. Two cautions: a calculated table recomputes
   on every refresh and does not fold, so convert only derivative tables, never the source pulls. You
   can convert an existing import table to a calculated table by editing the TMDL, if you delete
   `.pbi\cache.abf` first so Desktop rebuilds fresh from the TMDL. See `powerbi-project-and-tools`
   and `pro-vs-premium-facts.md` in the `powerbi-project-and-tools` skill.

   Know what this trade actually is. It moves cost out of the data phase and into the recalc
   phase, where the table is rebuilt in full on every refresh. It wins when the source pull
   dominates, which is the usual shape of a multi hour Pro refresh, and it is not free. Microsoft
   does not recommend it, their documented fix for fan out is a dataflow, which on Pro means
   Dataflow Gen1 with the problems listed in point 5. The Best Practice Analyzer also flags heavy
   use of calculated tables as technical debt. So after converting, go and clean up the recalc
   phase you just loaded, starting with auto date/time. See `refresh-cost-model.md`.
5. Dataflows would materialize the staging once, but Dataflow Gen1 on Pro is unreliable when
   a refreshing model imports it (no orchestration, no folding). Treat it as a last resort
   and sequence it by hand. The clean version needs Fabric or Premium.

## Quick checklist

- Are filters at the source, not in M after a full pull.
- Does the query fold as far as possible (View Native Query).
- How many loaded tables reference each expensive staging query. Fewer is faster.
- Is any single REST page too large to build inside the source's limit.
- Is a SharePoint single file being read directly, not via a whole site crawl.
