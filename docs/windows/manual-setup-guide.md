# Ручной гайд по настройке окружения для AI Camp
# Версия: финальная, 2026-05-15
# Источник ссылок: docs/research/sources.md

Этот гайд — твоя единственная точка входа после запуска скриптов.
Иди по шагам сверху вниз. Не пропускай шаги.

---
**ЧТО ДЕЛАЮТ СКРИПТЫ АВТОМАТИЧЕСКИ (делать не нужно):**
- Устанавливают: Node.js LTS, Git (https://gitforwindows.org), Docker Desktop, Python 3.12
- Устанавливают: Claude Code CLI, Claude Desktop (winget)
- Устанавливают: yc CLI (Яндекс Облако)
- Генерируют SSH-ключ (`~/.ssh/id_ed25519`)
> **ВНИМАНИЕ**: Gemini CLI удаляется вместе с npm-global — переустанови его в шаге 0d.

**ЧТО НУЖНО СДЕЛАТЬ ВРУЧНУЮ (этот гайд):**
- Переустановить Gemini CLI (шаг 0d)
- Войти во все аккаунты (Claude, GitHub, Telegram)
- Оформить подписку (Claude Pro / Max)
- Настроить git identity (имя + email)
- Запустить Docker Desktop и проверить
- Выполнить `yc init` (интерактивный OAuth)
- Загрузить SSH-ключ в Яндекс Облако
- Создать Telegram-бота
- Зарегистрироваться на AI-сервисах
---

## Шаг 0: Запуск скриптов установки

Открой PowerShell от имени администратора в корне проекта.

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Шаг 0a: базовые инструменты (Node.js, Git, Docker Desktop, Python)
.\platforms\windows\install\01_install_dev_environment_demo.ps1 -Execute
```

> **ВАЖНО**: После установки Docker Desktop — закрой и открой PowerShell заново. Если Docker попросил перезагрузку — перезагрузись и вернись сюда.

```powershell
# Шаг 0b: AI-инструменты (Claude Code CLI, Claude Desktop, yc CLI)
.\platforms\windows\install\04_install_ai_tools.ps1 -Execute
```

> **ВАЖНО**: Закрой и открой PowerShell заново (нужно для yc и Claude в PATH).

```powershell
# Шаг 0c: SSH-ключ для Яндекс Облака
.\platforms\windows\install\05_ssh_key.ps1 -Execute

# Шаг 0d: Переустановка Gemini CLI (был в npm-global, удалён вместе с ним)
npm install -g @google/gemini-cli
gemini --version
# Если просит авторизацию — следуй инструкциям в терминале
```

## Шаг 1: Git — настройка identity

После переустановки Git теряет имя и email. Настрой сразу:

```powershell
git config --global user.name "Твоё Имя Фамилия"
git config --global user.email "твой@email.com"
```

Проверка: `git config --global --list`

## Шаг 2: Docker Desktop — запуск и проверка

1. Найди Docker Desktop в меню Пуск и запусти его
2. Жди пока иконка кита в системном трее (правый нижний угол) перестанет мигать
3. Если Docker просит включить WSL2 или VirtualMachinePlatform — нажми OK, перезагрузись
4. После запуска проверь в PowerShell:
   ```powershell
   docker run hello-world
   ```
   Ожидаемый вывод: `"Hello from Docker! This message shows that your installation..."`

## Шаг 3: Claude — вход, авторизация CLI и подписка

### 3.1 Создать аккаунт Anthropic (если ещё нет)
Зарегистрируйся: [claude.ai](https://claude.ai)
Или войди, если аккаунт уже есть.

### 3.2 Войти в Claude Desktop (GUI приложение)
Открой Claude Desktop из меню Пуск.
Если не установлен скриптом — скачай: [claude.com/download](https://claude.com/download)
Войди в свой аккаунт Anthropic.

### 3.3 Авторизовать Claude Code CLI (терминал)
В PowerShell выполни:
```powershell
claude
```
Откроется браузер — войди в тот же аккаунт Anthropic.
После входа терминал напишет `"Logged in as ..."`.
Проверка: `claude --version`

### 3.4 Оформить подписку (ОБЯЗАТЕЛЬНО — без неё Claude не работает)
**Вариант A — Подписка на Claude (для Desktop и CLI):**
  Открой: [claude.ai/settings/billing](https://claude.ai/settings/billing)
  Минимум: Claude Pro ($20/мес)
  Рекомендуется: Claude Max ($100/мес) — на 3 дня интенсива лимит Pro точно кончится

**Вариант B — API-баланс (для разработчиков):**
  Открой биллинг API: [console.anthropic.com/settings/billing](https://console.anthropic.com/settings/billing)
  Пополни на $20-50
  Создай API-ключ: [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys) -> "Create key"
  Нажми "Create key", скопируй ключ, сохрани — он показывается только один раз!
  Понадобится на первом дне кэмпа.

### 3.5 Альтернатива: Codex от ChatGPT (если не используешь Claude)
Подписка ChatGPT Plus ($20/мес): [platform.openai.com](https://platform.openai.com)
Скачать Codex (GUI): [chatgpt.com/codex](https://chatgpt.com/codex)

Установка Codex CLI (если не установлен скриптом):
```powershell
npm install -g @openai/codex
```
Проверка: `codex --version`

API-ключ OpenAI: [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
Биллинг API: [platform.openai.com/settings/organization/billing/overview](https://platform.openai.com/settings/organization/billing/overview)

## Шаг 4: GitHub — аккаунт

1. Открой: [github.com/signup](https://github.com/signup)
2. Заполни: username (придумай запоминающийся), email, password
3. Реши капчу, выбери тариф Free
4. Подтверди email — письмо придёт на почту, нажми кнопку в письме
5. Запомни свой username — понадобится в первый день кэмпа

Войти позже: [github.com/login](https://github.com/login)

## Шаг 5: Telegram Desktop + бот

### 5.1 Установить Telegram Desktop (если не установлен)
* Вариант A — прямая ссылка: [telegram.org/dl/desktop/win64](https://telegram.org/dl/desktop/win64)
* Вариант B — основная страница: [desktop.telegram.org](https://desktop.telegram.org)
* Вариант C — Microsoft Store: поиск "Telegram Desktop"

Зарегистрируйся / войди по номеру телефона.

### 5.2 Создать своего Telegram-бота (для получения BOT_TOKEN)
1. Открой BotFather: [@BotFather](https://t.me/BotFather)
   (или найди `@BotFather` через поиск в Telegram)
2. Нажми Start (если первый раз)
3. Отправь команду: `/newbot`
4. Придумай название бота (например: My Camp Bot)
5. Придумай username — ОБЯЗАТЕЛЬНО оканчивается на `_bot`
   Пример: `my_camp_2026_bot`
6. BotFather пришлёт сообщение с токеном:
   `"Use this token to access the HTTP API: 123456789:AABBccDDeeFF..."`
7. Скопируй и сохрани `BOT_TOKEN` в надёжном месте (заметки / файл)

### 5.3 Узнать свой Chat ID (для получения CHAT_ID)
1. Открой userinfobot: [@userinfobot](https://t.me/userinfobot)
   (или найди `@userinfobot` через поиск в Telegram)
2. Нажми Start
3. Бот ответит сообщением вида: `"Id: 123456789"`
4. Скопируй и сохрани этот `CHAT_ID` рядом с `BOT_TOKEN`

> **Примечание**: `BOT_TOKEN` и `CHAT_ID` понадобятся на ВТОРОМ дне кэмпа.

## Шаг 6: Яндекс Облако + yc CLI

### 6.1 Регистрация в Яндекс Облаке
1. Открой: [cloud.yandex.ru](https://cloud.yandex.ru)
2. Нажми "Начать бесплатно" (или "Войти" если есть аккаунт Яндекса)
3. Войди через аккаунт Яндекса (Яндекс ID)
4. Заполни данные организации (можно физлицо)
5. Привяжи карту в разделе Billing — деньги НЕ спишутся
6. После привязки карты ищи предложение "Начальный грант"
   Активируй грант: ~4000 руб / 60 дней — бесплатно для новых аккаунтов

Консоль управления: [console.cloud.yandex.ru](https://console.cloud.yandex.ru)

### 6.2 yc init — подключение CLI к аккаунту
> **ВАЖНО**: сначала закрой и открой PowerShell (если ещё не сделал после шага 0).

В PowerShell выполни:
```powershell
yc init
```
Что произойдёт:
1. Откроется браузер — войди через Яндекс-аккаунт (тот же что в шаге 6.1)
2. Вернись в PowerShell
3. Выбери облако (Cloud) — Enter для единственного варианта
4. Выбери каталог (Folder) — Enter для единственного варианта
5. Выбери зону по умолчанию — выбери "ru-central1-a" (первый вариант)

Проверка: `yc config list`

### 6.3 SSH-ключ — загрузка в Яндекс Облако

Посмотреть публичный ключ (уже создан скриптом 05_ssh_key.ps1):
```powershell
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub
```
Скопируй всё содержимое (строка начинается с "ssh-ed25519 AAAA...")

Загрузить ключ — СПОСОБ A (через yc CLI, рекомендуем):
```powershell
yc compute ssh-key create --name ai-camp-key --public-key-path $env:USERPROFILE\.ssh\id_ed25519.pub
```
Проверка: `yc compute ssh-key list`

Загрузить ключ — СПОСОБ B (через браузер):
1. Открой: [console.cloud.yandex.ru](https://console.cloud.yandex.ru)
2. В правом верхнем углу нажми на своё имя / аватар
3. Выбери "Мои данные"
4. Перейди на вкладку "SSH-ключи"
5. Нажми "Создать SSH-ключ"
6. Вставь содержимое публичного ключа в поле "Публичный ключ"
7. Дай имя ключу: `ai-camp-key` -> нажми "Создать"

Документация: [yandex.cloud/ru/docs/compute/operations/vm-connect/ssh](https://yandex.cloud/ru/docs/compute/operations/vm-connect/ssh)

### 6.4 ОПЦИОНАЛЬНО: демо-ключ (создать, посмотреть, удалить)

  Если хочешь убедиться что ssh-keygen работает, или показать студентам как это выглядит —
  создай временный ключ, посмотри его и сразу удали:

    ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\ai_camp_demo_key" -N ""
    Get-Content "$env:USERPROFILE\.ssh\ai_camp_demo_key.pub"
    Remove-Item "$env:USERPROFILE\.ssh\ai_camp_demo_key", "$env:USERPROFILE\.ssh\ai_camp_demo_key.pub" -Force

  То же самое через скрипт (делает ровно эти три команды):
    .\platforms\windows\install\02_demo_ssh_key_create_and_remove.ps1 -Execute

  ВАЖНО: демо-ключ удаляется сразу. Для Яндекс Облака используется id_ed25519 из шага 0c.

## Шаг 7: Дополнительные AI-сервисы

### NotebookLM (нужен Google-аккаунт)
Открой: [notebooklm.google.com](https://notebooklm.google.com)
Нажми "Try NotebookLM" -> войди через Google-аккаунт (Gmail)
Готово — аккаунт создаётся автоматически через Google.

### Lovable (AI-разработка веб-приложений)
Открой: [lovable.dev](https://lovable.dev)
Нажми "Sign up"
Зарегистрируйся через GitHub (рекомендуем) или email
Документация: [docs.lovable.dev/introduction/welcome](https://docs.lovable.dev/introduction/welcome)

### Manus (AI-агент для задач)
Открой: [manus.im](https://manus.im)
Нажми "Get started" или "Sign up"
Зарегистрируйся через email or Google
Приложение: [manus.im/app](https://manus.im/app)

### Exa (ОПЦИОНАЛЬНО — поиск для AI-агентов)
Открой: [exa.ai](https://exa.ai)
Нажми "Get started" -> зарегистрируйся (email или Google)
При регистрации выдаётся $10 на API — бесплатно.
Перейди в дашборд: [dashboard.exa.ai](https://dashboard.exa.ai)
API-ключи: [dashboard.exa.ai/api-keys](https://dashboard.exa.ai/api-keys) -> "Create API Key"
Скопируй ключ и сохрани как `EXA_API_KEY`
Документация: [docs.exa.ai](https://docs.exa.ai)

## Шаг 8: Финальная проверка

Открой PowerShell и запусти скрипт проверки:

```powershell
.\platforms\windows\install\03_final_check.ps1
```

Дополнительные ручные проверки:

```powershell
# Docker:
docker run hello-world
# Ожидаемо: "Hello from Docker!"

# Все версии:
node -v                  # должно быть v18 или выше (сейчас v24 LTS)
npm -v
git --version
docker --version
claude --version
gemini --version
codex --version          # опционально
yc --version             # опционально

# Git identity:
git config user.name     # должно вывестись твоё имя
git config user.email    # должен вывестись твой email

# yc (если настроен):
yc config list           # должен показывать аккаунт, облако, каталог, зону
```

---
**ИТОГОВЫЙ ЧЕКЛИСТ В ДЕНЬ КЭМПА:**

- [ ] Claude Desktop — запущен и залогинен
- [ ] Claude Code CLI — авторизован (`claude` в терминале работает)
- [ ] Подписка Claude Pro / Max — активна (или API-баланс пополнен)
- [ ] Docker Desktop — запущен (иконка кита в трее, `docker hello-world` прошёл)
- [ ] `git user.name` и `user.email` — настроены
- [ ] Gemini CLI — переустановлен (`gemini --version` работает)
- [ ] `yc init` — выполнен (`yc config list` показывает данные)
- [ ] SSH-ключ — загружен в Яндекс Облако
- [ ] BOT_TOKEN — сохранён (создан через `@BotFather`)
- [ ] CHAT_ID — сохранён (получен через `@userinfobot`)
- [ ] GitHub — аккаунт есть, username запомнен
- [ ] Яндекс Облако — аккаунт есть, биллинг подтверждён, грант активирован
- [ ] NotebookLM — аккаунт Google, вход работает
- [ ] Lovable — аккаунт создан
- [ ] Manus — аккаунт создан
- [ ] Ноутбук заряжен, зарядка в сумке
- [ ] Телефон с возможностью раздачи мобильного интернета
---
