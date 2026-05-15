<!-- Memory Metadata
Last updated: 2026-05-15
Last commit: 0b4d41c fix: harden platform environment scripts
Scope: platforms/windows, platforms/macos, platforms/ubuntu
Area: CLI
-->

# CLI_01_platform_flows

## Purpose

This memory records the platform CLI flows and safety behavior implemented in the repository.

## Source Of Truth

- `platforms/windows/README.md`: Windows quick start and platform scope.
- `platforms/windows/uninstall/lib.ps1`: Windows dry-run runner, exact WinGet uninstall helpers, npm prefix helper, and safe removal guard.
- `platforms/windows/uninstall/00_discovery_inventory.ps1`: Windows inventory collection and local plan bootstrap.
- `platforms/windows/uninstall/part2_final/04_env_registry_path.ps1`: Windows registry, environment variable, and PATH cleanup.
- `platforms/macos/uninstall/lib.sh`: macOS dry-run runner, Homebrew helpers, and safe removal guard.
- `platforms/ubuntu/uninstall/lib.sh`: Ubuntu dry-run runner, apt purge helper, and safe removal guard.
- `platforms/macos/install/*.sh` and `platforms/ubuntu/install/*.sh`: OS-specific install flows.
- `docs/research/os-tooling-research.md`: source-backed package manager and vendor command decisions.

## Entry Points

- Windows discovery: `powershell -ExecutionPolicy Bypass -File platforms/windows/uninstall/00_discovery_inventory.ps1`.
- Windows execute mode: add `-Execute` to each destructive PowerShell script.
- Windows secret cleanup: add `-RemoveSecrets` to `platforms/windows/uninstall/part2_final/04_env_registry_path.ps1` only when secret env var deletion is explicitly requested.
- macOS discovery: `./platforms/macos/uninstall/00_discovery_inventory.sh`.
- macOS execute mode: add `--execute`.
- Ubuntu discovery: `./platforms/ubuntu/uninstall/00_discovery_inventory.sh`.
- Ubuntu execute mode: add `--execute`.

## Current Behavior

Windows discovery records commands including `node`, `npm`, `npx`, `python`, `py`, `pip`, `git`, `docker`, `wsl`, `codex`, `gemini`, `claude`, and `yc`; it also records npm global prefix and a bounded project-root overview. Windows safe removal blocks wildcards, non-absolute paths, critical roots, configured protected roots, and default project roots under the current user profile.

Windows uninstall uses exact WinGet IDs where available: `Python.Python.3.14`, `Python.Python.3.13`, `Python.Python.3.12`, `Python.Launcher`, `Git.Git`, `GitHub.cli`, `Docker.DockerDesktop`, `Microsoft.WSL`, `Oven-sh.Bun`, `OpenAI.Codex`, `Anthropic.Claude`, `Anthropic.ClaudeCode`, and `OpenJS.NodeJS.LTS`. WinGet calls use `-e --source winget --disable-interactivity`; install scripts throw on missing WinGet or failed required WinGet installs.

Windows Docker cleanup runs Docker Desktop's official CLI uninstaller when `C:\Program Files\Docker\Docker\Docker Desktop Installer.exe` exists, then falls back to exact WinGet uninstall and vendor-documented residual paths. WSL unregister logic guards missing `wsl.exe` and strips null characters from `wsl --list --quiet` output.

Windows yc CLI install uses the Yandex Cloud scriptless zip path (`yc_windows_amd64.zip` or `yc_windows_386.zip`) and adds the install directory to User `PATH`, avoiding the interactive `install.ps1` PATH prompt.

macOS scripts use Homebrew for native packages/casks and `nvm` for Node.js LTS. Homebrew Python install uses the default `python` formula rather than pinning `python@3.x`; uninstall still removes legacy `python@3.12`, `python@3.13`, and `python@3.14` formulae when present. macOS discovery/install/check scripts have Darwin guards. macOS post-uninstall treats system/Xcode `python3`, `pip3`, and `git` as informational because they may remain after Homebrew cleanup.

Ubuntu scripts use `apt-get` in scripts, Docker's official apt repository, and `nvm` for Node.js LTS. Ubuntu uninstall preserves the base OS `python3` runtime and only purges dev extras such as `python3-pip`, `python3-venv`, `python3-dev`, and user-level Python tooling. Ubuntu scripts have Ubuntu `/etc/os-release` guards. Docker and Claude apt repository keys are checked against published fingerprints before the repositories are trusted.

Yandex Cloud CLI install on macOS/Ubuntu uses `bash -s -- -a` so PATH/completion can be added non-interactively to the default shell rc file.

## Contracts And Data

- `DEV_ENV_REBUILD_PROTECTED_PATHS` extends protected removal roots. Windows expects `;`-separated paths; macOS/Ubuntu expect `:`-separated paths.
- SSH install scripts create `~/.ssh/id_ed25519` only when the private key is absent. If the private key exists but `.pub` is missing, they regenerate the public key.
- `.claude`, `.codex`, and `.gemini` config directories are preserved by uninstall scripts unless a separate manual backup/inspection cleanup is requested.
- Git user config and credential stores (`~/.gitconfig`, `~/.git-credentials`, Git Credential Manager data) are preserved by default.
- Secret environment variables (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `YC_TOKEN`) are preserved by default and require explicit Windows `-RemoveSecrets`.

## Invariants

- AI CLI npm packages are removed before removing Node/npm so npm-based tools can be uninstalled cleanly.
- Node/npm removal remains late in destructive flows.
- Project directories, `.git` directories, existing SSH keys, Git config/credentials, secret env vars, and AI config directories must not be removed without an explicit manual request.
- Ubuntu base `python3` must not be purged.
- Third-party apt repository signing keys must be fingerprint-verified before package install.

## Change Rules

- Keep OS-specific package-manager commands in the OS subtree; do not share destructive commands across OSes without an explicit compatibility layer.
- Use `run`, `run_shell`, or PowerShell `Run` wrappers for destructive actions so dry-run behavior stays consistent.
- Use safe path-removal helpers for user-directory cleanup unless the path is an intentional system tool data directory documented by the platform vendor, such as Docker data under `/var/lib/docker`.
- Before changing package IDs or installer URLs, update `docs/research/os-tooling-research.md` with source-backed facts.

## Verification

- `bash -n platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`: validates Bash syntax.
- `shellcheck platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`: validates shell quality.
- `git diff --check`: validates diff hygiene.
- macOS dry-run can be simulated on Linux by shadowing `uname`, `sw_vers`, and `brew`; this validates dry-run output and OS-guard behavior but is not a real macOS runtime test.
- Ubuntu discovery, uninstall dry-run, install dry-run, AI install dry-run, and SSH dry-run are run without `--execute` on an Ubuntu host.
- `command -v pwsh || command -v powershell` checks whether Windows PowerShell validation can be run from the current host.

## Known Gaps

- PowerShell parse/runtime validation was not run in the Linux development environment because `pwsh`/`powershell` was not installed.
- macOS scripts were syntax-checked, shellchecked, and simulated in dry-run on Linux but not executed on a real macOS host.
