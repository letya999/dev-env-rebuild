#!/usr/bin/env bash

set -euo pipefail

commands=(node npm npx yarn pnpm bun python3 pip3 git gh docker claude codex yc)

printf 'Checking commands expected to be removed:\n'
for cmd in "${commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[LEFT] %s -> %s\n' "$cmd" "$(command -v "$cmd")"
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
