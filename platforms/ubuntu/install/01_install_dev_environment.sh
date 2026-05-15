#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=1
INSTALL_DOCKER=1
NVM_INSTALL_VERSION="${NVM_INSTALL_VERSION:-v0.40.4}"

for arg in "$@"; do
  case "$arg" in
    --execute) DRY_RUN=0 ;;
    --skip-docker) INSTALL_DOCKER=0 ;;
    --help|-h)
      printf 'Usage: %s [--execute] [--skip-docker]\n' "$0"
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

step() { printf '\n=== %s ===\n' "$1"; }

step 'Base apt packages'
run_shell 'sudo apt-get update' 'sudo apt-get update'
run_shell 'Install curl, ca-certificates, git, Python dev extras, OpenSSH client' \
  'sudo apt-get install -y ca-certificates curl gnupg git python3 python3-pip python3-venv openssh-client'

step 'Node.js LTS through nvm'
run_shell 'Install nvm and latest LTS Node.js' \
  "export NVM_DIR=\"\$HOME/.nvm\"; if [ ! -s \"\$NVM_DIR/nvm.sh\" ]; then curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_INSTALL_VERSION}/install.sh | bash; fi; . \"\$NVM_DIR/nvm.sh\"; nvm install --lts; nvm alias default 'lts/*'; nvm use default; node -v; npm -v"

if [ "$INSTALL_DOCKER" = "1" ]; then
  step 'Docker Engine from official Docker apt repository'
  # shellcheck disable=SC2016
  run_shell 'Install Docker apt repository key and source' \
    'sudo install -m 0755 -d /etc/apt/keyrings && sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && sudo chmod a+r /etc/apt/keyrings/docker.asc && gpg --show-keys --with-colons /etc/apt/keyrings/docker.asc | grep -q "fpr:::::::::9DC858229FC7DD38854AE2D88D81803C0EBFCD88:" && echo "Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc" | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null && sudo apt-get update'
  run_shell 'Install Docker Engine packages' \
    'sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin'
fi

printf '\nRestart the shell after execute mode, then run ./platforms/ubuntu/install/02_install_ai_tools.sh --execute\n'
