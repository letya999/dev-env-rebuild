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

function Convert-ToSafeFullPath($Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    $expanded = [Environment]::ExpandEnvironmentVariables($Path)
    if ($expanded.IndexOfAny([char[]]@('*', '?', '[', ']')) -ge 0) {
        Write-Host "BLOCKED (SAFETY): Wildcards are not allowed in removal paths: $Path" -ForegroundColor Red
        return $null
    }
    if (-not [System.IO.Path]::IsPathRooted($expanded)) {
        Write-Host "BLOCKED (SAFETY): Removal path must be absolute: $Path" -ForegroundColor Red
        return $null
    }
    try { return ([System.IO.Path]::GetFullPath($expanded)).TrimEnd('\') }
    catch {
        Write-Host "BLOCKED (SAFETY): Cannot normalize path: $Path" -ForegroundColor Red
        return $null
    }
}

function Test-SameOrChildPath($Candidate, $Parent) {
    if (-not $Candidate -or -not $Parent) { return $false }
    $candidateNorm = $Candidate.TrimEnd('\').ToLowerInvariant()
    $parentNorm = $Parent.TrimEnd('\').ToLowerInvariant()
    return ($candidateNorm -eq $parentNorm -or $candidateNorm.StartsWith("$parentNorm\"))
}

function Get-ProtectedRemovalPaths {
    $defaults = @(
        "$env:USERPROFILE\a_projects",
        "$env:USERPROFILE\projects",
        "$env:USERPROFILE\Projects",
        "$env:USERPROFILE\Desktop\projects",
        "$env:USERPROFILE\Documents\projects",
        "$env:USERPROFILE\.agents",
        "$env:USERPROFILE\.ai_backup"
    )
    $fromEnv = @()
    if ($env:DEV_ENV_REBUILD_PROTECTED_PATHS) {
        $fromEnv = $env:DEV_ENV_REBUILD_PROTECTED_PATHS -split ';' | Where-Object { $_ -and $_.Trim() -ne "" }
    }
    @($defaults + $fromEnv) |
        ForEach-Object { Convert-ToSafeFullPath $_ } |
        Where-Object { $_ } |
        Sort-Object -Unique
}

function Test-CriticalRemovalRoot($NormalizedPath) {
    $critical = @(
        ([System.IO.Path]::GetPathRoot($env:USERPROFILE)),
        $env:USERPROFILE,
        $env:APPDATA,
        $env:LOCALAPPDATA,
        $env:ProgramData,
        $env:ProgramFiles,
        ${env:ProgramFiles(x86)},
        "C:\Users"
    ) | Where-Object { $_ }

    foreach ($root in $critical) {
        $normalizedRoot = Convert-ToSafeFullPath $root
        if ($normalizedRoot -and $NormalizedPath.ToLowerInvariant() -eq $normalizedRoot.ToLowerInvariant()) {
            return $true
        }
    }
    return $false
}

function Remove-PathSafe($Path, [switch]$DryRun) {
    $normalizedTarget = Convert-ToSafeFullPath $Path
    if (-not $normalizedTarget) { return }

    if (Test-CriticalRemovalRoot $normalizedTarget) {
        Write-Host "BLOCKED (SAFETY): Refusing to remove critical root $Path" -ForegroundColor Red
        return
    }

    foreach ($protected in Get-ProtectedRemovalPaths) {
        if (Test-SameOrChildPath $normalizedTarget $protected) {
            Write-Host "BLOCKED (SAFETY): Cannot remove $Path as it is inside protected directory $protected" -ForegroundColor Red
            return
        }
        if (Test-SameOrChildPath $protected $normalizedTarget) {
            Write-Host "BLOCKED (SAFETY): Cannot remove $Path as it contains protected directory $protected" -ForegroundColor Red
            return
        }
    }

    Run "Remove: $Path" {
        if (Test-Path -LiteralPath $Path) {
            Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "  path not found, skipped" -ForegroundColor Gray
        }
    } -DryRun:$DryRun
}

function Invoke-WingetIfAvailable([scriptblock]$Action) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "  winget not found, skipped" -ForegroundColor Yellow
        return
    }
    & $Action
}

function WingetUninstallById($Id, [switch]$DryRun) {
    Run "winget uninstall --id $Id -e --source winget" {
        Invoke-WingetIfAvailable {
            winget uninstall --id "$Id" -e --source winget --silent --accept-source-agreements --disable-interactivity
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  winget did not uninstall '$Id' (not installed or installer returned non-zero)" -ForegroundColor Gray
            }
        }
    } -DryRun:$DryRun
}

function WingetUninstallByName($Name, [switch]$DryRun) {
    Run "winget uninstall --name '$Name'" {
        Invoke-WingetIfAvailable {
            winget uninstall --name "$Name" --silent --accept-source-agreements --disable-interactivity
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  winget did not uninstall '$Name' (not installed, ambiguous, or installer returned non-zero)" -ForegroundColor Gray
            }
        }
    } -DryRun:$DryRun
}

function WingetUninstall($Name, [switch]$DryRun) {
    Run "winget uninstall --name '$Name'" {
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Host "  winget not found, skipped" -ForegroundColor Yellow
            return
        }
        winget uninstall --name "$Name" --silent --accept-source-agreements --disable-interactivity
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  winget did not uninstall '$Name' (not installed or installer returned non-zero)" -ForegroundColor Gray
        }
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
