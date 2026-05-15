# Windows implementation

Windows uses PowerShell 5.1+, `winget`, Docker Desktop, and WSL-specific
commands. Run PowerShell as Administrator from the repository root.

## Flow

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

.\platforms\windows\uninstall\00_discovery_inventory.ps1

# Dry-run first, then repeat with -Execute after reviewing _state.
.\platforms\windows\uninstall\part1_tools\01_python.ps1
.\platforms\windows\uninstall\part1_tools\02_git.ps1
.\platforms\windows\uninstall\part1_tools\03_docker.ps1
.\platforms\windows\uninstall\part1_tools\04_wsl.ps1
.\platforms\windows\uninstall\part1_tools\05_js_package_managers.ps1
.\platforms\windows\uninstall\part1_tools\06_yandex_chatgpt.ps1
.\platforms\windows\uninstall\part2_final\01_claude_deep_clean.ps1
.\platforms\windows\uninstall\part2_final\02_codex_deep_clean.ps1
.\platforms\windows\uninstall\part2_final\03_node_npm_npx.ps1
.\platforms\windows\uninstall\part2_final\04_env_registry_path.ps1
```

After execute mode, reboot Windows and run:

```powershell
.\platforms\windows\uninstall\03_post_reboot_check.ps1
```

Install:

```powershell
.\platforms\windows\install\01_install_dev_environment_demo.ps1 -Execute
.\platforms\windows\install\04_install_ai_tools.ps1 -Execute
.\platforms\windows\install\05_ssh_key.ps1 -Execute
.\platforms\windows\install\03_final_check.ps1
```
