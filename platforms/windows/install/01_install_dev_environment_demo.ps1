#requires -version 5.1
param(
    [switch]$Execute,
    [switch]$InstallCodex
)

<#
Демонстрационная установка dev-окружения после очистки.
По умолчанию dry-run. Для установки нужен -Execute.
Использует winget, если он доступен.
#>

$ErrorActionPreference = "Continue"
$DryRun = -not $Execute

function Step($Text) { Write-Host "`n=== $Text ===" -ForegroundColor Cyan }
function Run($Command, [scriptblock]$Action) {
    if ($DryRun) {
        Write-Host "DRY-RUN: $Command" -ForegroundColor Yellow
    } else {
        Write-Host "Выполняю: $Command" -ForegroundColor Green
        & $Action
    }
}
function WingetInstall($Id, $Name) {
    Run "winget install --id $Id ($Name)" {
        winget install --id $Id --silent --accept-package-agreements --accept-source-agreements
    }
}

Write-Host "Режим: $(if ($DryRun) { 'DRY-RUN, ничего не устанавливается' } else { 'EXECUTE, реальная установка' })" -ForegroundColor Magenta

Step "Проверка winget"
Run "winget --version" { winget --version }

Step "Установка Node.js LTS"
WingetInstall "OpenJS.NodeJS.LTS" "Node.js LTS"

Step "Установка Git"
WingetInstall "Git.Git" "Git for Windows"

Step "Установка Docker Desktop"
WingetInstall "Docker.DockerDesktop" "Docker Desktop"
Write-Host "После установки Docker может понадобиться перезагрузка и включение WSL2/VirtualMachinePlatform." -ForegroundColor Yellow

Step "Установка Python"
WingetInstall "Python.Python.3.12" "Python 3.12"

if ($InstallCodex) {
    Step "Опциональная установка Codex CLI после Node.js"
    Run "npm install -g @openai/codex" { npm install -g @openai/codex }
} else {
    Write-Host "Codex CLI не устанавливается. Для установки добавь параметр -InstallCodex." -ForegroundColor Yellow
}

Write-Host "`nПосле установки закрой и открой PowerShell заново, затем запусти 03_final_check.ps1" -ForegroundColor Green
