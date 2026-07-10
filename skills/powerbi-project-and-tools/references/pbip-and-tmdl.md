# PBIP and TMDL

## What the PBIP format is

A `.pbix` is one binary file. Report and model are zipped together and you cannot diff it, merge
it, or edit it in a text editor.

A Power BI Project (PBIP) is the same content saved as a folder of plain text files instead. The
model and report metadata become human readable files in a simple folder tree. That makes them
diffable in git, mergeable, and editable in VS Code or any text editor. PBIP is still a preview
feature in Power BI Desktop. Turn it on under File, Options and settings, Options, Preview
features, then check the pbip save option and the option to store the semantic model using TMDL.

You save a pbip with File, Save as, and pick the Power BI Project type. You can convert a pbix
to a pbip and back through Save as in Desktop.

## The folder layout

A pbip for a project called `ABCSales` looks like this. Names are illustrative.

```text
ABCSales.pbip                      pointer file, opening it opens the report and model
ABCSales.SemanticModel/            the model
  definition.pbism                 model definition pointer and format version (required)
  definition/                      the TMDL model, THIS is the source of truth
    database.tmdl                  database name and compatibility level
    model.tmdl                     model level settings, default culture, and table order refs
    relationships.tmdl             every relationship in the model, one file
    expressions.tmdl               every shared expression, one file (see below)
    tables/
      Fact_Sales.tmdl              one file per table: its columns, measures, hierarchies, and
      Dim_Date.tmdl                the partition that holds the table's M query
      Dim_Customer.tmdl
    cultures/                      one file per culture, present only with translations
    roles/                         one file per row level security role, present only with RLS
    perspectives/                  one file per perspective
  .pbi/                            local only, git ignored: localSettings.json and cache.abf
  diagramLayout.json               model diagram positions, do not hand edit
  .platform
ABCSales.Report/                   the report
  definition.pbir                  report pointer
  definition/                      report pages and visuals
.gitignore                         created by Desktop, ignores .pbi\cache.abf and localSettings.json
```

What goes where in the model:

- A regular loaded table's M query lives inside that table's file, in its `partition` block, under
  `tables\<Table>.tmdl`.
- `expressions.tmdl` holds the model level shared expressions. That means parameters, and any
  query that is load disabled or shared as a staging query that other queries reference. These
  are stored once at the model level, not inside a table.
- `relationships.tmdl` holds all relationships, so a relationship change is one file to review.
- Columns, hierarchies, and partitions of a table all live inside that one table file, not in
  separate files.

## TMDL is the source of truth

TMDL (Tabular Model Definition Language) is a text format for the model, similar in feel to
YAML. Indentation with a single tab per level denotes the object tree. The files in the
`definition\` folder are what defines the model. The `cache.abf` in `.pbi\` is only a cached copy
of the data from the last edit, and it is git ignored. When you fix the model, you edit the
`.tmdl` files.

## Safe hand editing rules

1. Back up first. Copy the whole project folder, or commit to git, so you can revert cleanly.
2. Close Power BI Desktop before you edit. Desktop keeps the model in memory and rewrites the
   TMDL files from memory when it saves or applies. Any edit you make while it is open will be
   overwritten. Desktop also does not watch the files, so it only reads your edits on a fresh
   open. Edit, save, then open Desktop.
3. Make minimal, targeted edits. One property or one measure at a time, then verify. A small diff
   is easy to review and easy to revert.
4. Preserve line endings and encoding. Desktop writes CRLF and UTF-8 without BOM. A tool that
   rewrites the file as LF makes the whole file look changed in git and can confuse a merge. Set
   git `autocrlf` so line endings stay consistent.
5. Respect the indentation. TMDL is whitespace significant. One tab per level. A stray space, or
   a tab converted to spaces, breaks the parse.
6. Reopen in Desktop to verify. If an edit is invalid, Desktop refuses to open the project and
   points at the file and location of the error.

## Converting a table between M and calculated (DAX) by editing TMDL

You can flip a table between an import (M) partition and a calculated (DAX) partition by editing
TMDL, but not while Desktop is holding the old model in memory. If you just swap the partition and
reopen, Power BI tries to morph the cached model into the new one, and that specific change is not a
legal in place edit. It rejects the whole project on open:

```text
Changing the partition type from or to PartitionType.Calculated is not allowed
```

The error code is `PFE_TM_DDL_CHANGED_PARTITION_FROM_OR_TO_CALC`. The trigger is the diff against the
cached data in `.pbi\cache.abf`, not the TMDL itself.

The fix is to make Desktop build the model fresh from the TMDL instead of morphing the cache. This is
the same cold load path a fresh git clone takes, since `cache.abf` is git ignored and absent on a
clone.

1. Close Desktop. Back up the pbip folder first.
2. Edit the table's partition in its `.tmdl` file. For a calculated table use `partition <Table> =
   calculated`, `mode: import`, and a `source =` DAX expression. Give each stored column
   `isNameInferred` and `sourceColumn: [Name]` matching a column the DAX returns. Keep the existing
   table and column `lineageTag` values so relationships, measures, and visuals stay bound.
3. Delete `.pbi\cache.abf` (it is git ignored and only holds the last loaded data). Keep
   `localSettings.json`, it holds the publish target binding.
4. Reopen the pbip. With no cache, Desktop creates the database fresh from the TMDL, so the partition
   type is set, not changed, and there is no error. The report opens with empty data.
5. Refresh to rebuild the data, validate the numbers, then publish.

Why bother. This is the light way to kill refresh fan out. A derivative table (one that only reshapes
or rolls up tables already in the model) as an M partition re-runs its whole upstream pull chain on
every refresh, which is a common cause of a slow or failing Pro refresh. As a calculated table it
computes in memory from data already loaded, with no extra source calls. See
`powerbi-data-and-refresh/references/folding-and-duplication.md`.

Cautions. A calculated table still recomputes on every refresh and does not fold, so only convert
derivative tables, never the source pulls themselves. If you would rather not touch TMDL, the GUI
path also works: create a New table in Desktop with the DAX, move relationships and measures onto it,
and delete the old one.

## Calculated table columns keep source lineage

When a calculated table column is a bare reference to another table's column, for example
`"Sprint", src[Sprint]` inside SELECTCOLUMNS, the engine keeps that column's lineage back to the
source column. It then will not accept your `sourceColumn: [Sprint]` declaration on the new table,
the declared column drops, and any relationship built on it fails to load:

```text
Relationship '...' uses an invalid column ID 300
```

error code `PFE_TM_RELATIONSHIP_END_COLUMN_INVALID`.

The fix is to make every passthrough column an expression, so it carries no lineage. Wrap the bare
reference in `IF ( TRUE (), src[Sprint] )`. Same value and type, but now it is a fresh computed
column that matches your `sourceColumn` declaration, and relationships bind. Do any aggregation
(CALCULATE or SUMMARIZE roll ups) in an inner ADDCOLUMNS where the row context is intact, then wrap
the result in an outer SELECTCOLUMNS that re-emits each column with the `IF ( TRUE (), ... )` trick.
That keeps the aggregation correct and leaves every output column lineage free.

## Other traps

- OneDrive. Keep the pbip repo out of a OneDrive or SharePoint synced folder. A git repo inside a
  synced folder is a known way to corrupt the repo, because OneDrive and git both churn the many
  small files under `.git`. Desktop also cannot save a pbip straight to OneDrive or SharePoint,
  and saving into a locally synced folder can make the save fail. Keep the working repo on a plain
  local path and push to the remote with git.
- Windows path length. A pbip stores many nested files. The default Windows path limit is 260
  characters. Long table names in a deep folder can push a file path past the limit and fail the
  save. Keep the root folder path short.
- Restart to see external edits. Desktop does not watch the files. After you edit TMDL in VS
  Code, close and reopen Desktop to load the change.
- Do not hand edit `diagramLayout.json` or the report layout files during preview. Those files
  are not documented for external editing.

## See also

- `references/external-tools.md`: the tools that read and write these files.
- `references/licensing-cheatsheet.md`: the Pro versus Premium boundary.
- `powerbi-doc-repo`: turning a TMDL export into a documented, redacted repo.
