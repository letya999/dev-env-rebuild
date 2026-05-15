#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "Docker WSL дистрибутивы"
Run "wsl --unregister docker-desktop" {
    wsl --unregister docker-desktop 2>$null
} -DryRun:$DryRun
Run "wsl --unregister docker-desktop-data" {
    wsl --unregister docker-desktop-data 2>$null
} -DryRun:$DryRun

Step "Docker Uninstallation"
WingetUninstall "Docker Desktop" -DryRun:$DryRun
Remove-PathSafe "$env:APPDATA\Docker" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\Docker" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.docker" -DryRun:$DryRun
Remove-PathSafe "C:\ProgramData\Docker" -DryRun:$DryRun
Remove-PathSafe "C:\ProgramData\DockerDesktop" -DryRun:$DryRun
Remove-PathSafe "C:\Program Files\Docker" -DryRun:$DryRun
