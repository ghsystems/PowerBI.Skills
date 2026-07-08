param([Parameter(Mandatory = $true)][string]$Message)
Set-Location -Path $PSScriptRoot
git add -A
git status --short
git commit -m $Message
git push
