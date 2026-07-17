# AGENTS.md

Operating rules for this repo, for any coding agent (Claude Code, Codex, Cursor) and any
human editing it. This file is committed on purpose, because the repo is the instructions.

## What this repo is

A pack of agent skills plus shared guidelines for building Power BI models and reports. This
repo is where they are authored, versioned, and evolved.

The skills follow the Agent Skills standard, so they load in Claude Code (as a plugin, see
README.md), and in Codex and Cursor (from `~/.agents/skills/`, see README.md). Each skill
auto triggers on its own Power BI work.

## The one constant: Power BI Pro only

Every skill and guideline assumes Power BI Pro. No Fabric, no Premium, no Premium Per User,
only Dataflow Gen1. When you add or change content, keep this lens. If something needs
Premium or Fabric, say so plainly and give the Pro friendly alternative. The verified limits
live in `skills/powerbi-project-and-tools/references/pro-vs-premium-facts.md`. Trust that
file over memory or old blog posts, and re-verify against Microsoft Learn about once a year.

## Writing rules (apply to every file here)

- Plain engineer voice. Short direct sentences. Explain the why, not marketing filler.
- Never use an em dash or an en dash. Use commas, periods, or parentheses.
- Never use a semicolon outside a fenced code block. Split into two sentences.
- No real company name. Use "ABC Company". No real people names, use a role. Reza may be
  named. Use placeholder hosts like `yourtenant.sharepoint.com` and
  `yourinstance.service-now.com`. No secrets, ever.

## How the skills are structured

- One folder per skill under `skills/`, each with a `SKILL.md` and a `references/` folder.
- `SKILL.md` has YAML frontmatter with two keys, `name` (matching the folder name) and
  `description`. The description is the trigger, so make it pushy: say what the skill does
  and when to use it, packed with trigger phrases and synonyms. Keep it under 1024
  characters.
- Keep `SKILL.md` short, roughly under 150 lines: when to use, a short workflow, rules of
  thumb, and pointers. Put the depth in `references/`.
- Every skill folder is self contained. Never reference a path outside the skill folder.
  Shared facts live in the `references/` of the skill that owns them
  (`pro-vs-premium-facts.md` in `powerbi-project-and-tools`, `design-principles.md` and
  `house-default-theme.json` in `powerbi-report-design`), and other skills point at them by
  skill name, not by path.
- `guidelines/sources.md` at the repo root is authoring material for maintainers, not loaded
  by the skills.

## Adding or updating a skill

1. Create or edit `skills/<name>/SKILL.md` and its `references/`. The folder name must match
   the `name` in the frontmatter.
2. Follow the writing rules above and keep the Pro lens.
3. A brand new skill folder needs no manifest change, the `skills` path in
   `.claude-plugin/plugin.json` already exposes every folder under `skills/`. Bump the
   `version` in plugin.json so installed copies pick it up on the next `/plugin update`.
4. Make the change on a branch and open a pull request, using the workflow below.

## Daily changes via pull request

Make each change on a branch and open a pull request. Do not commit straight to main.

```powershell
git checkout -b my-change
# make your edits
git add -A
git commit -m "what changed"
git push -u origin my-change
gh pr create
```

Merge on GitHub after review.

## Verify before committing

- No em or en dashes and no stray semicolons: search the changed files.
- Each `SKILL.md` frontmatter `name` matches its folder name, and its description is under
  1024 characters.
- No path references leave a skill folder: search `skills/` for `guidelines/` and `../`,
  both must come back empty.
- `skills/powerbi-report-design/references/house-default-theme.json` still validates against
  the official report theme schema (from microsoft/powerbi-desktop-samples) if you changed it.
- No real company, people, hosts, or secrets slipped in.

## Keep it local

Do not put this repo in a OneDrive synced folder. Git plus OneDrive can corrupt the repo.
