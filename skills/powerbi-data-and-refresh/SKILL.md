---
name: powerbi-data-and-refresh
description: >-
  Build and troubleshoot the data layer of a Power BI model: Power Query (M) sources,
  connecting to REST or OData or a ServiceNow Table API or SharePoint or Excel on
  SharePoint, paging through an API, query folding, and refresh performance. Use whenever
  the user is writing or fixing M queries, wiring Power BI to an API or SharePoint, paging a
  REST endpoint, or hitting a slow, stuck, or failing refresh: a refresh timeout, "the
  operation was cancelled", an 8 or 9 hour refresh, a scheduled refresh that fails, a
  query that runs twice, or a Dataflow Gen1 that collapses when mixed into a model. Trigger
  on phrases like "connect power bi to", "my refresh is slow", "refresh keeps failing",
  "refresh timed out", "paginate the api in power query", "power query queries twice",
  "should I use a dataflow". Assumes Power BI Pro only, no Fabric or Premium.
---

# Power BI data and refresh

This skill covers the data layer: how data gets into the model and why refresh is fast,
slow, or failing. It assumes Power BI Pro (no Fabric or Premium). For the hard license
facts, read `pro-vs-premium-facts.md` in the `powerbi-project-and-tools` skill.

## When to use

Use this for anything about M and Power Query, connecting to a source, paging an API, or a
refresh that is slow or failing. For star schema and relationships use `powerbi-modeling`.
For DAX use `powerbi-dax`. For the pbip and TMDL file format and external tools use
`powerbi-project-and-tools`.

## The mental model

1. Pull only what the model needs. Filter early, select only the columns you use, and push
   work to the source when the source can do it (folding).
2. Watch for the source being read more than once. Referencing another loaded query does
   not reuse its result, it re-runs the whole pipeline.
3. A Pro refresh has a hard 2 hour cap. If a single query runs past it, the refresh is
   cancelled and fails. Most "will not refresh" cases are a timeout, not a credential issue.
4. Refresh has two phases and they need opposite fixes. The data phase pulls and compresses,
   the recalc phase rebuilds calculated tables, calculated columns, relationships, and
   hierarchies. Know which one is slow before changing anything. See
   `references/refresh-cost-model.md`.

## On a brand new model, do this first

Set the defaults while the file is still empty, because they are free now and expensive later.

- Turn OFF auto date/time globally (File, Options and settings, Options, Time intelligence,
  the Global page option labelled "Auto date/time for new files"). Left on, Power BI builds a
  hidden calculated date table for EVERY date column in every Import table, each with six
  calculated columns, and rebuilds all of them on every refresh. Build one date table instead
  and mark it as a date table.
- Disable load on staging queries, and keep the number of loaded tables referencing the same
  expensive staging query low.
- Keep the first argument of `Web.Contents` a literal string, with everything variable in
  `RelativePath` and `Query`, or the Service will refuse to refresh a dynamic data source.

Full reasoning and the rest of the list in `references/refresh-cost-model.md`.

## Workflow

1. Identify each source and how it connects. Prefer the most specific connector. For a file
   on SharePoint, read the file directly, do not crawl the whole site (see below).
2. Keep sources thin. Apply filters and column selection as early as possible so less data
   moves and folding has a chance.
3. Check folding. In the Power Query editor, right click a step and look for "View Native
   Query". If it is available, the work is being pushed to the source. If it greys out at a
   step, everything after that step runs locally in the mashup engine.
4. For a REST or ServiceNow source, page with a stable cursor and a page size the source can
   assemble inside its own limits. See `references/connecting-to-sources.md`.
5. When refresh is slow or fails, do not guess. Follow the diagnosis steps in
   `references/refresh-troubleshooting.md` (watch the per table timer in Desktop, read the
   Service refresh history detail, find the one table that eats the time).

## Rules of thumb

- SharePoint file: use `Web.Contents("https://tenant.sharepoint.com/sites/Site/.../File.xlsx")`
  wrapped in `Excel.Workbook`. Do NOT use `SharePoint.Files("https://tenant.sharepoint.com/sites/Site")`
  for one file, because it enumerates every file in the whole site first and can run for
  many minutes. This alone can cause a multi hour refresh. Only reach for the site crawl when
  the file will move or you cannot get a stable path. Do not use the REST `GetFileById` endpoint
  for a normal read, its credential test is fragile. Full decision rule in
  `references/connecting-to-sources.md`.
- REST paging: a ServiceNow Table API or similar should page with `List.Generate`, order by
  a stable key (for ServiceNow, `ORDERBYsys_id`), stop as soon as a page returns fewer rows
  than the page size, and keep the row ceiling the same if you change the page size (page
  size times max pages). A very large page with expanded reference or display values can hit
  the source's own transaction limit and be cancelled, which surfaces to Power BI as "the
  operation was cancelled". Smaller pages (a few thousand) are safer. Add a per request
  `Timeout` to `Web.Contents` so a stalled call fails fast instead of hanging toward the
  2 hour wall.
- Do not push a Dataflow Gen1 into a model that also refreshes on a schedule. On Pro there
  is no orchestration between the two, so the model can read stale or partial data or fail.
  See `pro-vs-premium-facts.md` in the `powerbi-project-and-tools` skill.
- Referencing another loaded query (`Source = OtherQuery`) re-runs that query in full every
  time. If three loaded tables reference the same expensive staging query, that staging
  query, and its API calls, run three times. See `references/folding-and-duplication.md`.

## References in this skill

- `references/connecting-to-sources.md`: REST and ServiceNow paging pattern, SharePoint file
  reads, auth, and the shape of a clean staging query.
- `references/folding-and-duplication.md`: query folding, and the "referencing a query
  re-runs it" duplication trap, with how to reduce it on Pro.
- `references/refresh-troubleshooting.md`: a step by step for a slow or failing refresh, the
  Pro limits, and what each error message means.
- `references/refresh-cost-model.md`: the design time view. The two refresh phases and how to
  tell which one is slow, what loads each, auto date/time in depth, and the defaults to set on
  a new model before any real work.
