# macOS implementation

macOS has its own implementation because package management, Docker Desktop,
shell startup files, and user data paths differ from Windows and Ubuntu.

Run commands from the repository root.

## Flow

Dry-run first:

```bash
./platforms/macos/uninstall/00_discovery_inventory.sh
./platforms/macos/uninstall/01_uninstall_dev_environment.sh
./platforms/macos/install/01_install_dev_environment.sh
./platforms/macos/install/02_install_ai_tools.sh
./platforms/macos/install/03_ssh_key.sh
```

Execute only after reviewing generated `_state` files and dry-run output:

```bash
./platforms/macos/uninstall/01_uninstall_dev_environment.sh --execute
./platforms/macos/uninstall/02_post_uninstall_check.sh

./platforms/macos/install/01_install_dev_environment.sh --execute --install-homebrew
./platforms/macos/install/02_install_ai_tools.sh --execute
./platforms/macos/install/03_ssh_key.sh --execute
./platforms/macos/install/04_final_check.sh
```

All destructive scripts are dry-run by default. Add `--execute` only after
reviewing `platforms/macos/_state/inventory.md` and `_state/local_plan.md`.

## Safety boundaries

The uninstall scripts do not remove project directories, `.git` directories,
existing SSH keys, `.claude`, `.codex`, or `.gemini` configuration directories.
Node is managed through `nvm` on macOS to avoid global npm permission problems.
