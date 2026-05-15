#requires -version 5.1
param([switch]$Execute)

<#
Создаёт отдельный временный SSH-ключ для демонстрации и сразу его удаляет.
Существующие ключи пользователя не трогаются.
#>

$DryRun = -not $Execute
$SshDir = Join-Path $env:USERPROFILE ".ssh"
$KeyPath = Join-Path $SshDir "ai_camp_demo_key"
$PubPath = "$KeyPath.pub"

function Run($Command, [scriptblock]$Action) {
    if ($DryRun) { Write-Host "DRY-RUN: $Command" -ForegroundColor Yellow }
    else { Write-Host "Выполняю: $Command" -ForegroundColor Green; & $Action }
}

Write-Host "Этот скрипт НЕ трогает существующие id_ed25519/id_rsa." -ForegroundColor Cyan
Write-Host "Он создаёт только временный ai_camp_demo_key и сразу удаляет его." -ForegroundColor Cyan

Run "Создать папку .ssh" { New-Item -ItemType Directory -Path $SshDir -Force | Out-Null }
Run "Удалить старый demo-key, если остался" { Remove-Item $KeyPath -Force -ErrorAction SilentlyContinue; Remove-Item $PubPath -Force -ErrorAction SilentlyContinue }
Run "ssh-keygen -t ed25519 -f $KeyPath -N ''" { ssh-keygen -t ed25519 -f $KeyPath -N "" }

if (-not $DryRun) {
    Write-Host "`nПубличный ключ, который можно показывать/добавлять в облако:" -ForegroundColor Green
    Get-Content $PubPath
    Write-Host "`nПриватный ключ без .pub показывать нельзя." -ForegroundColor Yellow
}

Run "Удалить demo SSH key" { Remove-Item $KeyPath -Force -ErrorAction SilentlyContinue; Remove-Item $PubPath -Force -ErrorAction SilentlyContinue }
Write-Host "Готово. Demo-ключ удалён." -ForegroundColor Green
