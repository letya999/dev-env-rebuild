#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=1
SKIP_YC=0
SKIP_CLAUDE=0
SKIP_CODEX=0
SKIP_GEMINI=0

for arg in "$@"; do
  case "$arg" in
    --execute) DRY_RUN=0 ;;
    --skip-yc) SKIP_YC=1 ;;
    --skip-claude) SKIP_CLAUDE=1 ;;
    --skip-codex) SKIP_CODEX=1 ;;
    --skip-gemini) SKIP_GEMINI=1 ;;
    --help|-h)
      printf 'Usage: %s [--execute] [--skip-yc] [--skip-claude] [--skip-codex] [--skip-gemini]\n' "$0"
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$arg" >&2
      exit 2
      ;;
  esac
done

if [ ! -r /etc/os-release ]; then
  printf 'ERROR: cannot detect OS; /etc/os-release is missing.\n' >&2
  exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release
if [ "${ID:-}" != "ubuntu" ]; then
  printf 'ERROR: this script is Ubuntu-specific. Detected ID=%s.\n' "${ID:-unknown}" >&2
  exit 1
fi

run_shell() {
  local description="$1"
  local command="$2"
  if [ "$DRY_RUN" = "0" ]; then
    printf 'Action: %s\n' "$description"
    bash -lc "$command"
  else
    printf 'DRY-RUN: %s\n' "$description"
  fi
}

# shellcheck disable=SC2016
load_nvm='export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'

if [ "$SKIP_CLAUDE" = "0" ]; then
  run_shell 'Install Claude Code through official apt repository' \
    'sudo install -d -m 0755 /etc/apt/keyrings && sudo curl -fsSL https://downloads.claude.ai/keys/claude-code.asc -o /etc/apt/keyrings/claude-code.asc && echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" | sudo tee /etc/apt/sources.list.d/claude-code.list >/dev/null && sudo apt-get update && sudo apt-get install -y claude-code'
fi
[ "$SKIP_CODEX" = "1" ] || run_shell 'npm install -g @openai/codex' \
  "$load_nvm; npm install -g @openai/codex"
[ "$SKIP_GEMINI" = "1" ] || run_shell 'npm install -g @google/gemini-cli' \
  "$load_nvm; npm install -g @google/gemini-cli"
[ "$SKIP_YC" = "1" ] || run_shell 'Install Yandex Cloud CLI' \
  'curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash'

printf '\nRestart the shell after execute mode, then run ./platforms/ubuntu/install/04_final_check.sh\n'
