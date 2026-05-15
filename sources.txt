Да, теперь даю **полный перечень ссылок**, с учётом PDF и твоего расширенного dev-стека: Windows 11, PowerShell, winget, Node/npm/npx, Python/pip/py, uv, Bun, Git, Docker/WSL2, Claude, Codex, Gemini CLI, Telegram, Яндекс Облако, yc CLI, GitHub, NotebookLM, Lovable, Manus, Exa.

В PDF явно указаны: Claude Desktop / Codex, подписка Claude или ChatGPT, Node.js 18+, Git, Docker Desktop, Claude Code CLI, GitHub, Telegram Desktop, BotFather, userinfobot, Яндекс Облако, yc CLI, SSH-ключ, NotebookLM, Lovable, Manus и Exa. Python, pip, winget, uv и Bun в PDF не указаны, но их логично добавить в твой демонстрационный стек как инфраструктурные dev-инструменты. 

---

# 1. Базовые системные инструменты Windows 11

| Инструмент                                       | Для чего                                  | Ссылка                                                                                                                                                                                               |
| ------------------------------------------------ | ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PowerShell                                       | Командная строка для установки и проверок | [https://learn.microsoft.com/en-us/powershell/](https://learn.microsoft.com/en-us/powershell/)                                                                                                       |
| Windows Terminal                                 | Удобный терминал для PowerShell           | [https://apps.microsoft.com/detail/9n0dx20hk701](https://apps.microsoft.com/detail/9n0dx20hk701)                                                                                                     |
| winget / Windows Package Manager                 | Установка программ из терминала           | [https://learn.microsoft.com/en-us/windows/package-manager/winget/](https://learn.microsoft.com/en-us/windows/package-manager/winget/)                                                               |
| App Installer, через него обычно приходит winget | Если winget отсутствует или сломан        | [https://apps.microsoft.com/detail/9nblggh4nns1](https://apps.microsoft.com/detail/9nblggh4nns1)                                                                                                     |
| WSL                                              | Нужен Docker Desktop и Linux-окружениям   | [https://learn.microsoft.com/en-us/windows/wsl/install](https://learn.microsoft.com/en-us/windows/wsl/install)                                                                                       |
| OpenSSH for Windows                              | SSH-ключи и подключение к серверам        | [https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse) |

Microsoft описывает winget как командный инструмент для установки, обновления, удаления и настройки приложений на Windows; WSL ставится и управляется через официальные команды Windows. ([Microsoft Learn][1])

---

# 2. JavaScript / Node-стек

| Инструмент        | Для чего                                                                  | Ссылка                                                                                                                                 |
| ----------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Node.js LTS       | База для npm/npx, Claude Code, Codex CLI, Gemini CLI, JS-проектов         | [https://nodejs.org/en/download](https://nodejs.org/en/download)                                                                       |
| npm               | Пакетный менеджер Node.js, ставится вместе с Node.js                      | [https://docs.npmjs.com/downloading-and-installing-node-js-and-npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) |
| npx               | Запуск npm-пакетов без ручной глобальной установки, ставится вместе с npm | [https://docs.npmjs.com/cli/v10/commands/npx](https://docs.npmjs.com/cli/v10/commands/npx)                                             |
| Bun               | Альтернативный JS runtime/package manager                                 | [https://bun.com/docs/installation](https://bun.com/docs/installation)                                                                 |
| Bun quick install | Быстрый установщик Bun                                                    | [https://bun.com/get](https://bun.com/get)                                                                                             |

Для Windows npm рекомендует устанавливать Node.js LTS через официальный инсталлятор Node.js; npm и npx идут вместе с Node.js. ([Node.js][2]) Bun официально поддерживает Windows и ставится через скрипт, npm или package manager. ([Bun][3])

Команды проверки:

```powershell
node -v
npm -v
npx -v
bun --version
```

---

# 3. Python / pip / uv

| Инструмент             | Для чего                                                     | Ссылка                                                                                                                                         |
| ---------------------- | ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Python for Windows     | Python runtime, py launcher, pip                             | [https://www.python.org/downloads/windows/](https://www.python.org/downloads/windows/)                                                         |
| Python main downloads  | Основная страница загрузки Python                            | [https://www.python.org/downloads/](https://www.python.org/downloads/)                                                                         |
| pip                    | Python package manager                                       | [https://pip.pypa.io/en/stable/installation/](https://pip.pypa.io/en/stable/installation/)                                                     |
| Python packaging guide | Официальный гайд по установке пакетов Python                 | [https://packaging.python.org/en/latest/tutorials/installing-packages/](https://packaging.python.org/en/latest/tutorials/installing-packages/) |
| uv                     | Современный быстрый Python package/project manager от Astral | [https://docs.astral.sh/uv/](https://docs.astral.sh/uv/)                                                                                       |
| uv installation        | Установка uv на Windows                                      | [https://docs.astral.sh/uv/getting-started/installation/](https://docs.astral.sh/uv/getting-started/installation/)                             |

Python.org даёт Windows installer и Python install manager; uv официально предлагает Windows-команду установки через PowerShell. ([Python.org][4])

Команды проверки:

```powershell
python --version
py --version
pip --version
uv --version
```

---

# 4. Git / GitHub

| Инструмент / сервис           | Для чего                                 | Ссылка                                                                                                                                                                             |
| ----------------------------- | ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Git for Windows               | Git CLI на Windows                       | [https://git-scm.com/download/win](https://git-scm.com/download/win)                                                                                                               |
| Git install page              | Официальная страница установки Git       | [https://git-scm.com/install/windows](https://git-scm.com/install/windows)                                                                                                         |
| GitHub signup                 | Регистрация GitHub                       | [https://github.com/signup](https://github.com/signup)                                                                                                                             |
| GitHub login                  | Вход в GitHub                            | [https://github.com/login](https://github.com/login)                                                                                                                               |
| GitHub docs: creating account | Документация GitHub по созданию аккаунта | [https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github](https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github) |

Git for Windows — официальный поддерживаемый Windows-дистрибутив Git; GitHub требует создать аккаунт и подтвердить email для базовой работы. ([Git][5])

Команды проверки:

```powershell
git --version
git config --global user.name
git config --global user.email
```

---

# 5. Docker / контейнеры / WSL2

| Инструмент                          | Для чего                                                   | Ссылка                                                                                                                                       |
| ----------------------------------- | ---------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Docker Desktop                      | Docker на Windows                                          | [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)                                           |
| Docker Desktop Windows install docs | Официальная инструкция установки Docker Desktop на Windows | [https://docs.docker.com/desktop/setup/install/windows-install/](https://docs.docker.com/desktop/setup/install/windows-install/)             |
| Docker Desktop docs                 | Общая документация Docker Desktop                          | [https://docs.docker.com/desktop/](https://docs.docker.com/desktop/)                                                                         |
| Get Docker Desktop                  | Страница загрузки Docker Desktop                           | [https://docs.docker.com/get-started/introduction/get-docker-desktop/](https://docs.docker.com/get-started/introduction/get-docker-desktop/) |
| WSL install                         | WSL2 для Docker Desktop                                    | [https://learn.microsoft.com/en-us/windows/wsl/install](https://learn.microsoft.com/en-us/windows/wsl/install)                               |

Docker Desktop официально описывается как one-click install для Windows/macOS/Linux; Windows-инструкция покрывает системные требования и установку. ([Docker Documentation][6])

Команды проверки:

```powershell
docker --version
docker run hello-world
wsl --status
wsl --list --verbose
```

---

# 6. Claude / Anthropic

| Инструмент / сервис      | Для чего                            | Ссылка                                                                                                             |
| ------------------------ | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Claude Desktop download  | Приложение Claude Desktop           | [https://claude.com/download](https://claude.com/download)                                                         |
| Claude web               | Вход в Claude                       | [https://claude.ai/](https://claude.ai/)                                                                           |
| Claude Code product page | Страница Claude Code                | [https://claude.com/product/claude-code](https://claude.com/product/claude-code)                                   |
| Claude Code npm package  | Установка Claude Code CLI через npm | [https://www.npmjs.com/package/@anthropic-ai/claude-code](https://www.npmjs.com/package/@anthropic-ai/claude-code) |
| Anthropic Console        | API keys / billing Anthropic        | [https://console.anthropic.com/](https://console.anthropic.com/)                                                   |
| Anthropic API keys       | API-ключи Anthropic                 | [https://console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys)                         |
| Anthropic billing        | Пополнение / биллинг Anthropic      | [https://console.anthropic.com/settings/billing](https://console.anthropic.com/settings/billing)                   |

Claude Desktop официально доступен для Windows на странице загрузки Claude; пакет `@anthropic-ai/claude-code` опубликован в npm как agentic coding tool для терминала. ([Claude][7])

Команда установки Claude Code CLI:

```powershell
npm install -g @anthropic-ai/claude-code
```

Проверка:

```powershell
claude --version
```

---

# 7. ChatGPT / OpenAI / Codex

| Инструмент / сервис | Для чего                                    | Ссылка                                                                                                                                   |
| ------------------- | ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| ChatGPT             | Вход в ChatGPT                              | [https://chatgpt.com/](https://chatgpt.com/)                                                                                             |
| Codex web           | Codex от ChatGPT                            | [https://chatgpt.com/codex](https://chatgpt.com/codex)                                                                                   |
| Codex CLI docs      | Официальная страница Codex CLI              | [https://developers.openai.com/codex/cli](https://developers.openai.com/codex/cli)                                                       |
| Codex GitHub repo   | Репозиторий Codex CLI                       | [https://github.com/openai/codex](https://github.com/openai/codex)                                                                       |
| OpenAI Platform     | API-аккаунт OpenAI                          | [https://platform.openai.com/](https://platform.openai.com/)                                                                             |
| OpenAI API keys     | API-ключи OpenAI                            | [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)                                                             |
| OpenAI billing      | Биллинг OpenAI API                          | [https://platform.openai.com/settings/organization/billing/overview](https://platform.openai.com/settings/organization/billing/overview) |
| Codex auth docs     | Авторизация Codex через ChatGPT или API key | [https://developers.openai.com/codex/auth](https://developers.openai.com/codex/auth)                                                     |
| OpenAI API pricing  | Стоимость API                               | [https://openai.com/api/pricing/](https://openai.com/api/pricing/)                                                                       |

Официальная документация Codex CLI даёт установку через npm: `npm i -g @openai/codex`; Codex CLI при первом запуске просит войти через ChatGPT или API key. ([OpenAI Developers][8])

Команда установки Codex CLI:

```powershell
npm install -g @openai/codex
```

Проверка:

```powershell
codex --version
```

---

# 8. Gemini CLI / Google

| Инструмент / сервис       | Для чего                        | Ссылка                                                                                                       |
| ------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| Gemini CLI site           | Основная страница Gemini CLI    | [https://geminicli.com/](https://geminicli.com/)                                                             |
| Gemini CLI install docs   | Инструкция установки Gemini CLI | [https://geminicli.com/docs/get-started/installation/](https://geminicli.com/docs/get-started/installation/) |
| Gemini CLI GitHub repo    | Репозиторий Gemini CLI          | [https://github.com/google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli)                   |
| Gemini CLI releases       | Релизы Gemini CLI               | [https://github.com/google-gemini/gemini-cli/releases](https://github.com/google-gemini/gemini-cli/releases) |
| Google AI Studio          | API key / Gemini API            | [https://aistudio.google.com/](https://aistudio.google.com/)                                                 |
| Google AI Studio API keys | Ключи Gemini API                | [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)                             |

Gemini CLI официально ставится глобально через npm командой `npm install -g @google/gemini-cli`. ([GitHub][9])

Команда установки:

```powershell
npm install -g @google/gemini-cli
```

Проверка:

```powershell
gemini --version
```

---

# 9. Telegram / BotFather / userinfobot

| Инструмент / бот                | Для чего                                       | Ссылка                                                                         |
| ------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------ |
| Telegram Desktop                | Telegram на Windows                            | [https://desktop.telegram.org/](https://desktop.telegram.org/)                 |
| Telegram Desktop direct Windows | Прямая ссылка из PDF                           | [https://telegram.org/dl/desktop/win64](https://telegram.org/dl/desktop/win64) |
| Telegram apps                   | Все официальные приложения Telegram            | [https://telegram.org/apps](https://telegram.org/apps)                         |
| BotFather                       | Создание Telegram-бота и получение `BOT_TOKEN` | [https://t.me/BotFather](https://t.me/BotFather)                               |
| BotFather альтернативная ссылка | То же самое                                    | [https://telegram.me/BotFather](https://telegram.me/BotFather)                 |
| userinfobot                     | Получение `CHAT_ID`                            | [https://t.me/userinfobot](https://t.me/userinfobot)                           |
| Telegram Bot API docs           | Документация Telegram Bot API                  | [https://core.telegram.org/bots/api](https://core.telegram.org/bots/api)       |
| Telegram bots intro             | Документация по ботам                          | [https://core.telegram.org/bots](https://core.telegram.org/bots)               |

Telegram Desktop — официальный десктоп-клиент; BotFather официально используется для создания и управления ботами. ([Telegram][10])

Что делать:

```text
1. Открыть https://t.me/BotFather
2. Отправить /newbot
3. Сохранить BOT_TOKEN
4. Открыть https://t.me/userinfobot
5. Нажать Start
6. Сохранить CHAT_ID
```

---

# 10. Яндекс Облако / yc CLI

| Инструмент / сервис      | Для чего                            | Ссылка                                                                                                                           |
| ------------------------ | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Yandex Cloud             | Регистрация и консоль Яндекс Облака | [https://cloud.yandex.ru/](https://cloud.yandex.ru/)                                                                             |
| Yandex Cloud Console     | Консоль управления                  | [https://console.cloud.yandex.ru/](https://console.cloud.yandex.ru/)                                                             |
| Yandex Cloud billing     | Биллинг                             | [https://billing.yandex.cloud/](https://billing.yandex.cloud/)                                                                   |
| Yandex Cloud CLI docs    | Документация yc CLI                 | [https://yandex.cloud/en/docs/cli/](https://yandex.cloud/en/docs/cli/)                                                           |
| yc CLI install           | Установка yc CLI на Windows         | [https://yandex.cloud/en/docs/cli/operations/install-cli](https://yandex.cloud/en/docs/cli/operations/install-cli)               |
| yc CLI quickstart        | Быстрый старт yc CLI                | [https://yandex.cloud/en/docs/cli/quickstart](https://yandex.cloud/en/docs/cli/quickstart)                                       |
| yc init docs             | Документация команды `yc init`      | [https://yandex.cloud/en/docs/cli/cli-ref/init](https://yandex.cloud/en/docs/cli/cli-ref/init)                                   |
| SSH keys in Yandex Cloud | SSH-ключи для ВМ / деплоя           | [https://yandex.cloud/en/docs/compute/operations/vm-connect/ssh](https://yandex.cloud/en/docs/compute/operations/vm-connect/ssh) |

Yandex Cloud CLI — официальный инструмент для управления ресурсами облака из командной строки; команда `yc init` используется для первичной инициализации CLI-профиля. ([Yandex Cloud][11])

Команда установки yc CLI на Windows из PowerShell:

```powershell
iex (New-Object System.Net.WebClient).DownloadString('https://storage.yandexcloud.net/yandexcloud-yc/install.ps1')
```

Потом:

```powershell
yc --version
yc init
```

SSH-ключ для демонстрации:

```powershell
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\ai_camp_demo_key"
type "$env:USERPROFILE\.ssh\ai_camp_demo_key.pub"
Remove-Item "$env:USERPROFILE\.ssh\ai_camp_demo_key" -Force
Remove-Item "$env:USERPROFILE\.ssh\ai_camp_demo_key.pub" -Force
```

---

# 11. Дополнительные AI-сервисы из PDF

| Сервис                   | Для чего                                       | Ссылка                                                                                         |
| ------------------------ | ---------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| NotebookLM               | Работа с документами, источниками, конспектами | [https://notebooklm.google.com/](https://notebooklm.google.com/)                               |
| NotebookLM official site | Основная страница NotebookLM                   | [https://notebooklm.google/](https://notebooklm.google/)                                       |
| NotebookLM Help          | Справка NotebookLM                             | [https://support.google.com/notebooklm/](https://support.google.com/notebooklm/)               |
| Lovable                  | AI-разработка веб-приложений                   | [https://lovable.dev/](https://lovable.dev/)                                                   |
| Lovable docs             | Документация Lovable                           | [https://docs.lovable.dev/introduction/welcome](https://docs.lovable.dev/introduction/welcome) |
| Lovable pricing          | Тарифы Lovable                                 | [https://lovable.dev/pricing](https://lovable.dev/pricing)                                     |
| Manus                    | AI-агент для задач и автоматизации             | [https://manus.im/](https://manus.im/)                                                         |
| Manus app                | Вход в Manus                                   | [https://manus.im/app](https://manus.im/app)                                                   |
| Manus docs               | Документация Manus                             | [https://manus.im/docs/introduction/welcome](https://manus.im/docs/introduction/welcome)       |
| Exa                      | Поиск/API для AI-агентов                       | [https://exa.ai/](https://exa.ai/)                                                             |
| Exa dashboard            | Dashboard Exa                                  | [https://dashboard.exa.ai/](https://dashboard.exa.ai/)                                         |
| Exa API keys             | API-ключи Exa                                  | [https://dashboard.exa.ai/api-keys](https://dashboard.exa.ai/api-keys)                         |
| Exa docs                 | Документация Exa                               | [https://docs.exa.ai/](https://docs.exa.ai/)                                                   |

NotebookLM, Lovable, Manus и Exa соответствуют дополнительным сервисам из PDF; Exa позиционируется как web search / crawling / SERP API для AI-сценариев.  ([Google NotebookLM][12])

---

# 12. Проверочные команды после установки

```powershell
winget --version
wsl --status
node -v
npm -v
npx -v
python --version
py --version
pip --version
uv --version
bun --version
git --version
docker --version
docker run hello-world
claude --version
codex --version
gemini --version
yc --version
yc config list
```

---

# 13. Минимальный install-порядок для твоего демонстрационного проекта

```text
1. Windows Terminal / PowerShell
2. winget
3. WSL
4. Node.js LTS
5. npm / npx
6. Python
7. pip
8. uv
9. Bun
10. Git for Windows
11. Docker Desktop
12. Claude Desktop
13. Claude Code CLI
14. Codex CLI
15. Gemini CLI
16. Telegram Desktop
17. GitHub account
18. Telegram bot через BotFather
19. CHAT_ID через userinfobot
20. Yandex Cloud account
21. yc CLI
22. yc init
23. SSH demo-key
24. NotebookLM
25. Lovable
26. Manus
27. Exa API key, опционально
```

Главное уточнение: в самом PDF обязательный минимум — Claude Desktop/Codex и подписка; полная подготовка — Node.js, Git, Docker, Claude Code CLI, GitHub, Telegram-бот, Яндекс Облако, yc CLI, SSH-ключ и дополнительные AI-сервисы. Python, pip, winget, uv и Bun — это уже усиление твоего демонстрационного dev-окружения, а не обязательный пункт памятки.

[1]: https://learn.microsoft.com/en-us/windows/package-manager/winget/?utm_source=chatgpt.com "Use WinGet to install and manage applications"
[2]: https://nodejs.org/en/download?utm_source=chatgpt.com "Download Node.js"
[3]: https://bun.com/docs/installation?utm_source=chatgpt.com "Installation"
[4]: https://www.python.org/downloads/?utm_source=chatgpt.com "Download Python"
[5]: https://git-scm.com/install/windows?utm_source=chatgpt.com "Git - Install for Windows"
[6]: https://docs.docker.com/desktop/setup/install/windows-install/?utm_source=chatgpt.com "Install Docker Desktop on Windows"
[7]: https://claude.com/download?utm_source=chatgpt.com "Download Claude | Claude by Anthropic"
[8]: https://developers.openai.com/codex/cli?utm_source=chatgpt.com "Codex CLI"
[9]: https://github.com/google-gemini/gemini-cli?utm_source=chatgpt.com "google-gemini/gemini-cli: An open-source AI ..."
[10]: https://desktop.telegram.org/?utm_source=chatgpt.com "Telegram Desktop"
[11]: https://yandex.cloud/en/docs/cli/operations/install-cli?utm_source=chatgpt.com "CLI installation | Yandex Cloud - Documentation"
[12]: https://notebooklm.google/?utm_source=chatgpt.com "Google NotebookLM | AI Research Tool & Thinking Partner"
