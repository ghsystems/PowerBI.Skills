# PowerBI.Skills

Eight task specific agent skills plus research backed guidelines for building Power BI models
and reports. Power BI Pro only, no Fabric, no Premium. The single source of truth for how we
build Power BI.

Much of the detail is harvested from real production models rather than from documentation, so
the patterns here are ones that have survived a Service refresh and a client review.

The skills follow the Agent Skills standard (a `SKILL.md` with `name` and `description`
frontmatter plus a `references/` folder), so the same skill folders work in Claude Code, Codex,
and Cursor. Each skill folder is self contained: copy it alone and nothing breaks.

## Install

### Claude Code

This repo is a Claude Code plugin. It works anywhere you run Claude Code: the CLI, the VS Code
or JetBrains extension, and the desktop app. The repo is public, so anyone can install it on
any Claude plan.

Terminal, the reliable way that works in every setup:

```
claude plugin marketplace add ghsystems/PowerBI.Skills
claude plugin install powerbi-skills@powerbi-skills
```

Run those from a project folder, not your home directory. A git safety check can otherwise
refuse to clone. Then `claude plugin list` should show `powerbi-skills` as enabled. Restart
your Claude Code session so the skills load.

Inside a Claude Code chat session, the interactive form also works:

```
/plugin marketplace add ghsystems/PowerBI.Skills
/plugin install powerbi-skills@powerbi-skills
```

The `/plugin` command is not available in every surface (the desktop app hides it), so use the
terminal commands above if you do not see it. Update later with
`claude plugin update powerbi-skills` (or `/plugin update` in chat).

### Codex and Cursor (one shared step)

Both Codex and Cursor read skills from `~/.agents/skills/`. Clone the repo and copy the skill
folders there once, and both tools pick them up.

PowerShell (Windows):

```
git clone https://github.com/ghsystems/PowerBI.Skills
Copy-Item -Recurse -Force PowerBI.Skills/skills/* ~/.agents/skills/
```

macOS or Linux:

```
git clone https://github.com/ghsystems/PowerBI.Skills
mkdir -p ~/.agents/skills && cp -R PowerBI.Skills/skills/* ~/.agents/skills/
```

To update: `git pull` in the clone, then run the copy again. Every skill folder is self
contained, so copying only the skills you want also works.

For project scoped use instead of user wide, copy the skill folders into the project's
`.agents/skills/` folder. Both tools discover that too.

### Native alternatives

- Codex: the `$skill-installer` skill can be prompted with this repo's URL to fetch skills.
- Cursor: Customize, Rules, Add Rule, Remote Rule (GitHub) accepts this repo's URL, and Cursor
  also discovers `.cursor/skills/`.

The clone and copy method above is the supported team path. Use these only if you prefer them.

## Why this exists

Building a Power BI model well takes a lot of scattered knowledge: how to pull data without a
slow refresh, how to model a star schema, how to write DAX that is correct and fast, how to
design a report that is readable and accessible, and which limits are Pro versus Premium. This
repo captures that once, as skills the agent loads on demand, so it does not have to be
re-learned per project.

## The skills

| Skill | What it does | Example trigger |
| --- | --- | --- |
| `powerbi-build-playbook` | The phase order for a whole build, the manual Desktop steps, and which skill owns which question. Start here. | "where do I start", "build a new power bi report", "create a pbip" |
| `powerbi-data-and-refresh` | The data layer. Power Query M, connecting to REST or ServiceNow or SharePoint, paging, query folding, and fixing slow or failing refreshes. | "my refresh keeps failing", "connect power bi to this api" |
| `powerbi-modeling` | Star schema, dimensions vs facts, grain, relationships, and naming including the `_Measures` table. | "how should I model this", "star schema" |
| `powerbi-dax` | Measures vs calculated columns and tables, context, and reusable DAX patterns. | "write a year over year measure", "running total" |
| `powerbi-pbir-builder` | Write real report pages and visuals into an existing PBIP by authoring PBIR JSON directly. | "add a page to the report", "build a KPI card in code" |
| `powerbi-report-design` | Layout, chart selection, color and theme JSON, fonts, slicers, navigation, and accessibility. | "design this report", "pick colors", "which chart" |
| `powerbi-project-and-tools` | The pbip and TMDL project format, safe hand editing, free external tools, and the Pro vs Premium boundary. | "edit the TMDL", "what needs Premium", "Tabular Editor" |
| `powerbi-doc-repo` | Document a finished model into a redacted, shareable git repo. | "document this pbi", "I have another PBI I want to do the same with" |

## Shared reference material

Shared facts live inside the skill that owns them, so every skill folder stays portable:

- `skills/powerbi-project-and-tools/references/pro-vs-premium-facts.md`, the verified license
  limits and what is Premium or Fabric only. Other skills point at it by skill name.
- `skills/powerbi-report-design/references/design-principles.md`, the situational report design
  rules of thumb.
- `skills/powerbi-report-design/references/house-default-theme.json`, an accessible Power BI
  theme (Okabe-Ito colorblind safe palette, Segoe UI, a blue to orange diverging scale) to
  start every report from.
- `guidelines/sources.md`, the curated Pro safe source list per topic. Authoring material for
  maintaining this repo, not loaded by the skills.

## Authoring changes

To add or change a skill, edit under `skills/` on a branch and open a pull request. Bump the
`version` in `.claude-plugin/plugin.json` so installed copies pick it up on the next
`/plugin update`. See AGENTS.md for the writing rules and the Pro only lens.

Before committing, run the check script. It enforces the writing rules, the file size caps, the
self containment rule, and redaction:

```
pwsh -File tools\check.ps1
```

## Keep it local

Do not put this repo inside a OneDrive synced folder. Git plus OneDrive in one folder can
corrupt the repo.

## Sources

See `guidelines/sources.md`. The anchors are Microsoft Learn, SQLBI and DAX.guide and DAX
Patterns, Chris Webb's blog, Kurt Buhler and Data Goblins, Zebra BI and IBCS, and the
colorblind safe palettes from Okabe-Ito and ColorBrewer.
