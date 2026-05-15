#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "Git & GitHub CLI Uninstallation"
WingetUninstallById "Git.Git" -DryRun:$DryRun
WingetUninstallById "GitHub.cli" -DryRun:$DryRun
WingetUninstallByName "Git Credential Manager" -DryRun:$DryRun
Remove-PathSafe "C:\Program Files\Git" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\GitHub CLI" -DryRun:$DryRun
Write-Host "Git user config and credential stores are preserved: ~/.gitconfig, ~/.git-credentials, GitCredentialManager data." -ForegroundColor Gray
