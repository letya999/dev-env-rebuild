# Architecture

The repository is organized by operating system. Each platform owns its own
install, uninstall, discovery, and verification scripts.

```text
platforms/<os>/
  README.md
  uninstall/
  install/
```

## Shared lifecycle

1. Run discovery.
2. Review generated `_state/inventory.md`, `_state/inventory.json`, and
   `_state/local_plan.md`.
3. Run destructive scripts in dry-run mode.
4. Repeat with the explicit execute flag.
5. Restart the OS session when required.
6. Run post-uninstall or final install checks.

## Execute flags

- Windows: `-Execute`
- macOS: `--execute`
- Ubuntu: `--execute`

## Safety boundaries

Scripts must not remove:

- project directories;
- `.git` directories;
- existing SSH keys;
- `.claude`, `.codex`, `.gemini` config directories;
- root user/system directories.

Platform scripts may remove tool caches, package-manager state, and app data
only when the path is specific to the tool being removed.

## OS-specific decisions

- Windows uses `winget`, WSL commands, and Docker Desktop cleanup paths.
- macOS uses Homebrew for native packages and `nvm` for Node.js.
- Ubuntu uses `apt-get` for scripts, Docker's official apt repository, and
  `nvm` for Node.js. The base `python3` runtime is preserved because it is
  part of the operating system contract.
