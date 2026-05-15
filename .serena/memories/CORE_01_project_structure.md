<!-- Memory Metadata
Last updated: 2026-05-15
Last commit: 2d71525 feat: split dev environment flows by operating system
Scope: README.md, docs/architecture.md, platforms/
Area: CORE
-->

# CORE_01_project_structure

## Purpose

This repository contains demonstrational dev-environment rebuild flows split by operating system. Each supported OS owns its own discovery, uninstall, install, and verification scripts.

## Source Of Truth

- `README.md`: top-level project overview, quick starts, safety contract, and supported platforms.
- `docs/architecture.md`: repository layout, lifecycle, execute flags, safety boundaries, and OS-specific decisions.
- `platforms/windows/`: Windows-specific PowerShell implementation.
- `platforms/macos/`: macOS-specific Bash implementation.
- `platforms/ubuntu/`: Ubuntu-specific Bash implementation.
- `docs/research/os-tooling-research.md`: source-backed package-manager and CLI installation/uninstall decisions.

## Entry Points

- `platforms/<os>/uninstall/00_discovery_inventory.*`: creates local machine inventory and `_state/local_plan.md` for that OS.
- `platforms/<os>/uninstall/*`: dry-run-first uninstall flow.
- `platforms/<os>/install/*`: demo install flow and final checks.

## Current Behavior

Generated machine state is written under `platforms/<os>/_state/` and ignored by `.gitignore`. Root legacy directories `01_uninstall` and `02_install` were migrated into `platforms/windows/uninstall` and `platforms/windows/install` respectively. Windows docs were moved into `docs/windows/` and research sources into `docs/research/`.

## Contracts And Data

- Windows destructive scripts use PowerShell `-Execute` for real changes.
- macOS and Ubuntu destructive scripts use Bash `--execute` for real changes.
- Without the execute flag, destructive scripts must run as dry-run.
- Platform-specific generated files live in `platforms/<os>/_state/`.

## Invariants

- Keep OS-specific implementation nested under `platforms/<os>/`.
- Do not reintroduce root-level `01_uninstall` or `02_install` implementation directories.
- Do not commit machine-specific `_state/` inventory output.
- Product branches must not track agent-only files such as root `AGENTS.md` or `.serena` knowledge.

## Change Rules

- Add new OS behavior under the matching `platforms/<os>/` subtree.
- Update `README.md` and `docs/architecture.md` when lifecycle, structure, or safety contracts change.
- Keep source-backed decisions in `docs/research/os-tooling-research.md` when package-manager or external CLI installation behavior changes.

## Verification

- `git diff --cached --check`: verifies staged whitespace and conflict-marker cleanliness before commit.
- `rg -n "01_uninstall|02_install|MANUAL_SETUP_GUIDE|UNINSTALL_MANUAL_RUN|sources\.txt" README.md CONTRIBUTING.md docs platforms`: checks for stale root-path references; expected matches may include new script filenames that contain `01_uninstall` in their basename.
