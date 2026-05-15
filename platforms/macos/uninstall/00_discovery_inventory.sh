#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_DIR="$PLATFORM_ROOT/_state"
mkdir -p "$STATE_DIR"

INVENTORY_MD="$STATE_DIR/inventory.md"
INVENTORY_JSON="$STATE_DIR/inventory.json"
LOCAL_PLAN="$STATE_DIR/local_plan.md"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

command_paths() {
  local cmd="$1"
  type -a -p "$cmd" 2>/dev/null | paste -sd ', ' -
}

command_version() {
  local cmd="$1"
  shift
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf 'not found'
    return 0
  fi
  local arg
  for arg in "$@"; do
    if "$cmd" "$arg" >/tmp/dev-env-version.$$ 2>&1; then
      head -n 3 /tmp/dev-env-version.$$ | tr '\n' ' '
      rm -f /tmp/dev-env-version.$$
      return 0
    fi
  done
  rm -f /tmp/dev-env-version.$$
  printf 'installed, version unavailable'
}

commands=(node npm npx python3 python pip3 pip git gh docker brew claude codex gemini yc)

{
  printf '# macOS Inventory Report\n\n'
  printf 'Generated: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'User: %s\n' "${USER:-unknown}"
  printf 'OS: %s\n\n' "$(sw_vers -productName 2>/dev/null) $(sw_vers -productVersion 2>/dev/null)"

  printf '## Commands\n'
  for cmd in "${commands[@]}"; do
    printf '### %s\n' "$cmd"
    printf -- '- Paths: %s\n' "$(command_paths "$cmd")"
    case "$cmd" in
      node|npm|npx) version="$(command_version "$cmd" -v --version)" ;;
      *) version="$(command_version "$cmd" --version -v)" ;;
    esac
    printf -- '- Version: %s\n' "$version"
  done

  printf '\n## Homebrew\n'
  if command -v brew >/dev/null 2>&1; then
    printf -- '- Prefix: %s\n' "$(brew --prefix 2>/dev/null)"
    printf -- '- Formulae: %s\n' "$(brew list --formula 2>/dev/null | tr '\n' ' ')"
    printf -- '- Casks: %s\n' "$(brew list --cask 2>/dev/null | tr '\n' ' ')"
  else
    printf -- '- not found\n'
  fi

  printf '\n## Existing Paths\n'
  for path in \
    "$HOME/.nvm" "$HOME/.npm" "$HOME/.npmrc" "$HOME/.cache/pip" \
    "$HOME/Library/Caches/pip" "$HOME/Library/Python" "$HOME/.pyenv" \
    "$HOME/.docker" "$HOME/Library/Group Containers/group.com.docker" \
    "$HOME/yandex-cloud" "$HOME/.config/yc" \
    "$HOME/.claude" "$HOME/.codex" "$HOME/.gemini"; do
    [ -e "$path" ] && printf -- '- %s\n' "$path"
  done

  printf '\n## Project Root Overview\n'
  for root in "$HOME/a_projects" "$HOME/projects" "$HOME/Projects" "$HOME/Desktop/projects" "$HOME/Documents/projects"; do
    if [ -d "$root" ]; then
      sample=""
      while IFS= read -r child; do
        sample="${sample}$(basename "$child") "
      done < <(find "$root" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | head -n 20 || true)
      printf -- '- %s: exists; sample: %s\n' "$root" "$sample"
    else
      printf -- '- %s: not found\n' "$root"
    fi
  done
} > "$INVENTORY_MD"

{
  printf '{\n'
  printf '  "generatedAt": "%s",\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '  "os": "macos",\n'
  printf '  "user": "%s",\n' "$(json_escape "${USER:-unknown}")"
  printf '  "commands": [\n'
  first=1
  for cmd in "${commands[@]}"; do
    [ "$first" -eq 0 ] && printf ',\n'
    first=0
    printf '    {"name":"%s","paths":"%s"}' "$cmd" "$(json_escape "$(command_paths "$cmd")")"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$INVENTORY_JSON"

if [ ! -f "$LOCAL_PLAN" ]; then
  cat > "$LOCAL_PLAN" <<'PLAN'
# Локальный план адаптации macOS

Заполнить после анализа inventory.md и inventory.json:

- какие инструменты реально установлены;
- какой Homebrew prefix используется;
- где установлен Node/nvm/npm global;
- какие Docker/AI/Yandex остатки есть;
- какие команды безопасно запускать с --execute.
PLAN
fi

printf 'Inventory complete: %s\n' "$STATE_DIR"
