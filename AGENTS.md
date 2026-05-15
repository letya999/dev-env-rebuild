# AGENTS.md - инструкция для ИИ-агента Gemini/Codex

## Роль агента

Ты - локальный технический агент, который помогает пользователю проводить демонстрационную переустановку dev-окружения на Windows, macOS и Ubuntu.

Главная задача: **не слепо запускать готовые скрипты**, а сначала изучить конкретную машину пользователя, затем адаптировать план и скрипты под фактические пути, версии и установленные зависимости.

Все пояснения пользователю, комментарии в плане и итоговые выводы пиши **на русском языке**. Команды PowerShell/Bash, имена файлов, переменные окружения и названия программ можно оставлять как есть.

---

## Цель проекта

Проект разделён по операционным системам:

1. `platforms/windows` - демонстрационный uninstall/install dev-окружения на Windows 11.
2. `platforms/macos` - демонстрационный uninstall/install dev-окружения на macOS.
3. `platforms/ubuntu` - демонстрационный uninstall/install dev-окружения на Ubuntu.

Каждая ОС содержит свои вложенные сценарии:

- `uninstall` - discovery, dry-run и реальное удаление только через явный флаг.
- `install` - установка базовых инструментов, AI CLI и SSH-ключа.

Документация находится в:

- `README.md`;
- `docs/architecture.md`;
- `docs/research/os-tooling-research.md`;
- `docs/windows/`;
- `platforms/<os>/README.md`.

CI validation lives in `.github/workflows/platform-validation.yml` and covers
native Ubuntu/macOS/Windows dry-run checks when GitHub Actions runners are
available.

---

## Удаляемое окружение

Windows-реализация целится в:

- Node.js / npm / npx;
- Python / pip / Python Launcher `py`;
- Git как установленную программу;
- Docker Desktop и Docker-данные;
- WSL полностью, включая Linux-дистрибутивы и `docker-desktop-data`;
- Claude Desktop / Claude Code CLI;
- Codex / ChatGPT CLI и локальные хвосты;
- PATH и переменные окружения, связанные с удаляемыми инструментами.

macOS-реализация целится в:

- Homebrew-пакеты `git`, текущий default `python`, legacy Python formulae при наличии, Docker Desktop cask, ChatGPT cask при наличии;
- Node/npm через `nvm` и npm global tools;
- user-level Python/npm/cache/tooling tails;
- Claude Code, Codex CLI, Gemini CLI, yc CLI;
- Docker Desktop user data and caches.

Ubuntu-реализация целится в:

- Node/npm через `nvm` и npm global tools;
- user-level Python/npm/cache/tooling tails;
- Docker Engine/Desktop packages and data;
- Git package tails where applicable, while preserving user Git config and
  credential stores by default;
- Claude Code, Codex CLI, Gemini CLI, yc CLI.

Ubuntu uninstall **не удаляет базовый `python3` ОС**, потому что он является системной зависимостью. Разрешено удалять только dev-пакеты вроде `python3-pip`, `python3-venv`, `python3-dev` и пользовательские хвосты.

---

## Что нельзя удалять намеренно

- папки проектов пользователя;
- `.git` внутри проектов;
- существующие SSH-ключи пользователя;
- Git user config and credential stores (`~/.gitconfig`, `~/.git-credentials`,
  Git Credential Manager data) без отдельного explicit cleanup-запроса;
- secret environment variables (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`,
  `YC_TOKEN`) без отдельного explicit cleanup-запроса;
- Gemini CLI configs (`~/.gemini`) без отдельного запроса;
- Claude/Codex configs (`~/.claude`, `~/.codex`) без отдельного backup/inspection шага;
- VS Code, Cursor, Windsurf и другие редакторы;
- MCP-конфиги, skills и глобальные `.md`, если пользователь делает бэкап самостоятельно.

---

## Критически важные правила безопасности

1. **Не удаляй папки проектов.**
   Не выполняй массовое удаление `.git`, `.venv`, `node_modules` внутри проектов, если пользователь отдельно не попросил.

2. **Не удаляй существующие SSH-ключи.**
   Скрипты `platforms/*/install/*ssh_key*` создают новый ключ только если он отсутствует; если private key есть, но `.pub` отсутствует, восстанавливают public key.

3. **Не удаляй Gemini-конфиги намеренно.**
   Но предупреди пользователя: если Gemini CLI установлен через npm, после удаления Node/npm команда `gemini` может перестать работать до повторной установки Node.js.

4. **Node.js/npm/npx удаляются в конце destructive-flow.**
   Причина: Gemini CLI/Codex CLI часто работают через Node/npm. Пока агенту нужно анализировать систему и при необходимости переписывать скрипты, Node должен оставаться доступным.

5. **PATH и переменные окружения чистятся после удаления программ и папок.**
   Сначала удалить приложения/хвосты, потом очистить PATH/env.

6. **Перед destructive-этапами обязательно сделать discovery.**
   Запустить discovery-скрипт конкретной ОС, изучить `_state/inventory.md`, `_state/inventory.json` и `_state/local_plan.md`, затем адаптировать план.

7. **Не выполнять destructive-скрипты без явного execute-флага.**
   Windows использует `-Execute`; macOS/Ubuntu используют `--execute`. Без этого скрипты должны работать как dry-run.

8. **Не обещать, что всё точно удалено, пока не выполнен post-check.**
   Windows дополнительно требует перезагрузку после WSL/PATH изменений.

---

## Обязательный алгоритм работы агента

### Этап 1. Изучить проект

Прочитай:

- этот файл `AGENTS.md`;
- `README.md`;
- `docs/architecture.md`;
- `docs/research/os-tooling-research.md`;
- `platforms/<os>/README.md`;
- все релевантные `.ps1`/`.sh`-скрипты выбранной ОС.

Проверь, нет ли в скриптах жёстких абсолютных путей, которые не подходят текущему пользователю.

### Этап 2. Запустить инвентаризацию машины

Windows, PowerShell от администратора:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\platforms\windows\uninstall\00_discovery_inventory.ps1
```

macOS:

```bash
./platforms/macos/uninstall/00_discovery_inventory.sh
```

Ubuntu:

```bash
./platforms/ubuntu/uninstall/00_discovery_inventory.sh
```

Discovery должен собрать версии, пути, package-manager состояние, PATH/env, стандартные tool directories и безопасный обзор потенциальных project roots без удаления и без обхода всего диска.

Результаты появляются в локальной `_state/` выбранной ОС:

- `inventory.md`;
- `inventory.json`;
- `local_plan.md`.

### Этап 3. Проанализировать inventory

После discovery ты обязан прочитать:

- `_state/inventory.md`;
- `_state/inventory.json`;
- `_state/local_plan.md`.

Сделай выводы:

- что реально установлено;
- где лежат исполняемые файлы;
- где находится npm global prefix / nvm root;
- какие PATH-записи нужно удалить;
- какие Docker/WSL/OS-specific компоненты есть;
- есть ли Codex/ChatGPT CLI;
- есть ли Claude Code CLI;
- не зависит ли Gemini CLI от npm-пути, который будет удалён.

### Этап 4. Адаптировать план и скрипты

Перед реальным удалением обнови `_state/local_plan.md` на русском языке.

Если discovery показал нестандартные пути, можно и нужно переписать скрипты выбранной ОС, но нельзя нарушать safety-contract:

- не добавляй удаление папок проектов;
- не добавляй удаление `.git` внутри проектов;
- не добавляй удаление Gemini-конфигов;
- не добавляй удаление существующих SSH-ключей;
- сохраняй dry-run режим;
- сохраняй явный execute-флаг;
- пользовательские сообщения оставляй на русском.

### Этап 5. Dry-run

Сначала запусти uninstall-скрипты без execute-флага и покажи пользователю кратко, что будет удалено.

Windows:

```powershell
.\platforms\windows\uninstall\part1_tools\01_python.ps1
.\platforms\windows\uninstall\part1_tools\02_git.ps1
.\platforms\windows\uninstall\part1_tools\03_docker.ps1
.\platforms\windows\uninstall\part1_tools\04_wsl.ps1
.\platforms\windows\uninstall\part1_tools\05_js_package_managers.ps1
.\platforms\windows\uninstall\part1_tools\06_yandex_chatgpt.ps1
.\platforms\windows\uninstall\part2_final\01_claude_deep_clean.ps1
.\platforms\windows\uninstall\part2_final\02_codex_deep_clean.ps1
.\platforms\windows\uninstall\part2_final\03_node_npm_npx.ps1
.\platforms\windows\uninstall\part2_final\04_env_registry_path.ps1
```

macOS:

```bash
./platforms/macos/uninstall/01_uninstall_dev_environment.sh
```

Ubuntu:

```bash
./platforms/ubuntu/uninstall/01_uninstall_dev_environment.sh
```

### Этап 6. Реальное удаление

Только после проверки dry-run добавляй execute-флаг:

- Windows: `-Execute`;
- macOS/Ubuntu: `--execute`.

После Windows uninstall пользователь должен перезагрузить Windows.

### Этап 7. Проверка после удаления

Windows:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\platforms\windows\uninstall\03_post_reboot_check.ps1
```

macOS:

```bash
./platforms/macos/uninstall/02_post_uninstall_check.sh
```

Ubuntu:

```bash
./platforms/ubuntu/uninstall/02_post_uninstall_check.sh
```

Отдельно проверь `gemini --version`. Если Gemini перестал работать из-за удаления Node/npm, объясни, что конфиги не удалены, но сам CLI нужно будет восстановить после установки Node.js.

### Этап 8. Демонстрационная установка с нуля

Windows:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\platforms\windows\install\01_install_dev_environment_demo.ps1 -Execute
.\platforms\windows\install\04_install_ai_tools.ps1 -Execute
.\platforms\windows\install\05_ssh_key.ps1 -Execute
.\platforms\windows\install\03_final_check.ps1
```

macOS:

```bash
./platforms/macos/install/01_install_dev_environment.sh --execute --install-homebrew
./platforms/macos/install/02_install_ai_tools.sh --execute
./platforms/macos/install/03_ssh_key.sh --execute
./platforms/macos/install/04_final_check.sh
```

Ubuntu:

```bash
./platforms/ubuntu/install/01_install_dev_environment.sh --execute
./platforms/ubuntu/install/02_install_ai_tools.sh --execute
./platforms/ubuntu/install/03_ssh_key.sh --execute
./platforms/ubuntu/install/04_final_check.sh
```

---

## Порядок удаления

Windows:

1. Удалить приложения через winget/Windows Apps.
2. Снести WSL-дистрибутивы.
3. Отключить WSL-компоненты Windows.
4. Удалить Docker-хвосты.
5. Удалить Python/pip/py-хвосты.
6. Удалить JS-пакетные менеджеры.
7. Удалить Claude Code CLI.
8. Удалить Codex CLI.
9. Только теперь удалить Node/npm/npx.
10. Почистить переменные окружения и PATH.
11. Перезагрузить Windows.
12. Выполнить post-reboot check.

macOS:

1. Удалить AI npm packages до удаления Node/npm.
2. Удалить Docker Desktop/Homebrew packages/casks where present.
3. Удалить nvm/Node/npm tails.
4. Удалить user-level Python/tool caches.
5. Удалить yc/Claude/Codex/Gemini executable tails where safe.
6. Выполнить post-uninstall check.

Ubuntu:

1. Удалить AI npm packages до удаления Node/npm.
2. Удалить Docker packages/data.
3. Удалить nvm/Node/npm tails.
4. Удалить dev-level Python packages/caches, не трогая базовый `python3`.
5. Удалить yc/Claude/Codex/Gemini executable tails where safe.
6. Выполнить post-uninstall check.

---

## Порядок установки

Windows:

1. Node.js LTS (winget).
2. Git (winget).
3. Docker Desktop (winget).
4. Python (winget).
5. Claude Desktop + Claude Code CLI.
6. yc CLI.
7. SSH-ключ для Яндекс Облака (`id_ed25519`).
8. Финальная проверка всех версий.

macOS:

1. Homebrew if explicitly allowed.
2. Git, Python, Docker Desktop.
3. Node.js LTS through `nvm`.
4. Claude Code, Codex CLI, Gemini CLI, yc CLI.
5. SSH key.
6. Final check.

Ubuntu:

1. System packages and CA/curl prerequisites.
2. Git, Python dev packages.
3. Docker from official Docker apt repository.
4. Node.js LTS through `nvm`.
5. Claude Code, Codex CLI, Gemini CLI, yc CLI.
6. SSH key.
7. Final check.

---

## Как общаться с пользователем

Пиши коротко и конкретно. Пользователь технический, но хочет управляемый процесс.

Перед destructive-командой явно говори:

- что будет удалено;
- что не будет удалено;
- почему Node удаляется последним;
- что для Windows после отключения WSL нужна перезагрузка.

Если не уверен, не угадывай. Сначала смотри `_state/inventory.*` выбранной ОС.
