#requires -version 5.1
param([switch]$Execute, [switch]$SkipYc, [switch]$SkipClaude)
$DryRun = -not $Execute

function Step($Text) { Write-Host "`n=== $Text ===" -ForegroundColor Cyan }
function Run($Command, [scriptblock]$Action) {
    if ($DryRun) { Write-Host "DRY-RUN: $Command" -ForegroundColor Yellow }
    else { Write-Host "Выполняю: $Command" -ForegroundColor Green; & $Action }
}

Write-Host "Режим: $(if ($DryRun) { 'DRY-RUN' } else { 'EXECUTE' })" -ForegroundColor Magenta

# --- Claude Code CLI ---
if (-not $SkipClaude) {
    Step "Claude Code CLI (winget)"
    Write-Host "  Устанавливается через winget (Anthropic.ClaudeCode)." -ForegroundColor Gray
    Write-Host "  Бинарник попадёт в: AppData\Local\Microsoft\WinGet\Links\claude.exe" -ForegroundColor Gray
    Write-Host "  Альтернатива через PS1-инсталлер: irm https://claude.ai/install.ps1 | iex" -ForegroundColor Gray
    Run "winget install --id Anthropic.ClaudeCode" {
        winget install --id Anthropic.ClaudeCode --silent --accept-package-agreements --accept-source-agreements
    }
    Step "Claude Desktop (GUI-приложение)"
    Run "winget install --id Anthropic.Claude" {
        winget install --id Anthropic.Claude --silent --accept-package-agreements --accept-source-agreements
    }
    Step "Проверка Claude Code CLI"
    Run "claude --version" { claude --version }
}

# --- yc CLI (Yandex Cloud) ---
if (-not $SkipYc) {
    Step "yc CLI (Yandex Cloud) — установка через PowerShell-скрипт"
    Write-Host "  Нет winget-пакета. Официальный способ — скрипт от Яндекса." -ForegroundColor Gray
    Write-Host "  После установки: перезапусти PowerShell, затем выполни 'yc init'" -ForegroundColor Gray
    Run "Install yc CLI from storage.yandexcloud.net" {
        iex (New-Object System.Net.WebClient).DownloadString('https://storage.yandexcloud.net/yandexcloud-yc/install.ps1')
    }
    Write-Host "`nПосле установки yc CLI:" -ForegroundColor Yellow
    Write-Host "  1. Закрой и открой PowerShell" -ForegroundColor Yellow
    Write-Host "  2. Выполни: yc init" -ForegroundColor Yellow
    Write-Host "  3. Пройди OAuth (откроется браузер)" -ForegroundColor Yellow
    Write-Host "  4. Выбери каталог в Яндекс Облаке" -ForegroundColor Yellow
}

Write-Host "`nГотово. Запусти .\platforms\windows\install\03_final_check.ps1 для проверки." -ForegroundColor Green
