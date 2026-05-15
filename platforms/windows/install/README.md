# Windows install

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
.\platforms\windows\install\01_install_dev_environment_demo.ps1
```

Реальная установка:

```powershell
.\platforms\windows\install\01_install_dev_environment_demo.ps1 -Execute
```

## SSH-ключ для демонстрации

Существующие ключи не трогаются. Скрипт создаёт отдельный временный ключ:

```text
%USERPROFILE%\.ssh\ai_camp_demo_key
```

Потом показывает публичную часть `.pub` и сразу удаляет оба файла демо-ключа.

## Что дальше?

После завершения автоматической установки переходи к **ручной донастройке** (аккаунты, подписки, ключи):
[../../../docs/windows/manual-setup-guide.md](../../../docs/windows/manual-setup-guide.md)
