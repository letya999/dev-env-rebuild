# Shared functions for uninstallation scripts
$ErrorActionPreference = "Continue"

function Step($Text) { Write-Host "`n=== $Text ===" -ForegroundColor Cyan }

function Run($Command, [scriptblock]$Action, [switch]$DryRun) {
    if ($DryRun) {
        Write-Host "DRY-RUN: $Command" -ForegroundColor Yellow
    } else {
        Write-Host "Action: $Command" -ForegroundColor Green
        try { & $Action } catch { Write-Host "Error: $_" -ForegroundColor Red }
    }
}

function Remove-PathSafe($Path, [switch]$DryRun) {
    # === CRITICAL SAFETY BOUNDARIES ===
    $protectedPaths = @(
        "C:\Users\User\a_projects",
        "C:\Users\User\.agents",
        "C:\Users\User\.ai_backup"
    )

    $normalizedTarget = $Path -replace '\\$', ''

    foreach ($protected in $protectedPaths) {
        # Check if target is inside protected (e.g., removing a_projects/node_modules)
        if ($normalizedTarget -like "$protected*") {
            Write-Host "BLOCKED (SAFETY): Cannot remove $Path as it is inside protected directory $protected" -ForegroundColor Red
            return
        }
        # Check if target is a parent of protected (e.g., removing C:\Users\User)
        if ($protected -like "$normalizedTarget*") {
            Write-Host "BLOCKED (SAFETY): Cannot remove $Path as it contains protected directory $protected" -ForegroundColor Red
            return
        }
    }

    Run "Remove: $Path" { 
        if (Test-Path $Path) {
            Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue 
        }
    } -DryRun:$DryRun
}

function WingetUninstall($Name, [switch]$DryRun) {
    Run "winget uninstall '$Name'" {
        winget uninstall --name $Name --silent --accept-source-agreements 2>$null
    } -DryRun:$DryRun
}

function Get-NpmPrefix {
    try {
        $prefix = (& npm config get prefix 2>$null)
        if ($prefix -and (Test-Path $prefix)) { return $prefix }
    } catch {}
    # fallbacks
    if (Test-Path "$env:USERPROFILE\.npm-global") { return "$env:USERPROFILE\.npm-global" }
    if (Test-Path "$env:APPDATA\npm") { return "$env:APPDATA\npm" }
    return "$env:APPDATA\npm"
}
