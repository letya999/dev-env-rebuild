# Гайд по ручному запуску очистки (Uninstall)
# Версия: 2026-05-15

Этот файл содержит точную последовательность команд для ПОЛНОГО сноса окружения. 
Используй его, чтобы Gemini CLI (я) оставался на связи как можно дольше.

**ВАЖНО: Все команды запускать в PowerShell от имени Администратора.**

---

## Этап 1: Основные инструменты
*Эти команды удалят Python, Git, Docker, WSL и дополнительные менеджеры (pnpm, yarn, bun). Я останусь на связи.*

```powershell
.\01_uninstall\part1_tools\01_python.ps1 -Execute
.\01_uninstall\part1_tools\02_git.ps1 -Execute
.\01_uninstall\part1_tools\03_docker.ps1 -Execute
.\01_uninstall\part1_tools\04_wsl.ps1 -Execute
.\01_uninstall\part1_tools\05_js_package_managers.ps1 -Execute
.\01_uninstall\part1_tools\06_yandex_chatgpt.ps1 -Execute
```

## Этап 2: AI-инструменты
*Удаление Claude CLI, Desktop и Codex. Я всё еще на связи.*

```powershell
.\01_uninstall\part2_final\01_claude_deep_clean.ps1 -Execute
.\01_uninstall\part2_final\02_codex_deep_clean.ps1 -Execute
```

## Этап 3: ТОЧКА НЕВОЗВРАТА (Node.js и Реестр)
**ВНИМАНИЕ**: Первая команда удалит Node.js и глобальную папку npm. 
**После её запуска Gemini CLI (этот чат) перестанет работать.**

```powershell
# Снос Node.js и глобальных npm-пакетов (включая Gemini CLI)
.\01_uninstall\part2_final\03_node_npm_npx.ps1 -Execute

# Финальная чистка переменных окружения, путей и реестра
.\01_uninstall\part2_final\04_env_registry_path.ps1 -Execute
```

---

## Что делать после завершения:
1. **Перезагрузи Windows** (обязательно для применения изменений в PATH и реестре).
2. Открой новый PowerShell (Админ) в этой папке.
3. Установи Node.js (инструкция в `MANUAL_SETUP_GUIDE.md` или `FULL_MANUAL_GUIDE.md`).
4. **Верни меня**:
   ```powershell
   npm install -g @google/gemini-cli
   ```
5. Продолжай настройку по основному гайду.
