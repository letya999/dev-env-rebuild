#requires -version 5.1
param([switch]$Execute)
$DryRun = -not $Execute
. (Join-Path $PSScriptRoot "..\lib.ps1")

Step "WSL Uninstallation"
Run "wsl --shutdown" { wsl --shutdown 2>$null } -DryRun:$DryRun
Run "wsl --unregister all" {
    $distros = wsl --list --quiet 2>$null
    foreach ($distro in $distros) {
        $clean = $distro.Trim()
        if ($clean) { wsl --unregister $clean }
    }
} -DryRun:$DryRun
WingetUninstall "Windows Subsystem for Linux" -DryRun:$DryRun
Run "Disable Features" {
    dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
    dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart
} -DryRun:$DryRun
