#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "Docker WSL дистрибутивы"
Run "wsl --unregister docker-desktop/docker-desktop-data" {
    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
        wsl --unregister docker-desktop 2>$null
        wsl --unregister docker-desktop-data 2>$null
    } else {
        Write-Host "  wsl.exe not found, skipped" -ForegroundColor Gray
    }
} -DryRun:$DryRun

Step "Docker Uninstallation"
Run "Docker Desktop official CLI uninstaller" {
    $installer = "C:\Program Files\Docker\Docker\Docker Desktop Installer.exe"
    if (Test-Path -LiteralPath $installer) {
        Start-Process -FilePath $installer -ArgumentList "uninstall" -Wait
    } else {
        Write-Host "  Docker Desktop Installer.exe not found, skipped" -ForegroundColor Gray
    }
} -DryRun:$DryRun
WingetUninstallById "Docker.DockerDesktop" -DryRun:$DryRun
Remove-PathSafe "$env:APPDATA\Docker" -DryRun:$DryRun
Remove-PathSafe "$env:APPDATA\Docker Desktop" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\Docker" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.docker" -DryRun:$DryRun
Remove-PathSafe "C:\ProgramData\Docker" -DryRun:$DryRun
Remove-PathSafe "C:\ProgramData\DockerDesktop" -DryRun:$DryRun
Remove-PathSafe "C:\Program Files\Docker" -DryRun:$DryRun
