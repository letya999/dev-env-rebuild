#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR/lib.sh"

for arg in "$@"; do
  case "$arg" in
    --execute) DRY_RUN=0 ;;
    --help|-h)
      printf 'Usage: %s [--execute]\n' "$0"
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$arg" >&2
      exit 2
      ;;
  esac
done

require_ubuntu

printf 'Mode: %s\n' "$([ "$DRY_RUN" = "1" ] && printf 'DRY-RUN' || printf 'EXECUTE')"
printf 'Project directories, .git directories, existing SSH keys, ~/.claude, ~/.codex and ~/.gemini are not removed.\n'
printf 'Ubuntu base python3 runtime is not purged because it is OS-critical.\n'

step 'AI CLI npm packages before Node removal'
if command_exists npm; then
  run_shell 'npm uninstall -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli' \
    'npm uninstall -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli || true'
else
  printf 'npm not found, skipping npm global packages.\n'
fi

step 'Claude Code apt package and native installer files'
apt_purge claude-code
remove_path_safe "$HOME/.local/bin/claude"
remove_path_safe "$HOME/.local/share/claude"

step 'Docker Desktop and Docker Engine'
apt_purge docker-desktop docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
remove_path_safe "$HOME/.docker/desktop"
run 'Remove /usr/local/bin/com.docker.cli' sudo rm -f /usr/local/bin/com.docker.cli
run 'Remove /var/lib/docker' sudo rm -rf /var/lib/docker
run 'Remove /var/lib/containerd' sudo rm -rf /var/lib/containerd
printf 'Docker config file %s/.docker/config.json is not edited automatically; remove Docker Desktop credsStore/currentContext manually if needed.\n' "$HOME"

step 'Node.js through nvm and user npm data'
remove_path_safe "$HOME/.nvm"
remove_path_safe "$HOME/.npm"
remove_path_safe "$HOME/.npmrc"
remove_path_safe "$HOME/.yarn"
remove_path_safe "$HOME/.yarnrc"
remove_path_safe "$HOME/.pnpm-store"
remove_path_safe "$HOME/.pnpmrc"
remove_path_safe "$HOME/.bun"
apt_purge nodejs npm yarn pnpm

step 'Python dev extras and user tooling'
apt_purge python3-pip python3-venv python3-dev pipx
remove_path_safe "$HOME/.cache/pip"
remove_path_safe "$HOME/.local/pipx"
remove_path_safe "$HOME/.pyenv"

step 'Git and GitHub CLI'
apt_purge gh git
printf 'Git user config and credential stores are preserved: %s/.gitconfig, %s/.git-credentials.\n' "$HOME" "$HOME"

step 'Yandex Cloud CLI'
remove_path_safe "$HOME/yandex-cloud"
remove_path_safe "$HOME/.config/yc"

step 'Autoremove'
run_shell 'sudo apt-get autoremove --purge -y' 'sudo apt-get autoremove --purge -y'

step 'Configuration directories intentionally preserved'
printf '%s/.claude, %s/.codex and %s/.gemini are preserved. Back them up and inspect manually if full config cleanup is required.\n' "$HOME" "$HOME" "$HOME"
printf 'Restart the shell after execute mode, then run ./platforms/ubuntu/uninstall/02_post_uninstall_check.sh\n'
