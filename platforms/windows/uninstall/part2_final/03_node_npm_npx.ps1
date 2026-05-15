#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

# Определяем npm prefix ПОКА Node/npm ещё установлены
$npmPrefix = $null
try { $npmPrefix = (& npm config get prefix 2>$null) } catch {}
if (-not $npmPrefix -or -not (Test-Path $npmPrefix)) {
    $npmPrefix = if (Test-Path "$env:USERPROFILE\.npm-global") { "$env:USERPROFILE\.npm-global" }
                 elseif (Test-Path "$env:APPDATA\npm") { "$env:APPDATA\npm" }
                 else { "$env:APPDATA\npm" }
}
Write-Host "  npm global prefix: $npmPrefix" -ForegroundColor Cyan

Step "Gemini CLI — предупреждение"
Write-Host "  ВНИМАНИЕ: Gemini CLI скорее всего установлен через npm." -ForegroundColor Yellow
Write-Host "  После удаления Node/npm команда 'gemini' перестанет работать." -ForegroundColor Yellow
Write-Host "  Конфиги ~/.gemini НЕ удаляются. Восстановить: npm install -g @google/gemini-cli" -ForegroundColor Yellow

Step "NPM cache и конфиги"
Remove-PathSafe "$env:APPDATA\npm-cache" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\npm-cache" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.npmrc" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.npm" -DryRun:$DryRun

Step "NPX cache"
Remove-PathSafe "$env:LOCALAPPDATA\npm-cache\_npx" -DryRun:$DryRun
# NPX в npm prefix
Run "Remove npx shims from npm prefix" {
    Remove-Item (Join-Path $npmPrefix "npx") -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $npmPrefix "npx.cmd") -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $npmPrefix "npx.ps1") -Force -ErrorAction SilentlyContinue
} -DryRun:$DryRun

Step "Удаление npm global prefix директории ($npmPrefix)"
Remove-PathSafe $npmPrefix -DryRun:$DryRun
# Стандартный путь — на случай если оба существуют
Remove-PathSafe "$env:APPDATA\npm" -DryRun:$DryRun

Step "Node.js — winget uninstall"
WingetUninstallById "OpenJS.NodeJS.LTS" -DryRun:$DryRun

Step "Node.js — файловые остатки"
Remove-PathSafe "C:\Program Files\nodejs" -DryRun:$DryRun
Remove-PathSafe "C:\Program Files (x86)\nodejs" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\node-gyp" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.node-gyp" -DryRun:$DryRun
