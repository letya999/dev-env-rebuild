# dev-env-rebuild

PowerShell-скрипты для **полного сброса и восстановления dev-окружения Windows 11** — для демонстрации работы AI CLI-инструментов (Claude Code, Gemini CLI, Codex CLI).

Проект создан для AI Camp: показывает как AI-агент (Gemini CLI или Codex CLI) может управлять реальными системными операциями — удалять, инвентаризировать и переустанавливать dev-стек с нуля.

## Что умеет

- **Инвентаризация** — сканирует машину: какие инструменты установлены, откуда, какие версии
- **Удаление** — убирает Node.js, Python, Git, Docker Desktop, Claude Code, Codex, WSL и связанные PATH/env-записи в правильной последовательности
- **Установка** — ставит всё обратно через winget и npm
- **Ручные гайды** — пошаговые инструкции для ручной настройки после скриптов (аккаунты, подписки, Telegram-бот, Яндекс Облако)

## Стек

- PowerShell 5.1+ (Windows)
- winget (Windows Package Manager)
- Node.js / npm
- Python 3.12
- Git, Docker Desktop, WSL2
- Claude Code CLI, Gemini CLI, Codex CLI
- yc CLI (Яндекс Облако)

## Структура

```
01_uninstall/           удаление в правильном порядке
  00_discovery_inventory.ps1   инвентаризация машины
  lib.ps1                      общие функции (Get-NpmPrefix и др.)
  part1_tools/                 удаление инструментов (можно в любом порядке)
    01_python.ps1
    02_git.ps1
    03_docker.ps1
    04_wsl.ps1
    05_js_package_managers.ps1
    06_yandex_chatgpt.ps1
  part2_final/                 финал (строгий порядок!)
    01_claude_deep_clean.ps1
    02_codex_deep_clean.ps1
    03_node_npm_npx.ps1
    04_env_registry_path.ps1

02_install/             установка
  01_install_dev_environment_demo.ps1  базовый стек (Node, Git, Docker, Python)
  02_demo_ssh_key_create_and_remove.ps1  демо SSH-ключ (создать→показать→удалить)
  03_final_check.ps1                   проверка всего окружения
  04_install_ai_tools.ps1              Claude Code CLI, Claude Desktop, yc CLI
  05_ssh_key.ps1                       постоянный SSH-ключ для Яндекс Облака
  FULL_MANUAL_GUIDE.md                 полный ручной гайд (без скриптов)

_state/                 генерируется скриптами (в .gitignore)
  inventory.md
  inventory.json
  local_plan.md

MANUAL_SETUP_GUIDE.md   гайд по ручной настройке после скриптов
AGENTS.md               инструкции для AI-агента
```

## Быстрый старт

Открой PowerShell от имени администратора в корне проекта.

### 1. Инвентаризация (всегда первым шагом)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\01_uninstall\00_discovery_inventory.ps1
```

### 2. Dry-run удаления (посмотреть что будет удалено, ничего не трогает)

```powershell
# Часть 1 — инструменты (порядок не важен):
.\01_uninstall\part1_tools\01_python.ps1
.\01_uninstall\part1_tools\02_git.ps1
.\01_uninstall\part1_tools\03_docker.ps1
.\01_uninstall\part1_tools\04_wsl.ps1
.\01_uninstall\part1_tools\05_js_package_managers.ps1
.\01_uninstall\part1_tools\06_yandex_chatgpt.ps1

# Часть 2 — финал (строгий порядок!):
.\01_uninstall\part2_final\01_claude_deep_clean.ps1
.\01_uninstall\part2_final\02_codex_deep_clean.ps1
.\01_uninstall\part2_final\03_node_npm_npx.ps1
.\01_uninstall\part2_final\04_env_registry_path.ps1
```

### 3. Реальное удаление (добавь `-Execute` к каждой команде)

```powershell
.\01_uninstall\part1_tools\01_python.ps1 -Execute
# ... и так далее
```

### 4. Перезагрузка

```powershell
Restart-Computer
```

### 5. Установка после перезагрузки

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

.\02_install\01_install_dev_environment_demo.ps1 -Execute
# Перезапусти PowerShell после Docker

.\02_install\04_install_ai_tools.ps1 -Execute
# Перезапусти PowerShell после этого шага

.\02_install\05_ssh_key.ps1 -Execute
```

### 6. Ручная донастройка

Следуй шагам из [MANUAL_SETUP_GUIDE.md](MANUAL_SETUP_GUIDE.md):
вход в аккаунты, подписки, git identity, yc init, Telegram-бот.

Или используй полный ручной гайд без скриптов: [02_install/FULL_MANUAL_GUIDE.md](02_install/FULL_MANUAL_GUIDE.md)

## Принцип dry-run

Все скрипты удаления по умолчанию работают в режиме **dry-run** — только показывают что сделают, ничего не трогают. Для реального выполнения добавь флаг `-Execute`:

```powershell
.\01_uninstall\part1_tools\01_python.ps1          # dry-run
.\01_uninstall\part1_tools\01_python.ps1 -Execute  # реальное удаление
```

## Требования

- Windows 11 (22H2+)
- PowerShell 5.1+
- Права администратора для скриптов удаления/установки

## Лицензия

MIT — см. [LICENSE](LICENSE)
