#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "Registry & Env Cleanup"
Run "Cleanup Registry" {
    Remove-Item "HKCU:\Software\Python" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "HKLM:\SOFTWARE\Python" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "HKCU:\Software\Node.js" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "HKLM:\SOFTWARE\Node.js" -Recurse -Force -ErrorAction SilentlyContinue
} -DryRun:$DryRun

$vars = @("NODE_PATH", "NPM_CONFIG_PREFIX", "PYTHONPATH", "PY_PYTHON", "PNPM_HOME", "BUN_INSTALL", "YC_TOKEN", "ANTHROPIC_API_KEY")
foreach ($v in $vars) {
    Run "Delete ENV $v" {
        [Environment]::SetEnvironmentVariable($v, $null, "User")
        [Environment]::SetEnvironmentVariable($v, $null, "Machine")
    } -DryRun:$DryRun
}

function Normalize-PathText($Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return "" }
    try { return ([System.IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($Path))).TrimEnd('\').ToLowerInvariant() }
    catch { return $Path.TrimEnd('\').ToLowerInvariant() }
}

function Should-RemovePathEntry($Path, $ExactPaths, $RegexPatterns) {
    $normalized = Normalize-PathText $Path
    foreach ($exact in $ExactPaths) {
        if ($normalized -eq (Normalize-PathText $exact)) { return $true }
    }
    foreach ($pattern in $RegexPatterns) {
        if ($Path -match $pattern) { return $true }
    }
    return $false
}

function Clean-Path($Scope, $ExactPaths, $RegexPatterns, $Dry) {
    $oldPath = [Environment]::GetEnvironmentVariable("Path", $Scope)
    if (-not $oldPath) { return }
    $parts = $oldPath -split ";" | Where-Object { $_ -and $_.Trim() -ne "" }
    $removed = @()
    $clean = foreach ($p in $parts) {
        $match = Should-RemovePathEntry $p $ExactPaths $RegexPatterns
        if ($match) { $removed += $p } else { $p }
    }
    if ($removed.Count -gt 0) {
        Write-Host "PATH ($Scope) removing: $($removed -join ', ')" -ForegroundColor Yellow
    } else {
        Write-Host "PATH ($Scope): no matching entries" -ForegroundColor Gray
    }
    if (-not $Dry) { [Environment]::SetEnvironmentVariable("Path", ($clean -join ";"), $Scope) }
}

$exactPaths = @(
    "$env:APPDATA\npm",
    "$env:USERPROFILE\.npm-global",
    "$env:APPDATA\Yarn\bin",
    "$env:LOCALAPPDATA\pnpm",
    "$env:APPDATA\pnpm",
    "$env:USERPROFILE\.bun\bin",
    "C:\Program Files\nodejs",
    "C:\Program Files (x86)\nodejs",
    "C:\Program Files\Git\cmd",
    "C:\Program Files\Git\bin",
    "C:\Program Files\Docker\Docker\resources\bin",
    "$env:USERPROFILE\yandex-cloud\bin"
)
$regexPatterns = @(
    "\\Programs\\Python\\Python\d+(\\Scripts)?\\?$",
    "\\AppData\\Roaming\\Python\\Python\d+\\Scripts\\?$",
    "\\Python\d+(\\Scripts)?\\?$"
)
Clean-Path "User" $exactPaths $regexPatterns $DryRun
Clean-Path "Machine" $exactPaths $regexPatterns $DryRun

Write-Host "`nSYSTEM CLEAN. REBOOT NOW." -ForegroundColor Green
