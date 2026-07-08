# install.ps1
# Installs the single router skill (powerbi-skills-repo) into your personal Claude Code
# skills folder. That is the ONLY thing this repo puts into Claude on purpose. Every real
# Power BI skill lives only under skills\ in this repo, and the router skill tells Claude to
# read them straight from here whenever a Power BI task comes up, so there is never a stale
# copy to update. Re-run after a git pull, though usually nothing changes here, since only
# the router skill is installed, and its own content rarely changes.

$ErrorActionPreference = "Stop"
$routerName = "powerbi-skills-repo"
$source = Join-Path $PSScriptRoot $routerName
$dest = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$link = Join-Path $dest $routerName

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
    New-Item -ItemType SymbolicLink -Path $link -Target $source | Out-Null
    Write-Output "linked  $routerName"
}
catch {
    Copy-Item -Recurse -Force -Path $source -Destination $link
    Write-Output "copied  $routerName  (symlink failed, used a copy - re-run after editing this one file if it ever changes)"
}

Write-Output ""
Write-Output "Done. Restart Claude Code or run /reload-skills."
Write-Output "Only '$routerName' is installed in Claude. Every other Power BI skill lives only in this repo's skills\ folder and is read on demand."
