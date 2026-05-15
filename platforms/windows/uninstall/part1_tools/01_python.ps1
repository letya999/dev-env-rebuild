#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "Python Uninstallation"
WingetUninstallById "Python.Python.3.14" -DryRun:$DryRun
WingetUninstallById "Python.Python.3.13" -DryRun:$DryRun
WingetUninstallById "Python.Python.3.12" -DryRun:$DryRun
WingetUninstallById "Python.Launcher" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\Programs\Python" -DryRun:$DryRun
Remove-PathSafe "$env:APPDATA\Python" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\pip" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.cache\pip" -DryRun:$DryRun
