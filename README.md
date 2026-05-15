# dev-env-rebuild

OS-specific scripts for demonstration rebuilds of local developer environments.
The repository is intentionally split by operating system so Windows, macOS, and
Ubuntu can evolve independently without cross-OS conditionals and path noise.

The project is built for AI Camp demos: an AI agent first inventories a concrete
machine, then adapts the local plan, dry-runs destructive steps, and only then
executes the reset and reinstall flow.

## Structure

```text
platforms/
  windows/
    uninstall/          Windows PowerShell uninstall flow
    install/            Windows PowerShell install flow
  macos/
    uninstall/          macOS Bash uninstall flow
    install/            macOS Bash install flow
  ubuntu/
    uninstall/          Ubuntu Bash uninstall flow
    install/            Ubuntu Bash install flow

docs/
  architecture.md       repository structure and safety contracts
  research/             source-backed implementation notes
  windows/              Windows manual guides
```

Generated machine inventory lives under `platforms/<os>/_state/` and is ignored.

## Safety Contract

- Discovery runs before destructive steps.
- Destructive scripts are dry-run by default.
- Windows uses `-Execute`; macOS and Ubuntu use `--execute`.
- Project directories, `.git` directories, existing SSH keys, and AI config
  directories (`~/.claude`, `~/.codex`, `~/.gemini`) are not removed
  automatically.
- Node/npm removal is last in destructive flows because AI CLIs often depend on
  Node while the agent is still guiding the process.
- Reboot or terminal restart checks are required before claiming cleanup is done.

## Windows Quick Start

Run PowerShell as Administrator from the repository root.

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\platforms\windows\uninstall\00_discovery_inventory.ps1

# Dry-run first:
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

# Execute only after inventory/local_plan review:
.\platforms\windows\uninstall\part1_tools\01_python.ps1 -Execute
```

After the uninstall flow, reboot Windows and run:

```powershell
.\platforms\windows\uninstall\03_post_reboot_check.ps1
```

Install after reboot:

```powershell
.\platforms\windows\install\01_install_dev_environment_demo.ps1 -Execute
.\platforms\windows\install\04_install_ai_tools.ps1 -Execute
.\platforms\windows\install\05_ssh_key.ps1 -Execute
.\platforms\windows\install\03_final_check.ps1
```

Manual Windows guide: [docs/windows/manual-setup-guide.md](docs/windows/manual-setup-guide.md).

## macOS Quick Start

```bash
./platforms/macos/uninstall/00_discovery_inventory.sh
./platforms/macos/uninstall/01_uninstall_dev_environment.sh
./platforms/macos/uninstall/01_uninstall_dev_environment.sh --execute
./platforms/macos/uninstall/02_post_uninstall_check.sh

./platforms/macos/install/01_install_dev_environment.sh --execute --install-homebrew
./platforms/macos/install/02_install_ai_tools.sh --execute
./platforms/macos/install/03_ssh_key.sh --execute
./platforms/macos/install/04_final_check.sh
```

## Ubuntu Quick Start

```bash
./platforms/ubuntu/uninstall/00_discovery_inventory.sh
./platforms/ubuntu/uninstall/01_uninstall_dev_environment.sh
./platforms/ubuntu/uninstall/01_uninstall_dev_environment.sh --execute
./platforms/ubuntu/uninstall/02_post_uninstall_check.sh

./platforms/ubuntu/install/01_install_dev_environment.sh --execute
./platforms/ubuntu/install/02_install_ai_tools.sh --execute
./platforms/ubuntu/install/03_ssh_key.sh --execute
./platforms/ubuntu/install/04_final_check.sh
```

Ubuntu intentionally does not purge the OS-critical base `python3` runtime.

## References

Implementation research and source links are in
[docs/research/os-tooling-research.md](docs/research/os-tooling-research.md).

## License

MIT, see [LICENSE](LICENSE).
