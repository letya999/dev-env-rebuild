#requires -version 5.1
<#
Inventory Script (STRENGTHENED). Deletes nothing.
Collects versions, paths, PATH/env, installed apps, WSL, registry and services.
#>

$ErrorActionPreference = "Continue"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$StateDir = Join-Path $Root "_state"
$InventoryJson = Join-Path $StateDir "inventory.json"
$InventoryMd = Join-Path $StateDir "inventory.md"
$LocalPlan = Join-Path $StateDir "local_plan.md"

if (-not (Test-Path $StateDir)) { New-Item -ItemType Directory -Path $StateDir -Force | Out-Null }

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

function Get-NpmPrefixSafe {
    try {
        $prefix = (& npm config get prefix 2>$null)
        if ($prefix) { return $prefix }
    } catch {}
    return "not found"
}

function Get-ProjectRootOverview {
    $candidates = @(
        "$env:USERPROFILE\a_projects",
        "$env:USERPROFILE\projects",
        "$env:USERPROFILE\Projects",
        "$env:USERPROFILE\Desktop\projects",
        "$env:USERPROFILE\Documents\projects"
    )
    foreach ($p in $candidates) {
        if (Test-Path -LiteralPath $p) {
            $children = @(Get-ChildItem -LiteralPath $p -Directory -Force -ErrorAction SilentlyContinue |
                Select-Object -First 30 -ExpandProperty Name)
            [pscustomobject]@{
                Path = $p
                Exists = $true
                DirectoryCountSample = $children.Count
                SampleDirectories = @($children)
            }
        } else {
            [pscustomobject]@{
                Path = $p
                Exists = $false
                DirectoryCountSample = 0
                SampleDirectories = @()
            }
        }
    }
}

$commands = @(
    (Get-CommandInfoSafe "node" @("-v", "--version")),
    (Get-CommandInfoSafe "npm" @("-v", "--version")),
    (Get-CommandInfoSafe "npx" @("-v", "--version")),
    (Get-CommandInfoSafe "yarn" @("-v", "--version")),
    (Get-CommandInfoSafe "pnpm" @("-v", "--version")),
    (Get-CommandInfoSafe "bun" @("-v", "--version")),
    (Get-CommandInfoSafe "python" @("--version")),
    (Get-CommandInfoSafe "py" @("--version")),
    (Get-CommandInfoSafe "pip" @("--version")),
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
    npmGlobalPrefix = (Get-NpmPrefixSafe)
    projectRoots = @(Get-ProjectRootOverview)
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
$md += "```text"
foreach ($line in $wslDistrosRaw) { $md += $line }
$md += "```"
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
$md += "## npm global prefix"
$md += "$($inventory.npmGlobalPrefix)"
$md += ""
$md += "## Project Root Overview"
foreach ($p in $inventory.projectRoots) {
    $md += "- $($p.Path): $(if ($p.Exists) { "exists; sample directories: $($p.SampleDirectories -join ', ')" } else { "not found" })"
}
$md += ""
$md += "## Relevant Env Vars"
foreach ($e in $inventory.interestingEnv) { $md += "- $($e.Name) = $($e.Value)" }

$md | Set-Content -Path $InventoryMd -Encoding UTF8

if (-not (Test-Path $LocalPlan)) {
    $npmPrefixDetected = try { (& npm config get prefix 2>$null) } catch { "not found" }
    @(
        "# Локальный план адаптации",
        "",
        "Generated: $((Get-Date).ToString('s'))",
        "",
        "## Инструкция для агента",
        "Заполни этот файл после анализа inventory.md и inventory.json.",
        "Опиши реальные установленные инструменты, нестандартные пути, npm global prefix, PATH-записи, WSL-дистрибутивы и безопасный порядок удаления.",
        "",
        "## npm global prefix",
        "npm config get prefix: $npmPrefixDetected",
        "",
        "## Статус инструментов",
        "Заполнить на основе inventory.md"
    ) | Set-Content -Path $LocalPlan -Encoding UTF8
    Write-Host "local_plan.md created/updated: $LocalPlan" -ForegroundColor Green
}

Write-Host "Inventory complete. Files created in _state/" -ForegroundColor Green
