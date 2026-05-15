#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "Yarn Uninstallation"
Remove-PathSafe "$env:APPDATA\Yarn" -DryRun:$DryRun
Remove-PathSafe "$env:LOCALAPPDATA\Yarn" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.yarnrc" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.yarn" -DryRun:$DryRun

Step "pnpm Uninstallation"
# Scoop-установленный pnpm
Run "scoop uninstall pnpm (если установлен через Scoop)" {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop uninstall pnpm 2>$null
    }
} -DryRun:$DryRun
# Shims Scoop (путь через env, не хардкод)
Remove-PathSafe "$env:USERPROFILE\scoop\shims\pnpm.exe" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\scoop\shims\pnpm.ps1" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\scoop\shims\pnpm.shim" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\scoop\shims\pnpx.exe" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\scoop\shims\pnpx.shim" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\scoop\apps\pnpm" -DryRun:$DryRun
# pnpm global store
Remove-PathSafe "$env:LOCALAPPDATA\pnpm" -DryRun:$DryRun
Remove-PathSafe "$env:APPDATA\pnpm" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.pnpmrc" -DryRun:$DryRun

Step "Bun Uninstallation"
WingetUninstall "Bun" -DryRun:$DryRun
Remove-PathSafe "$env:USERPROFILE\.bun" -DryRun:$DryRun

Step "Turbo cache"
Remove-PathSafe "$env:LOCALAPPDATA\Turbo" -DryRun:$DryRun
