# OS Tooling Research

Research date: 2026-05-15.

## Windows

- Microsoft documents `winget` as the Windows Package Manager CLI for
  discovering, installing, upgrading, removing, and configuring applications on
  Windows 10/11 and Windows Server 2025:
  https://learn.microsoft.com/en-us/windows/package-manager/winget/
- WSL official commands include `wsl --list --verbose`, `wsl --shutdown`, and
  destructive `wsl --unregister <DistributionName>`; Microsoft warns that
  unregistering permanently loses the distribution's data:
  https://learn.microsoft.com/en-us/windows/wsl/basic-commands
- Docker Desktop uninstall docs list Windows residual paths under
  `C:\ProgramData\Docker`, `C:\ProgramData\DockerDesktop`,
  `C:\Program Files\Docker`, user AppData Docker folders, and `~\.docker`:
  https://docs.docker.com/desktop/uninstall/

## macOS

- Homebrew's supported default prefixes are `/opt/homebrew` on Apple Silicon
  and `/usr/local` on Intel macOS. Homebrew states the installer explains what
  it will do before it starts:
  https://docs.brew.sh/Installation.html
- Homebrew's FAQ points to the official uninstall script and notes
  `brew uninstall --force <formula>` when all versions must be removed:
  https://docs.brew.sh/FAQ.html
- Docker Desktop for Mac can be uninstalled via
  `/Applications/Docker.app/Contents/MacOS/uninstall`; Docker documents
  leftover `~/Library/Group Containers/group.com.docker` and `~/.docker`:
  https://docs.docker.com/desktop/uninstall/

## Ubuntu

- Ubuntu recommends APT for Debian packages and explicitly notes that scripts
  should use `apt-get` instead of interactive `apt`:
  https://ubuntu.com/server/docs/how-to/software/package-management/
- Docker documents the official Ubuntu apt repository and installation command
  for `docker-ce`, `docker-ce-cli`, `containerd.io`,
  `docker-buildx-plugin`, and `docker-compose-plugin`:
  https://docs.docker.com/engine/install/ubuntu/
- Docker Engine uninstall requires `apt purge` of Docker packages; Docker data
  under `/var/lib/docker` and `/var/lib/containerd` is not removed
  automatically:
  https://docs.docker.com/engine/install/ubuntu/

## Node and AI CLIs

- npm documentation recommends installing Node.js/npm with a Node version
  manager and documents `npm install -g <package_name>` for global CLIs:
  https://docs.npmjs.com/downloading-and-installing-node-js-and-npm/
- `nvm` supports macOS and Linux and provides `nvm install --lts` for the
  latest LTS Node.js line:
  https://github.com/nvm-sh/nvm
- Claude Code supports macOS 13+, Windows 10 1809+, Ubuntu 20.04+, and Debian
  10+. Official setup documents native installers, Homebrew, WinGet, apt, and
  npm installation methods:
  https://code.claude.com/docs/en/setup
- Codex CLI official docs install with `npm i -g @openai/codex`; first run
  prompts for ChatGPT or API-key authentication:
  https://developers.openai.com/codex/cli
- Codex authentication docs state that the CLI supports ChatGPT sign-in and API
  key sign-in:
  https://developers.openai.com/codex/auth
- Gemini CLI official docs install with `npm install -g @google/gemini-cli`:
  https://google-gemini.github.io/gemini-cli/docs/get-started/
- Yandex Cloud CLI official quickstart uses
  `curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash`
  on Linux/macOS and `install.ps1` on Windows:
  https://yandex.cloud/en/docs/cli/quickstart
