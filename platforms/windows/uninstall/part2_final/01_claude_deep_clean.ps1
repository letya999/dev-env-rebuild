#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "Claude Desktop (GUI app) Uninstall"
WingetUninstall "Claude" -DryRun:$DryRun

Step "Claude Code CLI — winget uninstall (если установлен через winget)"
Run "winget uninstall Anthropic.ClaudeCode" {
    winget uninstall --id Anthropic.ClaudeCode --silent --accept-source-agreements 2>$null
} -DryRun:$DryRun

Step "Claude Code CLI — удаление бинарника PS1-инсталлера (~/.local/bin)"
Remove-PathSafe "$env:USERPROFILE\.local\bin\claude.exe" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.local\share\claude" -DryRun:$DryRun

Step "Claude Code CLI — удаление npm-глобального пакета (если установлен через npm)"
Run "npm uninstall -g @anthropic-ai/claude-code" {
    $prefix = Get-NpmPrefix
    $cliPath = Join-Path $prefix "node_modules\@anthropic-ai\claude-code"
    if (Test-Path $cliPath) {
        npm uninstall -g @anthropic-ai/claude-code 2>$null
    } else {
        Write-Host "  @anthropic-ai/claude-code не найден в npm global — пропускаем" -ForegroundColor Gray
    }
} -DryRun:$DryRun

Step "Claude Code CLI — удаление shims в npm prefix"
Run "Remove claude shims from npm prefix" {
    $prefix = Get-NpmPrefix
    Remove-Item (Join-Path $prefix "claude") -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $prefix "claude.cmd") -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $prefix "claude.ps1") -Force -ErrorAction SilentlyContinue
} -DryRun:$DryRun

Step "Claude конфиги и данные"
Remove-PathSafe "$env:APPDATA\Claude" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\Claude" -DryRun:$DryRun
# ВНИМАНИЕ: $env:USERPROFILE\.claude содержит настройки, MCP-конфиги, memory.
# Раскомментировать только если нужна полная очистка:
# Remove-PathSafe "$env:USERPROFILE\.claude" -DryRun:$DryRun
Write-Host "  ВНИМАНИЕ: ~/.claude (настройки, MCP) НЕ удаляется автоматически." -ForegroundColor Yellow
Write-Host "  Если нужна ручная очистка ~/.claude, сначала сделай отдельный backup." -ForegroundColor Yellow
