#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "Git & GitHub CLI Uninstallation"
WingetUninstall "Git" -DryRun:$DryRun
WingetUninstall "Git Credential Manager" -DryRun:$DryRun
WingetUninstall "GitHub CLI" -DryRun:$DryRun
Remove-PathSafe "C:\Program Files\Git" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\GitCredentialManager" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\GitHub CLI" -DryRun:$DryRun
Run "Remove .gitconfig" { Remove-Item "$env:USERPROFILE\.gitconfig" -Force -ErrorAction SilentlyContinue } -DryRun:$DryRun
