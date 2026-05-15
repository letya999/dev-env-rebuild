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

require_macos

printf 'Mode: %s\n' "$([ "$DRY_RUN" = "1" ] && printf 'DRY-RUN' || printf 'EXECUTE')"
printf 'Project directories, .git directories, existing SSH keys, ~/.claude, ~/.codex and ~/.gemini are not removed.\n'

step 'AI CLI npm packages before Node removal'
if command_exists npm; then
  run_shell 'npm uninstall -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli' \
    'npm uninstall -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli || true'
else
  printf 'npm not found, skipping npm global packages.\n'
fi

step 'Claude Code and desktop apps installed through Homebrew'
brew_uninstall_cask claude-code
brew_uninstall_cask claude
brew_uninstall_cask chatgpt

step 'Docker Desktop'
if [ -x /Applications/Docker.app/Contents/MacOS/uninstall ]; then
  run '/Applications/Docker.app/Contents/MacOS/uninstall' /Applications/Docker.app/Contents/MacOS/uninstall
else
  printf 'Docker Desktop CLI uninstaller not found.\n'
fi
brew_uninstall_cask docker
remove_path_safe "$HOME/Library/Group Containers/group.com.docker"
remove_path_safe "$HOME/.docker"

step 'Node.js and JS package managers'
remove_path_safe "$HOME/.nvm"
remove_path_safe "$HOME/.npm"
remove_path_safe "$HOME/.npmrc"
remove_path_safe "$HOME/.yarn"
remove_path_safe "$HOME/.yarnrc"
remove_path_safe "$HOME/.pnpm-store"
remove_path_safe "$HOME/.pnpmrc"
remove_path_safe "$HOME/.bun"
brew_uninstall_formula node
brew_uninstall_formula yarn
brew_uninstall_formula pnpm
brew_uninstall_formula bun

step 'Python user tooling'
remove_path_safe "$HOME/Library/Caches/pip"
remove_path_safe "$HOME/.cache/pip"
remove_path_safe "$HOME/Library/Python"
remove_path_safe "$HOME/.pyenv"
brew_uninstall_formula python@3.12
brew_uninstall_formula python

step 'Git and GitHub CLI'
brew_uninstall_formula gh
brew_uninstall_formula git
remove_path_safe "$HOME/.gitconfig"
remove_path_safe "$HOME/.git-credentials"

step 'Yandex Cloud CLI'
remove_path_safe "$HOME/yandex-cloud"
remove_path_safe "$HOME/.config/yc"

step 'Configuration directories intentionally preserved'
printf '%s/.claude, %s/.codex and %s/.gemini are preserved. Back them up and inspect manually if full config cleanup is required.\n' "$HOME" "$HOME" "$HOME"
printf 'Restart the terminal after execute mode, then run ./platforms/macos/uninstall/02_post_uninstall_check.sh\n'
