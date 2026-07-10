---
name: powerbi-skills-repo
description: >-
  Points to the PowerBI.Skills repo, the single source of truth for building, fixing, and
  designing Power BI, Pro license only, no Fabric or Premium. Use whenever the task touches
  Power BI in any way: a pbix or pbip file, a semantic model, Power Query or M, connecting
  to a REST API or ServiceNow or SharePoint, a slow or failing refresh, star schema, facts
  and dimensions, relationships, a `_Measures` table, DAX (a measure, a calculated column,
  time intelligence, a running total, ranking, TREATAS), report design (layout, chart
  choice, color, a theme JSON, fonts, slicers, bookmarks, navigation, accessibility),
  writing PBIR JSON to add a page or visual in code, editing TMDL, Tabular Editor, DAX
  Studio, Bravo, Measure Killer, or documenting a finished model into a shareable repo.
  Trigger on any Power BI or Fabric-adjacent phrase even without the words "Power BI",
  for example "star schema", "DAX measure", "refresh keeps failing", "connect to
  ServiceNow", "pick a chart", "theme JSON", "TMDL", "PBIR". This skill itself only
  points to the repo, read the repo before doing the actual work.
---

# Power BI: read the PowerBI.Skills repo first

Do not rely on general knowledge or memory for Power BI work. This repo is the single
source of truth for how Power BI gets built, kept current, and reviewed:

```
C:\Users\rseifollahi\source\repos\PowerBI-Skills
```

## How to use this

1. List the folders under `skills\` in that repo. Each one is a focused skill with its own
   `SKILL.md`. There may be more than were here when this pointer was written, always check
   the live folder rather than assuming a fixed list.
2. Read the `SKILL.md` of whichever skill (or skills) matches the task.
3. Follow that skill's own pointers into its `references\` folder as needed.
4. Also check `guidelines\` in the repo root for shared facts that apply across skills: the
   verified Power BI Pro vs Premium limits, the situational report design principles, the
   house default theme JSON, and the curated source list.

## Rules that apply no matter which skill you land on

- Power BI Pro only. No Fabric, no Premium, no Premium Per User. If something needs one of
  those, the repo will say so, flag it to the user rather than assuming it is available.
- The repo is the single source of truth. If something here conflicts with a general
  assumption, trust the repo.
- This repo is the only Power BI skill installed in Claude on purpose. Every other Power BI
  skill lives only inside the repo and is read fresh each time, never copied elsewhere, so
  it is never stale.
