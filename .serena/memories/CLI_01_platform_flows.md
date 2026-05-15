<!-- Memory Metadata
Last updated: 2026-05-15
Last commit: 2d71525 feat: split dev environment flows by operating system
Scope: platforms/windows, platforms/macos, platforms/ubuntu
Area: CLI
-->

# CLI_01_platform_flows

## Purpose

This memory records the platform CLI flows and safety behavior implemented in the repository.

## Source Of Truth

- `platforms/windows/README.md`: Windows quick start and destructive command order.
- `platforms/windows/uninstall/lib.ps1`: Windows dry-run runner, winget helper, npm prefix helper, and safe removal guard.
- `platforms/windows/uninstall/00_discovery_inventory.ps1`: Windows inventory collection and local plan bootstrap.
- `platforms/windows/uninstall/part2_final/04_env_registry_path.ps1`: Windows registry, environment variable, and PATH cleanup.
- `platforms/macos/uninstall/lib.sh`: macOS dry-run runner, Homebrew helpers, and safe removal guard.
- `platforms/ubuntu/uninstall/lib.sh`: Ubuntu dry-run runner, apt purge helper, and safe removal guard.
- `platforms/macos/install/*.sh` and `platforms/ubuntu/install/*.sh`: OS-specific install flows.

## Entry Points

- Windows discovery: `powershell -ExecutionPolicy Bypass -File platforms/windows/uninstall/00_discovery_inventory.ps1`.
- Windows execute mode: add `-Execute` to each destructive PowerShell script.
- macOS discovery: `./platforms/macos/uninstall/00_discovery_inventory.sh`.
- macOS execute mode: add `--execute`.
- Ubuntu discovery: `./platforms/ubuntu/uninstall/00_discovery_inventory.sh`.
- Ubuntu execute mode: add `--execute`.

## Current Behavior

Windows discovery records commands including `node`, `npm`, `npx`, `python`, `py`, `pip`, `git`, `docker`, `wsl`, `codex`, `gemini`, `claude`, and `yc`; it also records npm global prefix and a bounded project-root overview. Windows safe removal blocks wildcards, non-absolute paths, critical roots, configured protected roots, and default project roots under the current user profile.

macOS scripts use Homebrew for native packages/casks and `nvm` for Node.js LTS. Ubuntu scripts use `apt-get` in scripts, Docker's official apt repository, and `nvm` for Node.js LTS. Ubuntu uninstall preserves the base OS `python3` runtime and only purges dev extras such as `python3-pip`, `python3-venv`, `python3-dev`, and user-level Python tooling.

## Contracts And Data

- `DEV_ENV_REBUILD_PROTECTED_PATHS` extends protected removal roots. Windows expects `;`-separated paths; macOS/Ubuntu expect `:`-separated paths.
- SSH install scripts create `~/.ssh/id_ed25519` only when the private key is absent. If the private key exists but `.pub` is missing, they regenerate the public key.
- `.claude`, `.codex`, and `.gemini` config directories are preserved by macOS/Ubuntu uninstall scripts. Windows Codex cleanup no longer removes `%USERPROFILE%\.codex` automatically.

## Invariants

- AI CLI npm packages are removed before removing Node/npm so npm-based tools can be uninstalled cleanly.
- Node/npm removal remains late in destructive flows.
- Project directories, `.git` directories, existing SSH keys, and AI config directories must not be removed without an explicit manual backup/inspection step.
- Ubuntu base `python3` must not be purged.

## Change Rules

- Keep OS-specific package-manager commands in the OS subtree; do not share destructive commands across OSes without an explicit compatibility layer.
- Use `run`, `run_shell`, or PowerShell `Run` wrappers for destructive actions so dry-run behavior stays consistent.
- Use safe path-removal helpers for user-directory cleanup unless the path is an intentional system tool data directory documented by the platform vendor, such as Docker data under `/var/lib/docker`.

## Verification

- `bash -n platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`: validates Bash syntax.
- `shellcheck platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`: validates shell quality.
- `./platforms/ubuntu/uninstall/00_discovery_inventory.sh`: validates Ubuntu discovery on an Ubuntu host.
- `./platforms/ubuntu/uninstall/01_uninstall_dev_environment.sh`: validates Ubuntu uninstall dry-run on an Ubuntu host.
- `./platforms/ubuntu/install/01_install_dev_environment.sh`: validates Ubuntu install dry-run on an Ubuntu host.

## Known Gaps

- PowerShell parse/runtime validation was not run in the Linux development environment because `pwsh`/`powershell` was not installed.
- macOS scripts were syntax-checked and shellchecked on Linux but not executed on a macOS host.
