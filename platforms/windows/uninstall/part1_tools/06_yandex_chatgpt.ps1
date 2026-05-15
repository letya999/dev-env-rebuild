#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "Cloud & Other AI Tools Uninstallation"
WingetUninstall "ChatGPT" -DryRun:$DryRun
WingetUninstall "Yandex Cloud CLI" -DryRun:$DryRun

Remove-PathSafe "$env:USERPROFILE\yandex-cloud" -DryRun:$DryRun
Remove-PathSafe "$env:APPDATA\yc" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.config\yc" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\Programs\ChatGPT" -DryRun:$DryRun
Remove-PathSafe "$env:APPDATA\ChatGPT" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\ChatGPT" -DryRun:$DryRun
