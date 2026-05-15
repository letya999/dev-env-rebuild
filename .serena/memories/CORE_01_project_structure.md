<!-- Memory Metadata
Last updated: 2026-05-15
Last commit: b32017e Merge platform environment rebuild flows
Scope: README.md, docs/architecture.md, platforms/, .github/workflows/platform-validation.yml
Area: CORE
-->

# CORE_01_project_structure

## Purpose

This repository contains demonstrational dev-environment rebuild flows split by operating system. Each supported OS owns its own discovery, uninstall, install, and verification scripts.

## Source Of Truth

- `README.md`: top-level project overview, quick starts, safety contract, supported platforms, and validation summary.
- `docs/architecture.md`: repository layout, lifecycle, execute flags, safety boundaries, and OS-specific decisions.
- `platforms/windows/`: Windows-specific PowerShell implementation.
- `platforms/macos/`: macOS-specific Bash implementation.
- `platforms/ubuntu/`: Ubuntu-specific Bash implementation.
- `docs/research/os-tooling-research.md`: source-backed package-manager and CLI installation/uninstall decisions.
- `.github/workflows/platform-validation.yml`: native-platform CI validation workflow.

## Entry Points

- `platforms/<os>/uninstall/00_discovery_inventory.*`: creates local machine inventory and `_state/local_plan.md` for that OS.
- `platforms/<os>/uninstall/*`: dry-run-first uninstall flow.
- `platforms/<os>/install/*`: demo install flow and final checks.
- `.github/workflows/platform-validation.yml`: validates shell scripts, platform dry-runs, and Windows PowerShell parser/dry-runs on GitHub Actions runners when available.

## Current Behavior

Generated machine state is written under `platforms/<os>/_state/` and ignored by `.gitignore`. Root legacy directories `01_uninstall` and `02_install` were migrated into `platforms/windows/uninstall` and `platforms/windows/install` respectively. Windows docs were moved into `docs/windows/` and research sources into `docs/research/`.

`main` intentionally does not track root `AGENTS.md` or `.serena` knowledge; these agent-only files are restored locally from `fullrepo` and synchronized back to `fullrepo` after meaningful project changes.

## Contracts And Data

- Windows destructive scripts use PowerShell `-Execute` for real changes.
- macOS and Ubuntu destructive scripts use Bash `--execute` for real changes.
- Without the execute flag, destructive scripts must run as dry-run.
- Platform-specific generated files live in `platforms/<os>/_state/`.
- Pull requests to `main` run native-platform validation through `.github/workflows/platform-validation.yml` when GitHub Actions runners can start.

## Invariants

- Keep OS-specific implementation nested under `platforms/<os>/`.
- Do not reintroduce root-level `01_uninstall` or `02_install` implementation directories.
- Do not commit machine-specific `_state/` inventory output.
- Product branches must not track agent-only files such as root `AGENTS.md` or `.serena` knowledge.
- Full agent-only context is preserved through the `fullrepo` branch.

## Change Rules

- Add new OS behavior under the matching `platforms/<os>/` subtree.
- Update `README.md` and `docs/architecture.md` when lifecycle, structure, validation, or safety contracts change.
- Keep source-backed decisions in `docs/research/os-tooling-research.md` when package-manager or external CLI installation behavior changes.
- Keep `.github/workflows/platform-validation.yml` aligned with supported platform entry points.

## Verification

- `git diff --cached --check`: verifies staged whitespace and conflict-marker cleanliness before commit.
- `actionlint .github/workflows/platform-validation.yml`: verifies GitHub Actions workflow syntax and semantics.
- `rg -n "01_uninstall|02_install|MANUAL_SETUP_GUIDE|UNINSTALL_MANUAL_RUN|sources\.txt" README.md CONTRIBUTING.md docs platforms`: checks for stale root-path references; expected matches may include new script filenames that contain `01_uninstall` in their basename.
