#!/usr/bin/env bash

set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  printf 'ERROR: this script is intended for macOS only.\n' >&2
  exit 1
fi

required=(node npm git python3 docker claude)
optional=(npx codex gemini yc)

all_ok=1
for cmd in "${required[@]}"; do
  printf '\n=== %s ===\n' "$cmd"
  if command -v "$cmd" >/dev/null 2>&1; then
    command -v "$cmd"
    "$cmd" --version 2>/dev/null || "$cmd" -v 2>/dev/null || true
  else
    printf '[ERROR] %s not found\n' "$cmd"
    all_ok=0
  fi
done

for cmd in "${optional[@]}"; do
  printf '\n=== %s ===\n' "$cmd"
  if command -v "$cmd" >/dev/null 2>&1; then
    command -v "$cmd"
    "$cmd" --version 2>/dev/null || "$cmd" -v 2>/dev/null || true
  else
    printf '[INFO] %s not found (optional)\n' "$cmd"
  fi
done

printf '\nDocker manual check after Docker Desktop starts:\n  docker run hello-world\n'
printf 'Claude auth:\n  claude\n'
printf 'Yandex Cloud init:\n  yc init\n'

[ "$all_ok" = "1" ]
