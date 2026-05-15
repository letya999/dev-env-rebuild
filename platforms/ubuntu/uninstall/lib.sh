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

require_ubuntu() {
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
    "$HOME"|"$HOME/"|"/"|"/home"|"/usr"|"/usr/local"|"/opt"|"/var"|"/var/lib")
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

apt_purge() {
  local packages="$*"
  run_shell "sudo apt-get purge -y $packages" "sudo apt-get purge -y $packages || true"
}
