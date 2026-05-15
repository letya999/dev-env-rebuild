#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=1
INSTALL_HOMEBREW=0
NVM_INSTALL_VERSION="${NVM_INSTALL_VERSION:-v0.40.3}"

for arg in "$@"; do
  case "$arg" in
    --execute) DRY_RUN=0 ;;
    --install-homebrew) INSTALL_HOMEBREW=1 ;;
    --help|-h)
      printf 'Usage: %s [--execute] [--install-homebrew]\n' "$0"
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$arg" >&2
      exit 2
      ;;
  esac
done

if [ "$(uname -s)" != "Darwin" ]; then
  printf 'ERROR: this script is macOS-specific.\n' >&2
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

step() { printf '\n=== %s ===\n' "$1"; }

# shellcheck disable=SC2016
brew_env='if command -v brew >/dev/null 2>&1; then :; elif [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; elif [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi'

step 'Homebrew'
if ! command -v brew >/dev/null 2>&1; then
  if [ "$INSTALL_HOMEBREW" = "1" ]; then
    # shellcheck disable=SC2016
    run_shell 'Install Homebrew using official installer' \
      '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  else
    printf 'Homebrew is not installed. Re-run with --install-homebrew to install it.\n'
    [ "$DRY_RUN" = "1" ] || exit 1
  fi
else
  printf 'brew found: %s\n' "$(brew --prefix)"
fi

step 'Base packages'
run_shell 'brew install git python@3.12' "$brew_env; brew install git python@3.12"
run_shell 'brew install --cask docker' "$brew_env; brew install --cask docker"

step 'Node.js LTS through nvm'
run_shell 'Install nvm and latest LTS Node.js' \
  "export NVM_DIR=\"\$HOME/.nvm\"; if [ ! -s \"\$NVM_DIR/nvm.sh\" ]; then curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_INSTALL_VERSION}/install.sh | bash; fi; . \"\$NVM_DIR/nvm.sh\"; nvm install --lts; nvm alias default 'lts/*'; nvm use default; node -v; npm -v"

printf '\nRestart the terminal after execute mode, then run ./platforms/macos/install/02_install_ai_tools.sh --execute\n'
