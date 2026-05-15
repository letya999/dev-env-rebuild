# Полный ручной гайд установки dev-окружения для AI Camp
# Версия: 2026-05-15
# Без скриптов — всё вручную, шаг за шагом

Иди строго сверху вниз. Не пропускай шаги — многие зависят от предыдущих.
Там где написано ПЕРЕЗАГРУЗКА или ПЕРЕЗАПУСК POWERSHELL — это обязательно.

================================================================
ПОЛЕЗНЫЕ КОМАНДЫ POWERSHELL (Шпаргалка):
  cls или clear      - очистить экран (стирает весь текст в окне терминала)
  cd <путь>          - перейти в нужную папку (пример: cd C:\Projects)
  cd ..              - выйти на уровень вверх (в родительскую папку)
  mkdir <имя>        - создать новую папку
  ls или dir         - показать содержимое текущей папки
  pwd                - показать текущий путь (где ты сейчас находишься)
  
  Как открыть НОВОЕ окно PowerShell от Администратора:
  Start-Process powershell -Verb runAs
================================================================

================================================================
ПОРЯДОК УСТАНОВКИ (кратко):
  1.  PowerShell + winget + OpenSSH  (системная подготовка)
  2.  Node.js LTS                    (основа для CLI-инструментов)
  3.  Python 3.14
  4.  Git for Windows + git config
  5.  Docker Desktop                 (потребует перезагрузку!)
  6.  Claude Desktop + Claude Code CLI + подписка
  7.  Gemini CLI
  8.  Codex CLI (опционально)
  9.  GitHub — аккаунт
  10. Telegram Desktop + бот
  11. Яндекс Облако + yc CLI + SSH-ключ
  12. AI-сервисы: NotebookLM, Lovable, Manus, Exa
  13. Финальная проверка
================================================================


## Шаг 1: Подготовка системы

### 1.1 Открыть PowerShell от имени администратора

  1. Нажми Win → введи "PowerShell" в поиске
  2. Правый клик на "Windows PowerShell" или "Терминал"
  3. Выбери "Запуск от имени администратора"
  4. Нажми "Да" в окне разрешения (UAC)

  Все следующие команды выполняй в этом окне.

### 1.2 Проверить winget

  winget --version

  Если выдаёт версию (например v1.9.x) — всё хорошо, переходи дальше.

  Если команда не найдена:
    1. Открой Microsoft Store
    2. Найди "App Installer"
    3. Нажми "Обновить" или "Установить"
    4. После установки ЗАКРОЙ и ОТКРОЙ PowerShell заново

### 1.3 Проверить и включить OpenSSH

  Проверь:
    Get-WindowsCapability -Online -Name OpenSSH.Client*

  Если State: NotPresent — установи:
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

  !! После установки OpenSSH может потребоваться перезагрузка.
  Если попросит — перезагрузись и снова открой PowerShell от администратора.

  Проверка после установки:
    ssh -V


## Шаг 2: Node.js LTS

Node.js нужен первым — от него зависят Claude Code CLI, Codex CLI и Gemini CLI.

### Через winget (рекомендуется):

  winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-package-agreements --accept-source-agreements

### Через браузер (если winget не работает):

  1. Открой: https://nodejs.org/en/download
  2. Нажми "Windows Installer (.msi)" → выбери LTS
  3. Запусти скачанный .msi файл
  4. В установщике: Next → Next → I accept → Next → Next → Install → Finish

!! ОБЯЗАТЕЛЬНО: После установки ЗАКРОЙ и ОТКРОЙ PowerShell заново.
   node и npm появятся в PATH только после перезапуска.

Проверка:
  node -v       # должно быть v22.x или v24.x
  npm -v        # должно быть 10+
  npx -v


## Шаг 3: Python 3.14

### Через winget:

  winget install --id Python.Python.3.14 -e --source winget --accept-package-agreements --accept-source-agreements

### Через браузер:

  1. Открой: https://www.python.org/downloads/windows/
  2. Нажми на "Python 3.14.x" → скачай "Windows installer (64-bit)"
  3. Запусти установщик
  4. ВАЖНО: поставь галочку "Add Python.exe to PATH" внизу первого экрана
  5. Нажми "Install Now"
  6. После установки нажми "Close"

!! После установки ЗАКРОЙ и ОТКРОЙ PowerShell заново.

Проверка:
  python --version    # должно быть Python 3.14.x
  pip --version


## Шаг 4: Git for Windows + настройка identity

### Через winget:

  winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements

### Через браузер:

  1. Открой: https://gitforwindows.org/ (альтернатива: https://git-scm.com/download/win)
  2. Скачай "64-bit Git for Windows Setup"
  3. Запусти установщик
  4. Нажимай Next оставляя все настройки по умолчанию
  5. На экране "Choosing the default editor" — выбери Notepad (или оставь Vim)
  6. На экране "Adjusting your PATH environment":
     выбери "Git from the command line and also from 3rd-party software" (обычно стоит)
  7. Все остальные экраны — Next → Install → Finish

!! После установки ЗАКРОЙ и ОТКРОЙ PowerShell заново.

### Настроить git identity (ОБЯЗАТЕЛЬНО — без этого git не даст делать коммиты):

  git config --global user.name "Твоё Имя Фамилия"
  git config --global user.email "твой@email.com"

Проверка:
  git --version
  git config --global user.name      # выведет твоё имя
  git config --global user.email     # выведет твой email


## Шаг 5: Docker Desktop

!! Docker требует WSL2. WSL2 при установке может потребовать ПЕРЕЗАГРУЗКУ.
   Это нормально — будь готов потерять 2-3 минуты на перезагрузку.

### 5.1 Установить / обновить WSL

  В PowerShell от администратора выполни:
    wsl --install

  Если WSL уже установлен — обнови его:
    wsl --update

  !! Если WSL не был установлен — ПОТРЕБУЕТСЯ ПЕРЕЗАГРУЗКА.
     Нажми "Да" или "Restart" → после перезагрузки:
     - Может открыться окно Ubuntu с предложением создать пользователя Linux
     - Введи любое имя и пароль, или просто закрой это окно — оно не нужно для Docker
     - Открой PowerShell от администратора заново

### 5.2 Установить Docker Desktop

  Через winget:
    winget install --id Docker.DockerDesktop -e --source winget --accept-package-agreements --accept-source-agreements

  Через браузер:
    1. Открой: https://www.docker.com/products/docker-desktop/
    2. Нажми "Download Docker Desktop for Windows"
    3. Запусти "Docker Desktop Installer.exe"
    4. В установщике:
       - "Use WSL 2 instead of Hyper-V" — оставь галочку (должна стоять)
       - "Add shortcut to desktop" — по желанию
    5. OK → Install → Close

  !! ПОЧТИ ВСЕГДА после установки Docker Desktop потребуется ПЕРЕЗАГРУЗКА.
     Нажми "Close and restart" или перезагрузись вручную.

### 5.3 Первый запуск Docker Desktop

  1. Найди Docker Desktop в меню Пуск → запусти
  2. При первом запуске откроется окно с лицензией — нажми "Accept"
  3. Дальше может предложить войти в Docker аккаунт — пропусти (Skip) или войди
  4. Жди пока иконка кита в системном трее (правый нижний угол) перестанет мигать
     Когда иконка стала статичной — Docker готов
  5. Если появилось окно с просьбой установить WSL kernel update:
     - Нажми "Download and install"
     - После установки нажми "Restart Docker"

Проверка:
  docker --version
  docker run hello-world

  Ожидаемый вывод hello-world:
    "Hello from Docker! This message shows that your installation appears to be working correctly."


## Шаг 6: Claude — аккаунт, Desktop, CLI, подписка

### 6.1 Создать аккаунт Anthropic

  1. Открой: https://claude.ai
  2. Нажми "Sign up"
  3. Выбери способ регистрации: Google, Apple или email
  4. Если email — введи адрес и пароль, подтверди email (письмо придёт на почту)
  5. Дальше Claude попросит указать имя и принять условия — заполни и нажми Continue

### 6.2 Установить Claude Desktop

  Через winget:
    winget install --id Anthropic.Claude -e --source winget --accept-package-agreements --accept-source-agreements

  Через браузер:
    1. Открой: https://claude.com/download
    2. Нажми "Download for Windows"
    3. Запусти установщик → Install → Finish
    4. Claude Desktop запустится автоматически

  Войти в Claude Desktop:
    1. Открой Claude Desktop из меню Пуск (если не открылся сам)
    2. Нажми "Sign in"
    3. Войди через тот же аккаунт что создал в шаге 6.1

### 6.3 Установить Claude Code CLI

  Вариант A — winget (рекомендуется):
    winget install --id Anthropic.ClaudeCode -e --source winget --accept-package-agreements --accept-source-agreements

  Вариант B — npm (если winget не сработал):
    npm install -g @anthropic-ai/claude-code

  !! После установки ЗАКРОЙ и ОТКРОЙ PowerShell заново.

  Авторизовать Claude Code CLI:
    claude

  Откроется браузер — войди в тот же аккаунт Anthropic.
  После входа терминал напишет "Logged in as ..."

Проверка:
  claude --version

### 6.4 Оформить подписку (ОБЯЗАТЕЛЬНО — без неё Claude не работает)

  Вариант A — Подписка Claude (для Desktop и CLI):
    Открой: https://claude.ai/settings/billing
    Минимум: Claude Pro ($20/мес)
    Рекомендуется: Claude Max ($100/мес) — лимит Pro точно кончится за 3 дня интенсива
    Введи данные карты → нажми "Subscribe"

  Вариант B — API-баланс (для разработчиков):
    Открой: https://console.anthropic.com/settings/billing
    Нажми "Add credit" → пополни на $20-50 → введи данные карты
    Создай API-ключ:
      Открой: https://console.anthropic.com/settings/keys
      Нажми "Create key" → придумай название → "Create key"
      Скопируй ключ и сохрани — он показывается ТОЛЬКО ОДИН РАЗ!
      Сохрани как ANTHROPIC_API_KEY
    Понадобится на первом дне кэмпа.


## Шаг 7: Gemini CLI

Требует Node.js (шаг 2). Убедись что node -v работает.

  npm install -g @google/gemini-cli

Проверка:
  gemini --version

При первом запуске `gemini` попросит авторизоваться через Google-аккаунт.
Следуй инструкциям в терминале — откроется браузер.


## Шаг 8: Codex CLI (опционально — альтернатива Claude Code)

Пропусти этот шаг если используешь Claude Code — устанавливать оба не нужно.

### 8.1 Создать аккаунт OpenAI (если нет):
  1. Открой: https://platform.openai.com
  2. Нажми "Sign up"
  3. Зарегистрируйся через email или Google
  4. Подтверди email

### 8.2 Оформить подписку ChatGPT Plus (если не используешь Claude):
  Открой: https://platform.openai.com/settings/organization/billing/overview
  Нажми "Add payment method" → введи карту → выбери ChatGPT Plus ($20/мес)

### 8.3 Установить Codex CLI:

  npm install -g @openai/codex

Проверка:
  codex --version

  При первом запуске `codex` — войди через ChatGPT или API key.

### 8.4 Codex Desktop (GUI, опционально):
  Открой: https://chatgpt.com/codex
  Скачай и установи приложение.


## Шаг 9: GitHub — аккаунт

  1. Открой: https://github.com/signup
  2. Введи username — придумай запоминающийся, он будет виден всем
     Пример: ivan-petrov-dev
  3. Введи email (тот же что везде, или отдельный)
  4. Придумай и введи пароль
  5. Реши капчу (кликни на картинки или введи код)
  6. Выбери тариф: Free
  7. Подтверди email — письмо придёт на почту, нажми кнопку в письме
  8. Запомни свой GitHub username — понадобится на первом дне кэмпа

  Войти позже: https://github.com/login


## Шаг 10: Telegram Desktop + бот

### 10.1 Установить Telegram Desktop

  Вариант A — прямая ссылка (64-bit):
    1. Открой: https://telegram.org/dl/desktop/win64
    2. Запусти "tsetup-x64.exe"
    3. Нажми "Далее" → "Установить" → "Готово"

  Вариант B — Microsoft Store:
    1. Открой Microsoft Store
    2. Найди "Telegram Desktop"
    3. Нажми "Получить" → "Установить"

  Вариант C — официальная страница:
    1. Открой: https://desktop.telegram.org
    2. Нажми "Get Telegram for Windows"
    3. Скачай и запусти установщик

  Войти в Telegram:
    1. Открой Telegram Desktop
    2. Нажми "Start Messaging"
    3. Выбери страну, введи номер телефона
    4. Получи код: придёт в Telegram на телефоне или SMS
    5. Введи код → Enter

### 10.2 Создать Telegram-бота (для получения BOT_TOKEN)

  1. В Telegram нажми на строку поиска (лупа) → введи @BotFather
     Или сразу открой: https://t.me/BotFather
  2. Нажми Start (кнопка внизу, если видишь её первый раз)
  3. Отправь команду: /newbot
  4. BotFather спросит название — введи любое (например: My Camp Bot)
     Это отображаемое имя, не техническое
  5. BotFather спросит username — введи техническое имя, ОБЯЗАТЕЛЬНО заканчивается на _bot
     Пример: my_camp_2026_bot
     Если имя занято — придумай другое (добавь цифры)
  6. BotFather ответит сообщением вида:
     "Done! Congratulations... Use this token to access the HTTP API:
     123456789:AABBccDDeeFFggHH..."
  7. Скопируй и сохрани BOT_TOKEN в надёжном месте (заметки / файл)
     Формат: цифры:буквы-цифры (около 46 символов после двоеточия)

### 10.3 Узнать свой Chat ID (CHAT_ID)

  1. В Telegram нажми поиск → введи @userinfobot
     Или открой: https://t.me/userinfobot
  2. Нажми Start
  3. Бот ответит сообщением вида:
     "First Name: Иван
      Last Name: Петров
      Id: 123456789"
  4. Скопируй число после "Id:" — это и есть твой CHAT_ID
  5. Сохрани CHAT_ID рядом с BOT_TOKEN

  BOT_TOKEN и CHAT_ID понадобятся на ВТОРОМ дне кэмпа.


## Шаг 11: Яндекс Облако + yc CLI + SSH-ключ

### 11.1 Регистрация в Яндекс Облаке

  1. Открой: https://cloud.yandex.ru
  2. Нажми "Начать бесплатно" (если нет аккаунта) или "Войти"
  3. Войди через Яндекс ID (аккаунт на yandex.ru)
     Если нет Яндекс ID — нажми "Создать аккаунт" и зарегистрируйся
  4. После входа откроется форма создания организации / платёжного аккаунта:
     - Имя: введи своё имя
     - Тип: Физическое лицо
     - Нажми "Создать"
  5. Привязка карты (ОБЯЗАТЕЛЬНО для активации гранта):
     - Перейди в раздел Billing: https://billing.yandex.cloud
     - Нажми "Привязать карту"
     - Введи номер карты, срок, CVV
     - Нажми "Привязать"
     - Деньги НЕ спишутся — это верификация
  6. Начальный грант — появится предложение после привязки карты:
     - Нажми "Активировать грант"
     - Получишь ~4000 руб на 60 дней — бесплатно для новых аккаунтов

  Консоль управления: https://console.cloud.yandex.ru

### 11.2 Установить yc CLI

  !! winget НЕ поддерживает yc CLI.

  Неинтерактивный вариант без install.ps1 prompt:

    $dir = "$env:USERPROFILE\yandex-cloud\bin"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Invoke-WebRequest "https://storage.yandexcloud.net/yandexcloud-yc/release/yc_windows_amd64.zip" -OutFile "$env:TEMP\yc_windows_amd64.zip"
    Expand-Archive "$env:TEMP\yc_windows_amd64.zip" -DestinationPath $dir -Force
    [Environment]::SetEnvironmentVariable("Path", "$([Environment]::GetEnvironmentVariable('Path', 'User'));$dir", "User")

  Интерактивная альтернатива через официальный PowerShell-скрипт:

    iex (New-Object System.Net.WebClient).DownloadString('https://storage.yandexcloud.net/yandexcloud-yc/install.ps1')

  Установщик скачает yc (~30 MB) и добавит его в PATH.

  !! ВАЖНО: После установки ЗАКРОЙ и ОТКРОЙ PowerShell заново.

Проверка:
  yc --version

### 11.3 yc init — подключение CLI к аккаунту

  В PowerShell (новом после перезапуска) выполни:
    yc init

  Что произойдёт шаг за шагом:
    1. Терминал напишет "Go to the following link..." и откроет браузер
    2. В браузере войди через Яндекс-аккаунт (тот же что в шаге 11.1)
    3. Нажми "Разрешить" на странице авторизации
    4. Браузер покажет "Код авторизации получен" — вернись в терминал
    5. Терминал спросит: "Please select the cloud" — нажми Enter (первый вариант)
    6. Терминал спросит: "Please choose a folder" — нажми Enter (первый вариант)
    7. Терминал спросит: "Do you want to configure a default Compute zone?"
       Введи "y" → нажми Enter
    8. Появится список зон — выбери "ru-central1-a" (обычно первый вариант) → Enter

Проверка:
  yc config list

  Должно показать:
    token: t1.xxx...
    cloud-id: b1gxxx...
    folder-id: b1gxxx...
    compute-default-zone: ru-central1-a

### 11.4 Создать SSH-ключ (для подключения к ВМ)

  В PowerShell выполни:
    ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\id_ed25519" -C "ai-camp"

  На вопросы установщика:
    "Enter passphrase" → нажми Enter (без пароля, для простоты)
    "Enter same passphrase again" → нажми Enter

  Посмотреть публичный ключ:
    Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub"

  Скопируй всё содержимое — строка начинается с "ssh-ed25519 AAAA..."

### 11.5 Загрузить SSH-ключ в Яндекс Облако

  Способ A — через yc CLI (рекомендуем):
    yc compute ssh-key create --name ai-camp-key --public-key-path "$env:USERPROFILE\.ssh\id_ed25519.pub"

    Проверка: yc compute ssh-key list

  Способ B — через браузер:
    1. Открой: https://console.cloud.yandex.ru
    2. В правом верхнем углу нажми на своё имя / аватар
    3. Выбери "Мои данные"
    4. Перейди на вкладку "SSH-ключи"
    5. Нажми "Создать SSH-ключ"
    6. Вставь содержимое публичного ключа (строка из шага 11.4)
    7. Имя ключа: ai-camp-key → нажми "Создать"

  Документация: https://yandex.cloud/ru/docs/compute/operations/vm-connect/ssh


## Шаг 12: Дополнительные AI-сервисы

### NotebookLM (нужен Google-аккаунт / Gmail)

  1. Открой: https://notebooklm.google.com
  2. Нажми "Try NotebookLM"
  3. Откроется страница входа Google — войди через Gmail
  4. NotebookLM аккаунт создаётся автоматически — отдельной регистрации нет

### Lovable

  1. Открой: https://lovable.dev
  2. Нажми "Sign up"
  3. Рекомендуется: "Continue with GitHub" → войди в GitHub-аккаунт
     Или: "Continue with Email" → введи email и пароль
  4. Документация: https://docs.lovable.dev/introduction/welcome

### Manus

  1. Открой: https://manus.im
  2. Нажми "Get started" или "Sign up"
  3. Зарегистрируйся через email или Google
  4. Приложение после входа: https://manus.im/app
  5. Документация: https://manus.im/docs/introduction/welcome

### Exa (ОПЦИОНАЛЬНО — поиск и данные для AI-агентов)

  1. Открой: https://exa.ai
  2. Нажми "Get started"
  3. Зарегистрируйся через email или Google
  4. При регистрации автоматически выдаётся $10 на API — бесплатно
  5. Перейди в дашборд: https://dashboard.exa.ai
  6. API-ключи: https://dashboard.exa.ai/api-keys → "Create API Key"
  7. Скопируй ключ и сохрани как EXA_API_KEY
  8. Документация: https://docs.exa.ai


## Шаг 13: Финальная проверка

Открой PowerShell и выполни:

  # Версии инструментов:
  node -v               # v22.x или v24.x
  npm -v                # 10+
  python --version      # Python 3.14.x
  git --version
  docker --version
  claude --version
  gemini --version
  codex --version       # опционально
  yc --version

  # Docker работает:
  docker run hello-world
  # Ожидаемо: "Hello from Docker!"

  # Git identity настроена:
  git config user.name
  git config user.email

  # yc настроен:
  yc config list
  # Должно показывать token, cloud-id, folder-id, compute-default-zone

================================================================
ИТОГОВЫЙ ЧЕКЛИСТ В ДЕНЬ КЭМПА:

[ ] Node.js установлен (node -v работает)
[ ] Python установлен (python --version работает)
[ ] Git установлен, user.name и user.email настроены
[ ] Docker Desktop запущен (иконка кита в трее, docker hello-world прошёл)
[ ] Claude Desktop — запущен и залогинен
[ ] Claude Code CLI — авторизован (claude --version работает)
[ ] Подписка Claude Pro / Max — активна (или API-баланс пополнен)
[ ] Gemini CLI — установлен и авторизован (gemini --version работает)
[ ] GitHub — аккаунт есть, username запомнен
[ ] Telegram Desktop — установлен, вошёл
[ ] BOT_TOKEN — сохранён (создан через @BotFather)
[ ] CHAT_ID — сохранён (получен через @userinfobot)
[ ] Яндекс Облако — аккаунт есть, биллинг подтверждён, грант активирован
[ ] yc init — выполнен (yc config list показывает данные)
[ ] SSH-ключ — создан и загружен в Яндекс Облако
[ ] NotebookLM — вход через Google работает
[ ] Lovable — аккаунт создан
[ ] Manus — аккаунт создан
[ ] Ноутбук заряжен, зарядка в сумке
[ ] Телефон с возможностью раздачи мобильного интернета
================================================================
