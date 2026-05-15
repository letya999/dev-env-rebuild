#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "Codex Deep Clean"
WingetUninstall "ChatGPT" -DryRun:$DryRun

Step "Codex — npm uninstall (пакет @openai/codex)"
Run "npm uninstall -g @openai/codex" {
    npm uninstall -g @openai/codex 2>$null
} -DryRun:$DryRun

Step "Codex — удаление shims и модулей из npm prefix"
Run "Remove codex shims from npm prefix" {
    $prefix = Get-NpmPrefix
    Remove-Item (Join-Path $prefix "codex") -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $prefix "codex.cmd") -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $prefix "codex.ps1") -Force -ErrorAction SilentlyContinue
    Remove-PathSafe (Join-Path $prefix "node_modules\@openai") -DryRun:$DryRun
    Remove-PathSafe (Join-Path $prefix "node_modules\codex") -DryRun:$DryRun
} -DryRun:$DryRun

Step "Codex данные"
Remove-PathSafe "$env:LOCALAPPDATA\ChatGPT" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\Programs\ChatGPT" -DryRun:$DryRun
Remove-PathSafe "$env:APPDATA\ChatGPT" -DryRun:$DryRun
Write-Host "  ВНИМАНИЕ: ~/.codex (настройки, MCP, skills, auth cache) НЕ удаляется автоматически." -ForegroundColor Yellow
Write-Host "  Если нужна ручная очистка ~/.codex, сначала сделай отдельный backup и проверь содержимое." -ForegroundColor Yellow
