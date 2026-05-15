# Ubuntu implementation

Ubuntu has its own implementation because `apt`, Docker Engine, system Python,
and user shell configuration differ from Windows and macOS.

Run commands from the repository root.

## Flow

Dry-run first:

```bash
./platforms/ubuntu/uninstall/00_discovery_inventory.sh
./platforms/ubuntu/uninstall/01_uninstall_dev_environment.sh
./platforms/ubuntu/install/01_install_dev_environment.sh
./platforms/ubuntu/install/02_install_ai_tools.sh
./platforms/ubuntu/install/03_ssh_key.sh
```

Execute only after reviewing generated `_state` files and dry-run output:

```bash
./platforms/ubuntu/uninstall/01_uninstall_dev_environment.sh --execute
./platforms/ubuntu/uninstall/02_post_uninstall_check.sh

./platforms/ubuntu/install/01_install_dev_environment.sh --execute
./platforms/ubuntu/install/02_install_ai_tools.sh --execute
./platforms/ubuntu/install/03_ssh_key.sh --execute
./platforms/ubuntu/install/04_final_check.sh
```

All destructive scripts are dry-run by default. Add `--execute` only after
reviewing `platforms/ubuntu/_state/inventory.md` and `_state/local_plan.md`.

## Ubuntu-specific rule

The uninstall script does not purge the OS-critical `python3` base runtime.
It only removes dev-facing Python extras installed by this project
(`python3-pip`, `python3-venv`, `python3-dev`) and user-level caches/managers.
