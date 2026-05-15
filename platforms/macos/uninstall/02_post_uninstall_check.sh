#!/usr/bin/env bash

set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  printf 'ERROR: this script is intended for macOS only.\n' >&2
  exit 1
fi

commands=(node npm npx yarn pnpm bun docker claude codex yc)

printf 'Checking commands expected to be removed:\n'
for cmd in "${commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[LEFT] %s -> %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '[OK] %s not found\n' "$cmd"
  fi
done

printf '\nSystem or Xcode-provided commands that may remain on macOS:\n'
for cmd in python3 pip3 git; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[INFO] %s still present -> %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '[OK] %s not found\n' "$cmd"
  fi
done

printf '\nGemini check:\n'
if command -v gemini >/dev/null 2>&1; then
  printf 'gemini found: %s\n' "$(command -v gemini)"
  gemini --version || true
else
  printf 'gemini not found. If it was npm-based, reinstall after Node.js is restored.\n'
fi

printf '\nPreserved config directories:\n'
for path in "$HOME/.claude" "$HOME/.codex" "$HOME/.gemini"; do
  [ -e "$path" ] && printf '%s exists\n' "$path"
done
