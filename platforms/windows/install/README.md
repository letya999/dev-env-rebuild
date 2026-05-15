# Windows install

Эта папка содержит демонстрационные скрипты установки окружения после очистки.

## Что устанавливается

- Node.js LTS;
- Git;
- Docker Desktop;
- Python;
- Claude Desktop / Claude Code CLI and yc CLI via `04_install_ai_tools.ps1`;
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

AI tools:

```powershell
.\platforms\windows\install\04_install_ai_tools.ps1
.\platforms\windows\install\04_install_ai_tools.ps1 -Execute
```

## SSH keys

Существующие ключи не трогаются.

Для постоянного ключа `id_ed25519`, который нужен после установки:

```powershell
.\platforms\windows\install\05_ssh_key.ps1
.\platforms\windows\install\05_ssh_key.ps1 -Execute
```

Для отдельной демонстрации создания и удаления временного ключа есть скрипт:

```text
%USERPROFILE%\.ssh\ai_camp_demo_key
```

Он показывает публичную часть `.pub` и сразу удаляет оба файла демо-ключа.

## Что дальше?

После завершения автоматической установки переходи к **ручной донастройке** (аккаунты, подписки, ключи):
[../../../docs/windows/manual-setup-guide.md](../../../docs/windows/manual-setup-guide.md)
