#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "WSL Uninstallation"
Run "wsl --shutdown" {
    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) { wsl --shutdown 2>$null }
    else { Write-Host "  wsl.exe not found, skipped" -ForegroundColor Gray }
} -DryRun:$DryRun
Run "wsl --unregister all" {
    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
        Write-Host "  wsl.exe not found, skipped" -ForegroundColor Gray
        return
    }
    $distros = wsl --list --quiet 2>$null
    foreach ($distro in $distros) {
        $clean = ($distro -replace "`0", "").Trim()
        if ($clean) { wsl --unregister $clean }
    }
} -DryRun:$DryRun
WingetUninstallById "Microsoft.WSL" -DryRun:$DryRun
Run "Disable Features" {
    dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
    dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart
} -DryRun:$DryRun
