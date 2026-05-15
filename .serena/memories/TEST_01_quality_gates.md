<!-- Memory Metadata
Last updated: 2026-05-15
Last commit: 0b4d41c fix: harden platform environment scripts
Scope: platforms/macos, platforms/ubuntu, platforms/windows, git diff checks
Area: TEST
-->

# TEST_01_quality_gates

## Purpose

This memory records the verification commands that apply after changes to this script-only repository.

## Source Of Truth

- `CONTRIBUTING.md`: dry-run and script safety expectations.
- `docs/architecture.md`: lifecycle, execute flags, and safety boundaries.
- `docs/research/os-tooling-research.md`: source-backed package-manager and installer facts.
- `platforms/macos/**/*.sh`: macOS shell scripts.
- `platforms/ubuntu/**/*.sh`: Ubuntu shell scripts.
- `platforms/windows/**/*.ps1`: Windows PowerShell scripts.

## Entry Points

- Shell syntax: `bash -n platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`.
- Shell lint: `shellcheck platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`.
- Diff hygiene: `git diff --check` or `git diff --cached --check`.
- Ubuntu safe behavior: run discovery and dry-run install/uninstall scripts without `--execute`.
- macOS safe behavior on Linux: simulate Darwin only for dry-run by prepending temporary fake `uname`, `sw_vers`, and `brew` shims; this is not a replacement for a real macOS host test.
- Windows availability check: `command -v pwsh || command -v powershell`.

## Current Behavior

The repository has no application test suite. Verification is script syntax, shell linting, diff hygiene, stale-reference searches, reviewer/static audits, and safe dry-run execution where the host OS matches the target platform or where macOS dry-run can be simulated without executing destructive commands.

## Contracts And Data

- macOS/Ubuntu shell scripts use `set -euo pipefail`.
- Dry-run commands must not require elevated permissions or mutate the machine.
- Generated `_state/` output is ignored and should not be staged.
- PowerShell runtime validation must be reported as blocked if neither `pwsh` nor `powershell` is available.
- Windows `.ps1` scripts should still be reviewed statically for exact WinGet IDs, `-Execute` behavior, and secret/config preservation when PowerShell runtime validation is blocked.

## Invariants

- Never report destructive flow success without running the matching post-check on the target OS.
- If PowerShell is unavailable on the development host, report Windows validation as blocked rather than implying it passed.
- If macOS is unavailable, report macOS real runtime validation as not executed.
- macOS/Ubuntu validation requested on the current Linux PC must use dry-run only and no `--execute`.

## Verification

- `bash -n platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`: Bash syntax.
- `shellcheck platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`: shell lint.
- `git diff --check`: unstaged diff hygiene.
- `git diff --cached --check`: staged diff hygiene.
- Ubuntu dry-run set: `./platforms/ubuntu/uninstall/00_discovery_inventory.sh`, `./platforms/ubuntu/uninstall/01_uninstall_dev_environment.sh`, `./platforms/ubuntu/install/01_install_dev_environment.sh`, `./platforms/ubuntu/install/02_install_ai_tools.sh`, and `./platforms/ubuntu/install/03_ssh_key.sh` without `--execute`.
- macOS simulated dry-run set: `./platforms/macos/uninstall/00_discovery_inventory.sh`, `./platforms/macos/uninstall/01_uninstall_dev_environment.sh`, `./platforms/macos/install/01_install_dev_environment.sh`, `./platforms/macos/install/02_install_ai_tools.sh`, and `./platforms/macos/install/03_ssh_key.sh` with temporary fake Darwin shims and without `--execute`.
- Static stale-risk search: `rg` for removed config deletion, secret env deletion, stale package versions, hardcoded user paths, and TODO/HACK markers.
- `command -v pwsh || command -v powershell`: checks whether Windows PowerShell validation can be run from the current host.

## Known Gaps

- Windows PowerShell scripts require a Windows or PowerShell-enabled host for full parse/runtime validation; this Linux environment currently lacks `pwsh`/`powershell`.
- macOS scripts require a real macOS host for full runtime validation; Linux simulation only proves dry-run branch behavior and OS guards.
