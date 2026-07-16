# CLAUDE.md

Operating rules for this repo. This file is committed on purpose, because the repo is the
instructions. That is different from the normal house rule that git ignores CLAUDE.md, and
the `.gitignore` here has a note saying so.

## What this repo is

A pack of Claude Code skills plus shared guidelines for building Power BI models and reports.
This repo is where they are authored, versioned, and evolved.

This repo is a Claude Code plugin. Installing it (see Install in README.md) registers every
skill under `skills/`, so each one auto triggers on its own Power BI work. The plugin manifest
lives in `.claude-plugin/`. There is no install script and no router skill anymore, Claude
Code loads the skills straight from the installed plugin. To share the pack, point a teammate
at this repo with the two plugin commands in README.md.

## The one constant: Power BI Pro only

Every skill and guideline assumes Power BI Pro. No Fabric, no Premium, no Premium Per User,
only Dataflow Gen1. When you add or change content, keep this lens. If something needs
Premium or Fabric, say so plainly and give the Pro friendly alternative. The verified limits
live in `guidelines/pro-vs-premium-facts.md`. Trust that file over memory or old blog posts,
and re-verify against Microsoft Learn about once a year.

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
  and when to use it, packed with trigger phrases and synonyms.
- Keep `SKILL.md` short, roughly under 150 lines: when to use, a short workflow, rules of
  thumb, and pointers. Put the depth in `references/`.
- Shared facts that many skills use live in `guidelines/`. Reference them by relative path,
  do not copy them into each skill.

## Adding or updating a skill

1. Create or edit `skills/<name>/SKILL.md` and its `references/`. The folder name must match
   the `name` in the frontmatter. Claude Code picks up any skill folder under `skills/`.
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
- Each `SKILL.md` frontmatter `name` matches its folder name.
- `guidelines/house-default-theme.json` still validates against the official report theme
  schema (from microsoft/powerbi-desktop-samples) if you changed it.
- No real company, people, hosts, or secrets slipped in.

## Keep it local

Do not put this repo in a OneDrive synced folder. Git plus OneDrive can corrupt the repo.
