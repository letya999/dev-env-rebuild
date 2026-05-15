#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute

$SshDir = Join-Path $env:USERPROFILE ".ssh"
$KeyPath = Join-Path $SshDir "id_ed25519"
$PubPath = "$KeyPath.pub"

function Run($Command, [scriptblock]$Action) {
    if ($DryRun) { Write-Host "DRY-RUN: $Command" -ForegroundColor Yellow }
    else { Write-Host "Выполняю: $Command" -ForegroundColor Green; & $Action }
}

Write-Host "Скрипт создаёт постоянный SSH-ключ для подключения к серверам Яндекс Облака." -ForegroundColor Cyan

if ($DryRun) {
    if (Test-Path $KeyPath) {
        Write-Host "DRY-RUN: SSH-ключ уже существует: $KeyPath" -ForegroundColor Yellow
        if (-not (Test-Path $PubPath)) {
            Write-Host "DRY-RUN: публичный ключ был бы восстановлен из приватного ключа." -ForegroundColor Yellow
        }
    } else {
        Write-Host "DRY-RUN: был бы создан SSH-ключ: $KeyPath" -ForegroundColor Yellow
    }
    return
}

if (-not $DryRun) {
    if (Test-Path $KeyPath) {
        Write-Host "`nSSH-ключ уже существует: $KeyPath" -ForegroundColor Yellow
        if (-not (Test-Path $PubPath)) {
            Run "Восстановить публичный ключ из существующего приватного ключа" {
                ssh-keygen -y -f $KeyPath | Set-Content -Path $PubPath -Encoding ascii
            }
        }
        Write-Host "Публичный ключ (скопируй в Яндекс Облако):" -ForegroundColor Cyan
        if (Test-Path $PubPath) {
            Get-Content $PubPath
        } else {
            Write-Host "Публичный ключ не найден и не был восстановлен автоматически." -ForegroundColor Red
        }
        Write-Host "`nДля создания НОВОГО ключа сначала удали $KeyPath" -ForegroundColor Red
        return
    }
}

Run "Создать .ssh директорию" { New-Item -ItemType Directory -Path $SshDir -Force | Out-Null }
Run "ssh-keygen -t ed25519 -f $KeyPath (без passphrase)" {
    ssh-keygen -t ed25519 -f $KeyPath -N "" -C "ai-camp-yandex-cloud"
}

if (-not $DryRun -and (Test-Path $PubPath)) {
    Write-Host "`n=== ПУБЛИЧНЫЙ КЛЮЧ (скопируй в профиль Яндекс Облака) ===" -ForegroundColor Green
    Get-Content $PubPath
    Write-Host "===========================================================" -ForegroundColor Green
    Write-Host "`nКак добавить в Яндекс Облако:" -ForegroundColor Yellow
    Write-Host "  1. Открой: console.yandex.cloud" -ForegroundColor Yellow
    Write-Host "  2. Профиль -> SSH-ключи -> Добавить ключ" -ForegroundColor Yellow
    Write-Host "  3. Вставь содержимое выше" -ForegroundColor Yellow
}
