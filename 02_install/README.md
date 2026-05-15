# 02_install — установка с нуля

Эта папка содержит демонстрационные скрипты установки окружения после очистки.

## Что устанавливается

- Node.js LTS;
- Git;
- Docker Desktop;
- Python;
- опционально Codex CLI после установки Node.js.

## Как запускать

Сначала dry-run:

```powershell
.\02_install\01_install_dev_environment_demo.ps1
```

Реальная установка:

```powershell
.\02_install\01_install_dev_environment_demo.ps1 -Execute
```

## SSH-ключ для демонстрации

Существующие ключи не трогаются. Скрипт создаёт отдельный временный ключ:

```text
%USERPROFILE%\.ssh\ai_camp_demo_key
```

Потом показывает публичную часть `.pub` и сразу удаляет оба файла демо-ключа.

## Что дальше?

После завершения автоматической установки переходи к **ручной донастройке** (аккаунты, подписки, ключи):
[MANUAL_SETUP_GUIDE.md](../MANUAL_SETUP_GUIDE.md)
