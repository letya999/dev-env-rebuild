#requires -version 5.1
<#
Скрипт инвентаризации (УСИЛЕННЫЙ). Ничего не удаляет.
Собирает версии, пути, PATH/env, установленные приложения, WSL, реестр и службы.
#>

$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$StateDir = Join-Path $Root "_state"
if (-not (Test-Path $StateDir)) { New-Item -ItemType Directory -Path $StateDir -Force | Out-Null }

$InventoryJson = Join-Path $StateDir "inventory.json"
$InventoryMd = Join-Path $StateDir "inventory.md"
$LocalPlan = Join-Path $StateDir "local_plan.md"

function Get-CommandInfoSafe {
    param([string]$Name, [string[]]$VersionArgs = @("--version"))
    $where = @()
    $version = @()
    try { $where = (& where.exe $Name 2>$null) } catch {}
    foreach ($arg in $VersionArgs) {
        try {
            $out = (& $Name $arg 2>&1 | Select-Object -First 5) -join "`n"
            if ($out) { $version += "[$arg] $out"; break }
        } catch {}
    }
    [pscustomobject]@{
        name = $Name
        paths = @($where)
        version = ($version -join "`n")
    }
}

function Get-InstalledApps {
    $keys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $apps = foreach ($key in $keys) {
        Get-ItemProperty $key -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName } |
            Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation, UninstallString
    }
    $apps | Sort-Object DisplayName -Unique
}

function Get-ExistingPathReport {
    $candidates = @(
        "$env:APPDATA\npm",
        "$env:APPDATA\npm-cache",
        "$env:LOCALAPPDATA\npm-cache",
        "$env:LOCALAPPDATA\pnpm",
        "$env:APPDATA\pnpm",
        "$env:APPDATA\Yarn",
        "$env:LOCALAPPDATA\node-gyp",
        "$env:USERPROFILE\.npm",
        "$env:USERPROFILE\.npmrc",
        "$env:USERPROFILE\.yarnrc",
        "$env:USERPROFILE\.pnpmrc",
        "$env:USERPROFILE\.node-gyp",
        "C:\Program Files\nodejs",
        "C:\Program Files (x86)\nodejs",
        "$env:LOCALAPPDATA\Programs\Python",
        "$env:APPDATA\Python",
        "$env:LOCALAPPDATA\pip",
        "$env:USERPROFILE\AppData\Roaming\Python",
        "$env:USERPROFILE\.cache\pip",
        "$env:USERPROFILE\.virtualenvs",
        "$env:USERPROFILE\.conda",
        "C:\Program Files\Git",
        "C:\Program Files (x86)\Git",
        "$env:LOCALAPPDATA\GitHub",
        "$env:LOCALAPPDATA\GitCredentialManager",
        "$env:APPDATA\GitCredentialManager",
        "$env:USERPROFILE\.docker",
        "C:\ProgramData\Docker",
        "C:\Program Files\Docker",
        "$env:USERPROFILE\.codex",
        "$env:USERPROFILE\.gemini",
        "$env:USERPROFILE\.wslconfig"
    )
    foreach ($p in $candidates) {
        [pscustomobject]@{ Path = $p; Exists = (Test-Path $p) }
    }
}

function Get-RegistryChecks {
    $paths = @(
        "HKCU:\Software\Node.js",
        "HKLM:\SOFTWARE\Node.js",
        "HKCU:\Software\Python",
        "HKLM:\SOFTWARE\Python"
    )
    $res = foreach ($p in $paths) {
        [pscustomobject]@{ Path = $p; Exists = (Test-Path $p) }
    }
    $res
}

function Get-ServiceChecks {
    $names = @("docker", "com.docker.service", "WSLService")
    $res = foreach ($n in $names) {
        $s = Get-Service -Name $n -ErrorAction SilentlyContinue
        if ($s) {
            [pscustomobject]@{ Name = $n; Status = $s.Status.ToString() }
        }
    }
    $res
}

$commands = @(
    (Get-CommandInfoSafe "node" @("-v", "--version")),
    (Get-CommandInfoSafe "npm" @("-v", "--version")),
    (Get-CommandInfoSafe "yarn" @("-v", "--version")),
    (Get-CommandInfoSafe "pnpm" @("-v", "--version")),
    (Get-CommandInfoSafe "bun" @("-v", "--version")),
    (Get-CommandInfoSafe "python" @("--version")),
    (Get-CommandInfoSafe "git" @("--version")),
    (Get-CommandInfoSafe "gh" @("--version")),
    (Get-CommandInfoSafe "docker" @("--version")),
    (Get-CommandInfoSafe "wsl" @("--status", "--version")),
    (Get-CommandInfoSafe "yc" @("--version")),
    (Get-CommandInfoSafe "claude" @("--version")),
    (Get-CommandInfoSafe "codex" @("--version")),
    (Get-CommandInfoSafe "gemini" @("--version"))
)

$wslDistrosRaw = @()
try { 
    # Исправляем баг с дублированием/кодировкой WSL
    $wslDistrosRaw = (wsl.exe --list --verbose | Out-String) -split "`n" | Where-Object { $_ -and $_.Trim() -ne "" }
    $wslDistrosRaw = $wslDistrosRaw | ForEach-Object { $_ -replace '\x00', '' }
} catch { $wslDistrosRaw = @("WSL unavailable") }

$apps = Get-InstalledApps
$interestingApps = $apps | Where-Object {
    $_.DisplayName -match "Node|Python|Git|GitHub|Docker|WSL|Ubuntu|Debian|ChatGPT|Codex|Gemini|Bun|Claude|Yandex|Visual Studio Code|Cursor"
}

$envInteresting = Get-ChildItem Env: | Where-Object {
    $_.Name -match "NODE|NPM|YARN|PNPM|BUN|PYTHON|PIP|DOCKER|WSL|OPENAI|CODEX|GEMINI|GOOGLE|CLAUDE|YANDEX|YC"
} | Sort-Object Name

$inventory = [pscustomobject]@{
    generatedAt = (Get-Date).ToString("s")
    user = $env:USERNAME
    computer = $env:COMPUTERNAME
    commands = $commands
    wslDistrosRaw = @($wslDistrosRaw)
    interestingApps = @($interestingApps)
    userPath = ([Environment]::GetEnvironmentVariable("Path", "User") -split ";" | Where-Object { $_ })
    machinePath = ([Environment]::GetEnvironmentVariable("Path", "Machine") -split ";" | Where-Object { $_ })
    interestingEnv = @($envInteresting | ForEach-Object { [pscustomobject]@{ Name=$_.Name; Value=$_.Value } })
    existingPaths = @(Get-ExistingPathReport)
    registry = @(Get-RegistryChecks)
    services = @(Get-ServiceChecks)
}

$inventory | ConvertTo-Json -Depth 8 | Set-Content -Path $InventoryJson -Encoding UTF8

$md = @()
$md += "# Inventory Report"
$md += ""
$md += "Generated: $($inventory.generatedAt)"
$md += "User: $($inventory.user)"
$md += ""
$md += "## Commands"
foreach ($c in $commands) {
    $md += "### $($c.name)"
    $md += "- Paths: $(if ($c.paths.Count -gt 0) { $c.paths -join ', ' } else { 'none' })"
    $md += "- Version: $(if ($c.version) { $c.version } else { 'not found' })"
}
$md += ""
$md += "## WSL"
$md += "```text`n$($wslDistrosRaw -join "`n")`n```"
$md += ""
$md += "## Services"
foreach ($s in $inventory.services) { $md += "- $($s.Name): $($s.Status)" }
$md += ""
$md += "## Registry Keys"
foreach ($r in $inventory.registry | Where-Object { $_.Exists }) { $md += "- $($r.Path)" }
$md += ""
$md += "## Existing Paths"
foreach ($p in $inventory.existingPaths | Where-Object { $_.Exists }) { $md += "- $($p.Path)" }
$md += ""
$md += "## Relevant Env Vars"
foreach ($e in $inventory.interestingEnv) { $md += "- $($e.Name) = $($e.Value)" }

$md | Set-Content -Path $InventoryMd -Encoding UTF8

# Создать local_plan.md с шаблоном, если не существует
if (-not (Test-Path $LocalPlan)) {
    $npmPrefixDetected = try { (& npm config get prefix 2>$null) } catch { "not found" }
    @(
        "# Локальный план адаптации",
        "",
        "Сгенерирован: $((Get-Date).ToString('s'))",
        "",
        "## Инструкция для агента",
        "Этот файл должен быть заполнен агентом (Gemini/Codex) после анализа inventory.md.",
        "Опиши здесь: что нестандартно, какие пути отличаются от дефолтных, что нужно адаптировать.",
        "",
        "## npm global prefix",
        "npm config get prefix: $npmPrefixDetected",
        "",
        "## Статус инструментов",
        "Заполнить по inventory.md"
    ) | Set-Content -Path $LocalPlan -Encoding UTF8
    Write-Host "local_plan.md создан/обновлён: $LocalPlan" -ForegroundColor Green
}

Write-Host "Inventory complete. Files created in _state/" -ForegroundColor Green
