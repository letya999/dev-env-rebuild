#requires -version 5.1
<# Проверка после перезагрузки. Ничего не удаляет. #>

$commands = @("node", "npm", "npx", "yarn", "pnpm", "bun", "python", "py", "pip", "git", "gh", "docker", "wsl", "yc", "claude", "codex")
Write-Host "Проверка команд, которые должны быть удалены:" -ForegroundColor Cyan
foreach ($cmd in $commands) {
    $paths = @()
    try { $paths = (& where.exe $cmd 2>$null) } catch {}
    if ($paths.Count -gt 0) {
        Write-Host "[ОСТАЛОСЬ] $cmd" -ForegroundColor Red
        $paths | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    } else {
        Write-Host "[OK] $cmd не найден" -ForegroundColor Green
    }
}

Write-Host "`nОтдельная проверка Gemini:" -ForegroundColor Cyan
try {
    $geminiWhere = & where.exe gemini 2>$null
    if ($geminiWhere) { Write-Host "gemini найден:" -ForegroundColor Green; $geminiWhere | ForEach-Object { Write-Host "  $_" } }
    else { Write-Host "gemini не найден. Если он был npm-based, его нужно восстановить после установки Node.js." -ForegroundColor Yellow }
    try { gemini --version } catch {}
} catch {
    Write-Host "gemini не найден или не запускается. Конфиги Gemini скрипты не удаляли." -ForegroundColor Yellow
}

Write-Host "`nПроверка PATH на остатки:" -ForegroundColor Cyan
$pathLines = @([Environment]::GetEnvironmentVariable("Path", "User") -split ";") + @([Environment]::GetEnvironmentVariable("Path", "Machine") -split ";")
$left = $pathLines | Where-Object { $_ -match "nodejs|npm|pnpm|yarn|bun|Python|Git|Docker|WSL|Codex|ChatGPT|Claude|yc|yandex|Debian" }
if ($left) { $left | ForEach-Object { Write-Host "Осталось в PATH: $_" -ForegroundColor Red } }
else { Write-Host "Явных старых PATH-записей не найдено." -ForegroundColor Green }
