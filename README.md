# PowerBI.Skills

A Claude Code plugin: seven skills plus research backed guidelines for building Power BI models
and reports. Power BI Pro only, no Fabric, no Premium. The single source of truth for how we
build Power BI.

## Install

This is a Claude Code plugin. It works anywhere you run Claude Code: the CLI, the VS Code or
JetBrains extension, and the desktop app. It is not part of Cursor's own AI, but the terminal
commands below run in any terminal, including the one inside Cursor or VS Code.

The repo is public, so anyone can install it on any Claude plan, no enterprise needed.

Terminal, the reliable way that works in every setup:

```
claude plugin marketplace add MrezaGHS/PowerBI.Skills
claude plugin install powerbi-skills@powerbi-skills
```

Run those from a project folder, not your home directory. A git safety check can otherwise
refuse to clone. Then `claude plugin list` should show `powerbi-skills` as enabled. Restart
your Claude Code session so the skills load.

Inside a Claude Code chat session, the interactive form also works:

```
/plugin marketplace add MrezaGHS/PowerBI.Skills
/plugin install powerbi-skills@powerbi-skills
```

Enter one value per prompt in the dialog. The `/plugin` command is not available in every
surface (the desktop app hides it), so use the terminal commands above if you do not see it.

Once installed, all seven skills auto trigger on their matching Power BI work. Update later
with `claude plugin update powerbi-skills` (or `/plugin update` in chat).

## Why this exists

Building a Power BI model well takes a lot of scattered knowledge: how to pull data without a
slow refresh, how to model a star schema, how to write DAX that is correct and fast, how to
design a report that is readable and accessible, and which limits are Pro versus Premium. This
repo captures that once, as skills Claude loads on demand, so it does not have to be re-learned
per project.

## The skills

| Skill | What it does | Example trigger |
| --- | --- | --- |
| `powerbi-data-and-refresh` | The data layer. Power Query M, connecting to REST or ServiceNow or SharePoint, paging, query folding, and fixing slow or failing refreshes. | "my refresh keeps failing", "connect power bi to this api" |
| `powerbi-modeling` | Star schema, dimensions vs facts, grain, relationships, and naming including the `_Measures` table. | "how should I model this", "star schema" |
| `powerbi-dax` | Measures vs calculated columns and tables, context, and reusable DAX patterns. | "write a year over year measure", "running total" |
| `powerbi-pbir-builder` | Write real report pages and visuals into an existing PBIP by authoring PBIR JSON directly. | "add a page to the report", "build a KPI card in code" |
| `powerbi-report-design` | Layout, chart selection, color and theme JSON, fonts, slicers, navigation, and accessibility. | "design this report", "pick colors", "which chart" |
| `powerbi-project-and-tools` | The pbip and TMDL project format, safe hand editing, free external tools, and the Pro vs Premium boundary. | "edit the TMDL", "what needs Premium", "Tabular Editor" |
| `powerbi-doc-repo` | Document a finished model into a redacted, shareable git repo. | "document this pbi", "I have another PBI I want to do the same with" |

## Shared guidelines

The `guidelines/` folder holds reference material the skills lean on:

- `pro-vs-premium-facts.md`, the verified license limits and what is Premium or Fabric only.
- `design-principles.md`, the situational report design rules of thumb.
- `house-default-theme.json`, an accessible Power BI theme (Okabe-Ito colorblind safe palette,
  Segoe UI, a blue to orange diverging scale) to start every report from.
- `sources.md`, the curated Pro safe source list per topic.

## Authoring changes

To add or change a skill, edit under `skills/` on a branch and open a pull request. Bump the
`version` in `.claude-plugin/plugin.json` so installed copies pick it up on the next
`/plugin update`. See CLAUDE.md for the writing rules and the Pro only lens.

## Keep it local

Do not put this repo inside a OneDrive synced folder. Git plus OneDrive in one folder can
corrupt the repo.

## Sources

See `guidelines/sources.md`. The anchors are Microsoft Learn, SQLBI and DAX.guide and DAX
Patterns, Chris Webb's blog, Kurt Buhler and Data Goblins, Zebra BI and IBCS, and the
colorblind safe palettes from Okabe-Ito and ColorBrewer.
