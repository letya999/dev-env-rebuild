#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=1
KEY_PATH="$HOME/.ssh/id_ed25519"

for arg in "$@"; do
  case "$arg" in
    --execute) DRY_RUN=0 ;;
    --key-path=*) KEY_PATH="${arg#*=}" ;;
    --help|-h)
      printf 'Usage: %s [--execute] [--key-path=~/.ssh/id_ed25519]\n' "$0"
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$arg" >&2
      exit 2
      ;;
  esac
done

PUB_PATH="$KEY_PATH.pub"

if [ "$DRY_RUN" = "1" ]; then
  printf 'DRY-RUN: create SSH key at %s only if it does not already exist\n' "$KEY_PATH"
  exit 0
fi

mkdir -p "$(dirname "$KEY_PATH")"
chmod 700 "$(dirname "$KEY_PATH")"

if [ -f "$KEY_PATH" ]; then
  printf 'SSH key already exists: %s\n' "$KEY_PATH"
  if [ ! -f "$PUB_PATH" ]; then
    ssh-keygen -y -f "$KEY_PATH" > "$PUB_PATH"
  fi
  printf 'Public key:\n'
  cat "$PUB_PATH"
  exit 0
fi

ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "ai-camp-yandex-cloud"
printf 'Public key:\n'
cat "$PUB_PATH"
