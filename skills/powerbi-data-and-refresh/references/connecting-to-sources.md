# Connecting to sources

Patterns for the sources that show up most, with a Pro lens. Hosts and names here are
placeholders. Replace `yourinstance` and `yourtenant` with the real values in the model,
and keep real hosts out of any shared or committed file.

## REST and ServiceNow Table API paging

A REST source that returns pages needs a loop. The clean shape is a `FetchPage` function
plus `List.Generate` that stops as soon as a page comes back short. This example is a
ServiceNow Table API pull, but the shape fits any offset or cursor paged API.

```m
let
  BaseUrl  = "https://yourinstance.service-now.com",
  RelPath  = "api/now/table/incident",
  PageSize = 5000,      // keep pages modest so the source can build them inside its limits
  MaxPages = 40,        // row ceiling = PageSize * MaxPages. Change both together.
  Fields   = "number,sys_id,priority,opened_at,short_description,assignment_group",

  FullQuery = "sys_created_on>=javascript:gs.dateGenerate('2025-01-01','00:00:00')"
            & "^ORDERBYsys_id",   // a stable order key makes offset paging deterministic

  FetchPage = (offset as number) as table =>
    let
      Raw = Web.Contents(BaseUrl, [
        RelativePath = RelPath,
        Timeout      = #duration(0, 0, 10, 0),   // fail a stalled call fast, do not hang
        Query = [
          sysparm_display_value          = "true",
          sysparm_exclude_reference_link = "true",
          sysparm_fields                 = Fields,
          sysparm_limit                  = Text.From(PageSize),
          sysparm_offset                 = Text.From(offset),
          sysparm_query                  = FullQuery
        ]
      ]),
      Rows = Json.Document(Raw)[result],
      Tbl  = Table.FromList(Rows, Splitter.SplitByNothing(), {"Record"})
    in
      Tbl,

  Pages = List.Generate(
    () => [Offset = 0, Data = FetchPage(0)],
    (s) => Table.RowCount(s[Data]) > 0 and s[Offset] < MaxPages * PageSize,
    (s) => [ Offset = s[Offset] + PageSize,
             Data   = if Table.RowCount(s[Data]) < PageSize then #table({}, {}) else FetchPage(s[Offset] + PageSize) ],
    (s) => s[Data]
  ),

  Combined = Table.Combine(Pages)
in
  Combined
```

Key points:
- Use a static `BaseUrl` plus `RelativePath` and `Query`. This lets the Service bind
  credentials to the base URL. Building one long dynamic URL string breaks credential
  binding and refresh in the Service.
- Order by a stable key so paging does not skip or repeat rows.
- Pick a page size the source can assemble inside its own transaction limit. A very large
  page with expanded display or reference values can be cancelled server side, which reaches
  Power BI as "the operation was cancelled" and "the exception was raised by the IDbCommand
  interface". If you see that, lower the page size and keep the ceiling by raising max pages.
- Add `Timeout` so one stuck request fails in minutes instead of hanging toward the 2 hour
  refresh cap.
- ServiceNow with `sysparm_display_value = "true"` resolves each reference field to text.
  That is convenient but expensive per row. It is often the reason a page is slow.

## Reading an Excel file on SharePoint

Read the file directly. Do not enumerate the site.

```m
// GOOD: direct file read, fast
let
  Source = Excel.Workbook(
    Web.Contents("https://yourtenant.sharepoint.com/sites/YourSite/Shared Documents/Folder/File.xlsx"),
    null, true),
  Table1 = Source{[Item = "TableName", Kind = "Table"]}[Data]
in
  Table1
```

```m
// BAD for a single file: SharePoint.Files crawls every file in the whole site first,
// which can run for many minutes and cause a multi hour refresh.
let
  Source = SharePoint.Files("https://yourtenant.sharepoint.com/sites/YourSite", [ApiVersion = 15]),
  File   = Source{[Name = "File.xlsx"]}[Content]
in
  File
```

To get the exact direct URL, open the file location in the browser and use the path, or in
the file details pane copy the Path field. Avoid the share link with the `?e=` parameter, it
is not a clean path.

## Which method to use

Default to the direct file read. When you know where the file lives, point at its exact URL.
Most files stay put, so a fixed path keeps working and the refresh stays fast. This is the
right choice almost every time.

Use `SharePoint.Files` (the whole site crawl) only when one of these is true:
- The file is expected to move or get renamed, so a fixed path would break.
- You cannot get or keep the exact path, for example you are not in touch with the file owner
  to confirm where it lives.

Do not use the SharePoint REST API for a normal file read:

```m
// AVOID: REST GetFileById. The file id survives a move, but the credential test is fragile
// and often fails with a 400 on the data source setup.
Web.Contents("https://yourtenant.sharepoint.com/sites/Site",
  [RelativePath = "_api/web/GetFileById('<file-id>')/$value"])
```

If you genuinely need a path that survives a move, weigh that one trade off against the setup
pain before choosing it.

## Authentication notes (Pro)

- ServiceNow REST: Basic (user and password) or OAuth. Set it once in Desktop, and again in
  the Service under the dataset's data source credentials.
- SharePoint and SharePoint files and Excel on SharePoint: Organizational account (OAuth).
- Set privacy levels consistently. When two sources are combined in one query, mismatched
  privacy levels throw a Formula.Firewall error. For a single tenant, Organizational on all
  sources is usually right, and it does not cause the "operation cancelled" timeout error.

## A clean staging query

Keep the raw pull in its own query (a staging query, load disabled), do the reshape there,
then let the model tables build from it. But remember the duplication rule in
`folding-and-duplication.md`: if several loaded tables reference the same staging query, it
runs several times. On Pro, the fix is to reduce how many loaded tables re-derive from the
same expensive pull, not to add a Gen1 dataflow.
