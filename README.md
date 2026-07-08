# PowerBI-Skills

A personal pack of Claude Code skills plus research backed guidelines for building Power BI
models and reports. This is the single source of truth for how we build Power BI. Point
Claude at these skills in any project and it builds models the same, correct, well designed
way every time.

Everything here assumes Power BI Pro only. No Fabric, no Premium, only Dataflow Gen1. The
guidance is written for that reality, including the traps that come with it.

## Why this exists

Building a Power BI model well takes a lot of scattered knowledge: how to pull data without
a slow refresh, how to model a star schema, how to write DAX that is correct and fast, how
to design a report that is readable and accessible, and which limits are Pro versus Premium.
This repo captures that once, as skills Claude loads on demand, so it does not have to be
re-learned per project.

## The skills

| Skill | What it does | Example trigger |
| --- | --- | --- |
| `powerbi-data-and-refresh` | The data layer. Power Query M, connecting to REST or ServiceNow or SharePoint, paging, query folding, and fixing slow or failing refreshes. | "my refresh keeps failing", "connect power bi to this api" |
| `powerbi-modeling` | Star schema, dimensions vs facts, grain, relationships, and naming including the `_Measures` table. | "how should I model this", "star schema" |
| `powerbi-dax` | Measures vs calculated columns and tables, context, and reusable DAX patterns. | "write a year over year measure", "running total" |
| `powerbi-report-design` | Layout, chart selection, color and theme JSON, fonts, slicers, navigation, and accessibility. | "design this report", "pick colors", "which chart" |
| `powerbi-project-and-tools` | The pbip and TMDL project format, safe hand editing, free external tools, and the Pro vs Premium boundary. | "edit the TMDL", "what needs Premium", "Tabular Editor" |
| `powerbi-doc-repo` | Document a finished model into a redacted, shareable git repo. | "document this pbi", "I have another PBI I want to do the same with" |

## Shared guidelines

The `guidelines/` folder holds reference material the skills lean on:

- `pro-vs-premium-facts.md`, the verified license limits and what is Premium or Fabric only.
- `design-principles.md`, the situational report design rules of thumb.
- `house-default-theme.json`, an accessible Power BI theme (Okabe-Ito colorblind safe
  palette, Segoe UI, a blue to orange diverging scale) to start every report from.
- `sources.md`, the curated Pro safe source list per topic.

## Install

The skills load once they live in your personal Claude skills folder.

```powershell
git clone https://github.com/MrezaGHS/PowerBI-Skills.git C:\Users\<you>\source\repos\PowerBI-Skills
cd C:\Users\<you>\source\repos\PowerBI-Skills
.\install.ps1
```

`install.ps1` links each skill in `skills/` into `~/.claude/skills`. Symlinks need Windows
Developer Mode on, or an elevated shell. If a symlink cannot be made, the script copies the
folder instead and tells you, in which case re-run `install.ps1` after each `git pull`.

Then restart Claude Code or run `/reload-skills`.

## Update

```powershell
cd C:\Users\<you>\source\repos\PowerBI-Skills
git pull
.\install.ps1   # only needed if install.ps1 had to copy instead of symlink
```

## Keep it local

Do not put this repo inside a OneDrive synced folder. Git plus OneDrive in one folder can
corrupt the repo.

## Sources

See `guidelines/sources.md`. The anchors are Microsoft Learn, SQLBI and DAX.guide and DAX
Patterns, Chris Webb's blog, Kurt Buhler and Data Goblins, Zebra BI and IBCS, and the
colorblind safe palettes from Okabe-Ito and ColorBrewer.
