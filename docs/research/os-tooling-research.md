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
- WinGet's community manifest repository currently contains exact package
  identifiers used by the scripts: `OpenJS.NodeJS.LTS`, `Git.Git`,
  `Docker.DockerDesktop`, `Python.Python.3.14`, `Python.Launcher`,
  `Anthropic.ClaudeCode`, `Anthropic.Claude`, `OpenAI.Codex`,
  `GitHub.cli`, and `Oven-sh.Bun`:
  https://github.com/microsoft/winget-pkgs

## macOS

- Homebrew's supported default prefixes are `/opt/homebrew` on Apple Silicon
  and `/usr/local` on Intel macOS. Homebrew states the installer explains what
  it will do before it starts:
  https://docs.brew.sh/Installation.html
- Homebrew's FAQ points to the official uninstall script and notes
  `brew uninstall --force <formula>` when all versions must be removed:
  https://docs.brew.sh/FAQ.html
- Homebrew's cask docs support `brew uninstall --zap --force <cask>` for more
  complete cask cleanup. This project intentionally uses conservative cask
  uninstall plus explicit vendor-documented residual paths rather than broad
  `--zap` cleanup:
  https://docs.brew.sh/Cask-Cookbook
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
- Docker's documented apt repository signing-key fingerprint is
  `9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88`; Ubuntu install scripts
  verify this fingerprint before trusting the repository key:
  https://docs.docker.com/engine/install/ubuntu/
- Docker Engine uninstall requires `apt purge` of Docker packages; Docker data
  under `/var/lib/docker` and `/var/lib/containerd` is not removed
  automatically:
  https://docs.docker.com/engine/install/ubuntu/
- Docker Desktop for Ubuntu cleanup also documents `$HOME/.docker/desktop`,
  `/usr/local/bin/com.docker.cli`, `docker-desktop` purge, and manual cleanup
  of `credsStore` / `currentContext` in `$HOME/.docker/config.json`:
  https://docs.docker.com/desktop/uninstall/

## Node and AI CLIs

- npm documentation recommends installing Node.js/npm with a Node version
  manager and documents `npm install -g <package_name>` for global CLIs:
  https://docs.npmjs.com/downloading-and-installing-node-js-and-npm/
- `nvm` supports macOS and Linux and provides `nvm install --lts` for the
  latest LTS Node.js line. GitHub currently reports the latest release as
  `v0.40.4`:
  https://github.com/nvm-sh/nvm
- Claude Code supports macOS 13+, Windows 10 1809+, Ubuntu 20.04+, and Debian
  10+. Official setup documents native installers, Homebrew, WinGet, apt, and
  npm installation methods:
  https://code.claude.com/docs/en/setup
- Claude Code apt setup publishes a signed repository and documents the GPG
  fingerprint `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE`; Ubuntu
  install scripts verify this fingerprint before installing `claude-code`:
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
  on Linux/macOS and `install.ps1` on Windows. Its install options include
  `-a` to automatically modify the default shell rc file with PATH and
  completion setup:
  https://yandex.cloud/en/docs/cli/operations/install-cli
- The same Yandex Cloud CLI docs document scriptless Windows installation by
  downloading `yc_windows_amd64.zip` or `yc_windows_386.zip`, unpacking
  `yc.exe`, and adding that directory to User `PATH`; the Windows install
  script uses that non-interactive path to avoid the `install.ps1` PATH prompt.
