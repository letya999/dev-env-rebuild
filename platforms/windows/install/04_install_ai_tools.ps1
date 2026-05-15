#requires -version 5.1
param([switch]$Execute, [switch]$SkipYc, [switch]$SkipClaude)
$DryRun = -not $Execute

function Step($Text) { Write-Host "`n=== $Text ===" -ForegroundColor Cyan }
function Run($Command, [scriptblock]$Action) {
    if ($DryRun) { Write-Host "DRY-RUN: $Command" -ForegroundColor Yellow }
    else { Write-Host "Выполняю: $Command" -ForegroundColor Green; & $Action }
}

function WingetInstall($Id, $Name) {
    Run "winget install --id $Id -e --source winget ($Name)" {
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            throw "winget не найден. Установи/обнови App Installer из Microsoft Store."
        }
        winget install --id "$Id" -e --source winget --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
        if ($LASTEXITCODE -ne 0) {
            throw "winget install failed for $Id with exit code $LASTEXITCODE"
        }
    }
}

function Add-UserPathEntry($PathEntry) {
    $current = [Environment]::GetEnvironmentVariable("Path", "User")
    $parts = @()
    if ($current) {
        $parts = $current -split ';' | Where-Object { $_ -and $_.Trim() -ne "" }
    }
    if ($parts -notcontains $PathEntry) {
        $next = (@($parts) + $PathEntry) -join ';'
        [Environment]::SetEnvironmentVariable("Path", $next, "User")
        $env:Path = "$env:Path;$PathEntry"
    }
}

function Install-YandexCloudCli {
    $arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "386" }
    $installDir = Join-Path $env:USERPROFILE "yandex-cloud\bin"
    $zipPath = Join-Path $env:TEMP "yc_windows_$arch.zip"
    $downloadUrl = "https://storage.yandexcloud.net/yandexcloud-yc/release/yc_windows_$arch.zip"

    Run "Download and install yc CLI from $downloadUrl" {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
        Add-UserPathEntry $installDir
        & (Join-Path $installDir "yc.exe") version
    }
}

Write-Host "Режим: $(if ($DryRun) { 'DRY-RUN' } else { 'EXECUTE' })" -ForegroundColor Magenta

# --- Claude Code CLI ---
if (-not $SkipClaude) {
    Step "Claude Code CLI (winget)"
    Write-Host "  Устанавливается через winget (Anthropic.ClaudeCode)." -ForegroundColor Gray
    Write-Host "  Бинарник попадёт в: AppData\Local\Microsoft\WinGet\Links\claude.exe" -ForegroundColor Gray
    Write-Host "  Альтернатива через PS1-инсталлер: irm https://claude.ai/install.ps1 | iex" -ForegroundColor Gray
    WingetInstall "Anthropic.ClaudeCode" "Claude Code CLI"
    Step "Claude Desktop (GUI-приложение)"
    WingetInstall "Anthropic.Claude" "Claude Desktop"
    Step "Проверка Claude Code CLI"
    Run "claude --version" { claude --version }
}

# --- yc CLI (Yandex Cloud) ---
if (-not $SkipYc) {
    Step "yc CLI (Yandex Cloud) — установка без интерактивного install.ps1"
    Write-Host "  Нет winget-пакета. Используется официальный zip-релиз Яндекса для Windows." -ForegroundColor Gray
    Write-Host "  После установки: перезапусти PowerShell, затем выполни 'yc init'" -ForegroundColor Gray
    Install-YandexCloudCli
    Write-Host "`nПосле установки yc CLI:" -ForegroundColor Yellow
    Write-Host "  1. Закрой и открой PowerShell" -ForegroundColor Yellow
    Write-Host "  2. Выполни: yc init" -ForegroundColor Yellow
    Write-Host "  3. Пройди OAuth (откроется браузер)" -ForegroundColor Yellow
    Write-Host "  4. Выбери каталог в Яндекс Облаке" -ForegroundColor Yellow
}

Write-Host "`nГотово. Запусти .\platforms\windows\install\03_final_check.ps1 для проверки." -ForegroundColor Green
