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

## The key gotcha: you cannot change a partition type by editing TMDL

You cannot convert an existing table from an import (M) partition to a calculated (DAX)
partition, or the other way, by editing the TMDL. Power BI validates the partition type on open
and rejects the whole project with this error:

```text
Changing the partition type from or to PartitionType.Calculated is not allowed
```

The error code is `PFE_TM_DDL_CHANGED_PARTITION_FROM_OR_TO_CALC`. The partition type is part of
the table identity, so swapping an `= m` partition for an `= calculated` DAX partition on an
existing table is not a supported edit.

The supported path is heavy. Create the calculated table fresh in Desktop with New table and a
DAX expression. Then move the relationships, measures, and any dependent visuals onto the new
table, and delete the old one. That is a lot of manual rework, so it is usually not worth doing
just to shave refresh time. If refresh speed is the goal, compute the column or table upstream in
M or at the source instead. See `powerbi-data-and-refresh` and the calculated columns note in
`guidelines/pro-vs-premium-facts.md`.

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
