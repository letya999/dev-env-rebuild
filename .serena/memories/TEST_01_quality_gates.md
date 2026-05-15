<!-- Memory Metadata
Last updated: 2026-05-15
Last commit: 2d71525 feat: split dev environment flows by operating system
Scope: platforms/macos, platforms/ubuntu, platforms/windows, git diff checks
Area: TEST
-->

# TEST_01_quality_gates

## Purpose

This memory records the verification commands that apply after changes to this script-only repository.

## Source Of Truth

- `CONTRIBUTING.md`: dry-run and script safety expectations.
- `docs/architecture.md`: lifecycle and execute flags.
- `platforms/macos/**/*.sh`: macOS shell scripts.
- `platforms/ubuntu/**/*.sh`: Ubuntu shell scripts.
- `platforms/windows/**/*.ps1`: Windows PowerShell scripts.

## Entry Points

- Shell syntax: `bash -n platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`.
- Shell lint: `shellcheck platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`.
- Diff hygiene: `git diff --check` or `git diff --cached --check`.
- Ubuntu safe behavior: run discovery and dry-run install/uninstall scripts without `--execute`.

## Current Behavior

The repository has no application test suite. Verification is script syntax, shell linting, diff hygiene, stale-reference searches, and safe dry-run execution where the host OS matches the target platform.

## Contracts And Data

- macOS/Ubuntu shell scripts use `set -euo pipefail`.
- Dry-run commands must not require elevated permissions or mutate the machine.
- Generated `_state/` output is ignored and should not be staged.

## Invariants

- Never report destructive flow success without running the matching post-check on the target OS.
- If PowerShell is unavailable on the development host, report Windows validation as blocked rather than implying it passed.
- If macOS is unavailable, report macOS runtime validation as not executed.

## Verification

- `bash -n platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`: Bash syntax.
- `shellcheck platforms/macos/uninstall/*.sh platforms/macos/install/*.sh platforms/ubuntu/uninstall/*.sh platforms/ubuntu/install/*.sh`: shell lint.
- `./platforms/ubuntu/uninstall/00_discovery_inventory.sh && ./platforms/ubuntu/uninstall/01_uninstall_dev_environment.sh && ./platforms/ubuntu/install/01_install_dev_environment.sh`: Ubuntu discovery plus dry-run uninstall/install.
- `command -v pwsh || command -v powershell`: checks whether Windows PowerShell validation can be run from the current host.
- `git diff --cached --check`: staged diff hygiene.

## Known Gaps

- Windows PowerShell scripts require a Windows or PowerShell-enabled host for full parse/runtime validation.
- macOS scripts require a macOS host for full runtime validation.
