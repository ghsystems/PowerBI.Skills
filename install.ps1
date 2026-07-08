# install.ps1
# Links every skill in this repo into your personal Claude Code skills folder so
# Claude discovers them in any project. Re-run after a git pull to pick up changes.
#
# Symlinks need either Windows Developer Mode turned on, or an elevated (admin) shell.
# If a symlink cannot be made, the script falls back to a copy and tells you, in which
# case you must re-run install.ps1 after each pull.

$ErrorActionPreference = "Stop"
$repoSkills = Join-Path $PSScriptRoot "skills"
$dest = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

foreach ($skill in Get-ChildItem -Path $repoSkills -Directory) {
    $link = Join-Path $dest $skill.Name

    if (Test-Path $link) {
        $item = Get-Item $link -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $item.Delete()
        }
        else {
            Remove-Item -Recurse -Force $link
        }
    }

    try {
        New-Item -ItemType SymbolicLink -Path $link -Target $skill.FullName | Out-Null
        Write-Output "linked  $($skill.Name)"
    }
    catch {
        Copy-Item -Recurse -Force -Path $skill.FullName -Destination $link
        Write-Output "copied  $($skill.Name)  (symlink failed, used a copy - re-run after pulls)"
    }
}

Write-Output ""
Write-Output "Done. Restart Claude Code or run /reload-skills to load the skills."
