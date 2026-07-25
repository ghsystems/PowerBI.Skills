# Power BI documentation repo playbook

The full process for turning a finished Power BI model into a redacted, shareable git repo.
Apply the `work-project-setup` skill throughout for the privacy and writing rules. Plain
engineer voice, no em or en dashes, no semicolons outside code.

## Repository structure

```
knowledgebase/
  00_overview.md
  01_data_flow_and_lineage.md
  02_data_sources.md
  03_<cross_cutting_topic>.md
  ...
  0N_data_model_relationships.md
  0N_measures_catalog.md
  reference/                 the verbatim M and DAX, one file per layer
    01_source.md
    02_staging.md
    03_transform.md
    04_facts.md
    05_dimensions_and_calculated.md
    06_measures.md
README.md                    the showcase front door
.gitignore
```

One numbered knowledgebase doc per topic. The `reference/` folder holds the real code
(redacted) so a reader can see exactly how each layer works.

## The .gitignore (write this before the first commit)

```
# OS junk
.DS_Store
Thumbs.db
desktop.ini

# Editor and IDE
.vs/
*.suo
*.user

# Power BI binaries and the raw project export (real, unredacted data)
*.pbix
*.pbip
*.pbit
*.SemanticModel/
*.Report/

# Local only working files, never pushed
CLAUDE.md
00_PROJECT_SETUP.md
00_LOCAL_REDACTION_MAP.md
```

Never commit the pbix, pbip, or the exported model folders. They hold the real, unredacted
data and code.

## Daily changes via pull request

After the first push, make each change on a branch and open a pull request. Do not commit
straight to main. Merge on GitHub after review.

```powershell
git checkout -b my-change
# make your edits
git add -A
git commit -m "what changed"
git push -u origin my-change
gh pr create
```

## Redaction checklist (where Power BI hides real data)

Power BI models bury real identifiers in several places. Check all of them.

- Company name. In host names, and as literal display values inside logic, for example
  `if [Company] = "Real Co"` in M or `IF ( company = "Real Co", ... )` in DAX. Replace with
  an alias like "ABC Company".
- Hosts and tenant URLs. ServiceNow instance hosts, SharePoint site URLs, and personal
  OneDrive paths like `https://yourtenant-my.sharepoint.com/personal/<user>`. Replace with
  placeholder hosts.
- People. Hardcoded rosters in dimension tables, owners named in M filters like
  `each [Owner] <> "Real Name"`, owners named in DAX like `IF ( owner = "Real Name", ... )`,
  and DAX variable names built from a first name like `VAR RealNameCap`, which must be
  renamed too. Replace names with roles or generic labels.
- Clients and customers. In assignment group labels and in table values. Use Client A,
  Client B.
- ServiceNow sys_id GUIDs and tenant identifiers. Replace with readable placeholders like
  `<assignment_group_sid_A>`.
- Secrets. Passwords, tokens, keys, connection strings. Never commit these. Flag and remove.

Keep the real to fake mapping only in a git ignored decoder, `00_LOCAL_REDACTION_MAP.md`.
After writing, verify nothing slipped through, for example
`grep -rniE "\bRealName\b|\bRealCompany\b" .` should return nothing.

## README as a showcase

The README is the front door. Structure it as:

- Title and one paragraph on what the model does.
- The goal, framed so a reader sees why the problem was hard.
- An architecture diagram (a mermaid `flowchart`).
- A data model diagram (a mermaid ER diagram).
- The hard parts. One short subsection per tricky thing, each linking to its deep dive doc
  in the knowledgebase.
- Repository layout, and the tech used.
- One quiet closing line that identifiers are anonymized.

Do not add a "what is and is not in the repo" section or a long redaction explainer. Let the
work speak.

## Setting up and pushing the repo (Windows)

Run git on the Windows machine, not from a sandbox mount. Write the `.gitignore` first so the
binaries and local files never get staged.

```powershell
cd C:\Users\<you>\source\repos\<ProjectName>
git init -b main
git config user.name  "Your Name"
git config user.email "you@company.com"
git remote add origin https://github.com/<account>/<ProjectName>.git
git add -A
git status               # eyeball that no pbix, pbip, or export folder is staged
git commit -m "Initial commit: redacted <model> knowledgebase"
git push -u origin main
```

Create the GitHub repo as Private first. After this first push, make each change on a branch
and open a pull request, then merge on GitHub after review. Never run `git init` twice in the
same folder.

## Gotchas

- Git plus OneDrive in one folder can corrupt the repo. Keep the repo local, outside any
  OneDrive synced path.
- The TMDL is the source of truth. Trust it over any older summary or diagram.
- "Save as pbip" in Power BI switches the active file to the pbip. Be aware which file you
  are now editing.
