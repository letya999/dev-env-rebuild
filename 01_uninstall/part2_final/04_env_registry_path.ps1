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

function Clean-Path($Scope, $Patterns, $Dry) {
    $oldPath = [Environment]::GetEnvironmentVariable("Path", $Scope)
    if (-not $oldPath) { return }
    $parts = $oldPath -split ";" | Where-Object { $_ -and $_.Trim() -ne "" }
    $removed = @()
    $clean = foreach ($p in $parts) {
        $match = $false
        foreach ($pat in $Patterns) { if ($p -match $pat) { $match = $true; break } }
        if ($match) { $removed += $p } else { $p }
    }
    Write-Host "PATH ($Scope) removing: $($removed -join ', ')" -ForegroundColor Yellow
    if (-not $Dry) { [Environment]::SetEnvironmentVariable("Path", ($clean -join ";"), $Scope) }
}

$patterns = @("nodejs", "npm", "pnpm", "yarn", "bun", "Python", "Git", "Docker", "WSL", "Claude", "yc", "yandex", "Codex", "\.local\\bin", "npm-global")
Clean-Path "User" $patterns $DryRun
Clean-Path "Machine" $patterns $DryRun

Write-Host "`nSYSTEM CLEAN. REBOOT NOW." -ForegroundColor Green
