# Windows uninstall

Я разбил процесс на отдельные скрипты для каждого инструмента. 
**Встроена защита путей:** скрипты не удаляют project roots, `.agents` и `.ai_backup`.
Список можно расширить через `DEV_ENV_REBUILD_PROTECTED_PATHS` с разделителем `;`.

## Последовательность выполнения

### Часть 1: Инструменты (Можно запускать в любом порядке)
Все скрипты находятся в `platforms/windows/uninstall/part1_tools/`.

1. `01_python.ps1` — Python, pip, кэши.
2. `02_git.ps1` — Git, GitHub CLI; user Git config/credentials are preserved.
3. `03_docker.ps1` — Docker Desktop и все данные.
4. `04_wsl.ps1` — WSL дистрибутивы и компоненты.
5. `05_js_package_managers.ps1` — Bun, Yarn, PNPM, Turbo.
6. `06_yandex_chatgpt.ps1` — Yandex Cloud, OpenAI Codex / ChatGPT app tails.

### Часть 2: Финал (СТРОГИЙ ПОРЯДОК)
Все скрипты находятся в `platforms/windows/uninstall/part2_final/`. Эти скрипты должны запускаться последними.

1. `01_claude_deep_clean.ps1` — Полная очистка Claude (включая глобальные пакеты npm).
2. `02_codex_deep_clean.ps1` — Полная очистка Codex.
3. `03_node_npm_npx.ps1` — Строгая последовательность: сначала удаление npm, затем npx, и в конце снос Node.js.
4. `04_env_registry_path.ps1` — Финальная очистка Реестра, Переменных окружения и PATH.
   Secret env vars (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `YC_TOKEN`) are preserved
   by default; delete them only with explicit `-RemoveSecrets`.

---

## Как запускать

ВАЖНО: npm global prefix определяется динамически через `npm config get prefix`.
На этой машине он переопределён в ~/.npmrc на ~/.npm-global.
Скрипты автоматически учитывают это — не нужно ничего менять вручную.

Все скрипты поддерживают параметр `-Execute`. Без него они работают в режиме **Dry-Run**.

Пример (тест):
```powershell
.\platforms\windows\uninstall\part2_final\03_node_npm_npx.ps1
```

Пример (удаление):
```powershell
.\platforms\windows\uninstall\part2_final\03_node_npm_npx.ps1 -Execute
```

## После удаления
1. Перезагрузи компьютер.
2. Запусти `.\platforms\windows\uninstall\03_post_reboot_check.ps1` для проверки.

---

## Что дальше?
После полной очистки и перезагрузки можно приступать к установке:
1. Ознакомься с [../install/README.md](../install/README.md).
2. Следуй общему [../../../docs/windows/manual-setup-guide.md](../../../docs/windows/manual-setup-guide.md).
