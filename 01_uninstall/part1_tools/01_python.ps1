#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "Python Uninstallation"
WingetUninstall "Python" -DryRun:$DryRun
WingetUninstall "Python Launcher" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\Programs\Python" -DryRun:$DryRun
Remove-PathSafe "$env:APPDATA\Python" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\pip" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.cache\pip" -DryRun:$DryRun
