#!/usr/bin/env bash

set -euo pipefail

DRY_RUN="${DRY_RUN:-1}"

step() {
  printf '\n=== %s ===\n' "$1"
}

is_execute() {
  [ "${DRY_RUN}" = "0" ]
}

run() {
  local description="$1"
  shift
  if is_execute; then
    printf 'Action: %s\n' "$description"
    "$@"
  else
    printf 'DRY-RUN: %s\n' "$description"
  fi
}

run_shell() {
  local description="$1"
  local command="$2"
  if is_execute; then
    printf 'Action: %s\n' "$description"
    bash -lc "$command"
  else
    printf 'DRY-RUN: %s\n' "$description"
  fi
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_brew_path() {
  if command_exists brew; then
    return 0
  fi
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

require_macos() {
  if [ "$(uname -s)" != "Darwin" ]; then
    printf 'ERROR: this script is macOS-specific.\n' >&2
    exit 1
  fi
}

same_or_child_path() {
  local candidate="${1%/}"
  local parent="${2%/}"
  [ "$candidate" = "$parent" ] || [[ "$candidate" == "$parent"/* ]]
}

protected_paths() {
  printf '%s\n' \
    "$HOME/a_projects" \
    "$HOME/projects" \
    "$HOME/Projects" \
    "$HOME/Desktop/projects" \
    "$HOME/Documents/projects" \
    "$HOME/.agents" \
    "$HOME/.ai_backup"

  if [ -n "${DEV_ENV_REBUILD_PROTECTED_PATHS:-}" ]; then
    printf '%s\n' "$DEV_ENV_REBUILD_PROTECTED_PATHS" | tr ':' '\n'
  fi
}

remove_path_safe() {
  local path="$1"
  if [ -z "$path" ]; then
    printf 'BLOCKED: empty removal path\n' >&2
    return 0
  fi
  case "$path" in
    *'*'*|*'?'*|*'['*|*']'*)
      printf 'BLOCKED: wildcard removal path is not allowed: %s\n' "$path" >&2
      return 0
      ;;
  esac
  case "$path" in
    "$HOME"|"$HOME/"|"/"|"/Applications"|"/Library"|"/usr"|"/usr/local"|"/opt"|"/opt/homebrew")
      printf 'BLOCKED: refusing to remove critical root: %s\n' "$path" >&2
      return 0
      ;;
  esac

  local protected
  while IFS= read -r protected; do
    [ -z "$protected" ] && continue
    if same_or_child_path "$path" "$protected"; then
      printf 'BLOCKED: %s is inside protected directory %s\n' "$path" "$protected" >&2
      return 0
    fi
    if same_or_child_path "$protected" "$path"; then
      printf 'BLOCKED: %s contains protected directory %s\n' "$path" "$protected" >&2
      return 0
    fi
  done < <(protected_paths)

  run "Remove: $path" rm -rf "$path"
}

brew_uninstall_formula() {
  local formula="$1"
  ensure_brew_path
  if ! command_exists brew; then
    printf 'brew not found, skipping formula %s\n' "$formula"
    return 0
  fi
  run_shell "brew uninstall --force $formula" "brew list --formula '$formula' >/dev/null 2>&1 && brew uninstall --force '$formula' || true"
}

brew_uninstall_cask() {
  local cask="$1"
  ensure_brew_path
  if ! command_exists brew; then
    printf 'brew not found, skipping cask %s\n' "$cask"
    return 0
  fi
  run_shell "brew uninstall --cask --force $cask" "brew list --cask '$cask' >/dev/null 2>&1 && brew uninstall --cask --force '$cask' || true"
}
