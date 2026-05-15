#requires -version 5.1
<# Финальная проверка после установки. Ничего не меняет. #>

$commands = @(
    @{ Cmd = "node";   VersionArg = "-v";        Required = $true  },
    @{ Cmd = "npm";    VersionArg = "-v";         Required = $true  },
    @{ Cmd = "npx";    VersionArg = "-v";         Required = $false },
    @{ Cmd = "python"; VersionArg = "--version";  Required = $true  },
    @{ Cmd = "git";    VersionArg = "--version";  Required = $true  },
    @{ Cmd = "docker"; VersionArg = "--version";  Required = $true  },
    @{ Cmd = "claude"; VersionArg = "--version";  Required = $true  },
    @{ Cmd = "yc";     VersionArg = "--version";  Required = $false },
    @{ Cmd = "codex";  VersionArg = "--version";  Required = $false },
    @{ Cmd = "gemini"; VersionArg = "--version";  Required = $false }
)

$allOk = $true
foreach ($item in $commands) {
    $cmd = $item.Cmd
    Write-Host "`n=== $cmd ===" -ForegroundColor Cyan
    try {
        $paths = & where.exe $cmd 2>$null
        if ($paths) {
            $paths | ForEach-Object { Write-Host "  Путь: $_" }
            try { & $cmd $item.VersionArg 2>&1 | Select-Object -First 3 } catch {}
            Write-Host "  [OK]" -ForegroundColor Green
        } else {
            $msg = if ($item.Required) { "[ОШИБКА] $cmd не найден — ОБЯЗАТЕЛЬНО" } else { "[INFO] $cmd не найден — опционально" }
            Write-Host "  $msg" -ForegroundColor $(if ($item.Required) { "Red" } else { "Yellow" })
            if ($item.Required) { $allOk = $false }
        }
    } catch {
        Write-Host "  Не найден" -ForegroundColor Yellow
    }
}

Write-Host "`n--- Итог ---" -ForegroundColor Cyan
if ($allOk) {
    Write-Host "Все обязательные инструменты установлены." -ForegroundColor Green
} else {
    Write-Host "Некоторые обязательные инструменты отсутствуют. Проверь выше." -ForegroundColor Red
}

Write-Host "`nDocker hello-world (проверь отдельно после запуска Docker Desktop):" -ForegroundColor Yellow
Write-Host "  docker run hello-world"
Write-Host "`nClaude Code авторизация:" -ForegroundColor Yellow
Write-Host "  claude (откроется браузер для входа в аккаунт Anthropic)"
Write-Host "`nyc init (если установлен yc CLI):" -ForegroundColor Yellow
Write-Host "  yc init"
