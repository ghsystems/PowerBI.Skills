# Refresh troubleshooting

A slow or failing refresh is almost always one table or one query, not the whole model. Do
not guess. Find the culprit, then fix that.

## Diagnose

1. Reproduce in Desktop. Home, then Refresh. A dialog lists every table with its own timer.
   Watch it. Healthy tables finish in seconds. The one still spinning after two or three
   minutes while the rest are done is the culprit. Cancel once you can see which one it is,
   you do not need to wait it out.
   - Note: the Power Query preview only pulls the first rows and often only the first page,
     so it does not reproduce a multi hour pull. Only a real refresh does.
2. In the Service, open the dataset settings, Refresh history, then the failed run, then
   Show. It lists the attempts and, where available, per table durations and the exact error.
   A repeating pattern of attempts that each run about two hours and then fail means a single
   query is hitting the 2 hour cap and being cancelled.

## What the common errors mean

- "The operation was cancelled" and "the exception was raised by the IDbCommand interface":
  a timeout or a source side cancellation. Not credentials. A query ran too long, or the
  source (for example ServiceNow) cancelled a heavy request. Fix by making that query
  cheaper (smaller pages, direct file reads, less duplication) and add a `Timeout`.
- "Formula.Firewall ... information could not be combined": privacy levels. Two sources with
  mismatched privacy are being combined. Set them consistently (often Organizational).
- "Please specify how to connect": missing or wrong credentials on that source.
- "The key did not match any rows" or a missing column: schema drift, the source changed its
  columns. Make the query tolerant (MissingField.Ignore, check column presence).

## The usual culprits, in order

1. A `SharePoint.Files("...site...")` call used to grab one file. It crawls the entire site
   first. Replace with a direct `Web.Contents` file URL. This is a frequent multi hour cause.
2. A REST page that is too large to build inside the source's transaction limit, so the
   source cancels it. Lower the page size (a few thousand), keep the row ceiling by raising
   max pages, add a `Timeout`.
3. Duplication: several loaded tables re-running the same expensive staging query. See
   `folding-and-duplication.md`. Reduce fan out or make the pull cheap.
4. A genuinely large table with no source side filter. Filter at the source, or use
   incremental refresh (below).
5. Auto date time hierarchies adding hidden work. Consider turning off the global "Auto
   date/time" option and using one proper Date table instead.

## The Pro limits that bite

- A single refresh run is capped at 2 hours on Pro. Past that it is cancelled.
- 8 scheduled refreshes per day, at least 30 minutes apart. API triggered refreshes count.
- 1 GB model size. A model near the cap is slow to refresh and may fail.

See `guidelines/pro-vs-premium-facts.md` for the full list.

## Incremental refresh on Pro

Incremental refresh is available on Pro and is the right tool for a large history that only
grows. Set RangeStart and RangeEnd parameters and a date filter. The catch: it only saves
work if the date filter folds to the source. For a non folding REST or SharePoint source,
inject the RangeStart and RangeEnd into the source request yourself (put the date range in
the API query string), otherwise Power BI still pulls everything before filtering.

## A safe fixing routine

- Make one change at a time and re-test in Desktop before publishing.
- Back up the pbip folder (a plain copy, or git) before editing.
- Keep changes that preserve row counts. If you change a page size, adjust max pages so the
  total ceiling is unchanged, so you never silently truncate data.
- After it refreshes fast in Desktop, republish. If the Service still fails, re-check the
  data source credentials and privacy levels in the dataset settings.
