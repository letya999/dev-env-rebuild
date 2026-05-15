#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_DIR="$PLATFORM_ROOT/_state"

if [ ! -r /etc/os-release ]; then
  printf 'ERROR: cannot detect OS; /etc/os-release is missing.\n' >&2
  exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release
if [ "${ID:-}" != "ubuntu" ]; then
  printf 'ERROR: this discovery script is Ubuntu-specific. Detected ID=%s.\n' "${ID:-unknown}" >&2
  exit 1
fi

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
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/dev-env-version.XXXXXX")"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    rm -f "$tmp"
    printf 'not found'
    return 0
  fi
  local arg
  for arg in "$@"; do
    if "$cmd" "$arg" >"$tmp" 2>&1; then
      head -n 3 "$tmp" | tr '\n' ' '
      rm -f "$tmp"
      return 0
    fi
  done
  rm -f "$tmp"
  printf 'installed, version unavailable'
}

commands=(node npm npx python3 pip3 git gh docker claude codex gemini yc)

{
  printf '# Ubuntu Inventory Report\n\n'
  printf 'Generated: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'OS: %s\n' "${PRETTY_NAME:-unknown}"
  printf 'User: %s\n\n' "${USER:-unknown}"

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

  printf '\n## apt packages\n'
  dpkg-query -W -f='- ${binary:Package} ${Version}\n' \
    nodejs npm git gh docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-desktop python3-pip python3-venv claude-code \
    2>/dev/null || true

  printf '\n## Existing Paths\n'
  for path in \
    "$HOME/.nvm" "$HOME/.npm" "$HOME/.npmrc" "$HOME/.cache/pip" "$HOME/.pyenv" \
    "$HOME/.docker" "$HOME/.docker/desktop" "$HOME/yandex-cloud" "$HOME/.config/yc" \
    "$HOME/.claude" "$HOME/.codex" "$HOME/.gemini" /var/lib/docker /var/lib/containerd; do
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
  printf '  "os": "ubuntu",\n'
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
# Локальный план адаптации Ubuntu

Заполнить после анализа inventory.md и inventory.json:

- какие инструменты реально установлены;
- какие apt-пакеты принадлежат dev-окружению;
- где установлен Node/nvm/npm global;
- какие Docker/AI/Yandex остатки есть;
- какие команды безопасно запускать с --execute.

Важно: не планировать purge базового python3 runtime.
PLAN
fi

printf 'Inventory complete: %s\n' "$STATE_DIR"
