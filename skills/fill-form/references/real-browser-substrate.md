# Субстрат авторизованной сессии: Chrome Beta + CDP-attach

Скилл `fill-form` НЕ поднимает браузер сам. Он работает поверх авторизованной
сессии, которую готовит **человек** на pre-flight. Разделение ролей жёсткое: браузер
и логин — на человеке; attach по CDP и заполнение — на агенте; **пароль агенту не
передаётся**.

Этот субстрат живёт в репозитории **дня 2 — `browser-use-starter`**, НЕ в этом ките.
Скилл на него опирается; полная инструкция установки и запуска (все ОС) —
`browser-use-starter/INSTALL-chrome-beta.md`. Здесь — только то, что нужно скиллу
на входе.

## Что человек делает один раз (pre-flight)

1. Поднимает **Google Chrome Beta** (отдельный браузер, не основной Chrome) с
   открытым CDP-портом. `--user-data-dir` **обязателен** — без него Chrome не даёт
   remote-debugging на дефолтном профиле, а логины не сохранятся между запусками.

   macOS:
   ```bash
   "/Applications/Google Chrome Beta.app/Contents/MacOS/Google Chrome Beta" \
     --remote-debugging-port=9222 \
     --user-data-dir="$HOME/.chrome-beta-profile" &
   ```
   Linux: `google-chrome-beta --remote-debugging-port=9222 --user-data-dir="$HOME/.chrome-beta-profile" &`
   Windows (PowerShell): `Start-Process "C:\Program Files\Google\Chrome Beta\Application\chrome.exe" -ArgumentList '--remote-debugging-port=9222', "--user-data-dir=$env:USERPROFILE\.chrome-beta-profile"`

2. Логинится вручную в нужные сайты (вузовские базы за подпиской, кабинеты, соцсети)
   прямо в этом окне. Логины оседают в `~/.chrome-beta-profile` и живут между
   запусками.

Кроссплатформенно (Win/Mac/Linux); официального arm64-пакета Chrome Beta под Linux
Google не публикует — только amd64.

## Что скилл проверяет перед работой

**Живость CDP-порта:**
```bash
curl -s http://localhost:9222/json/version
```
Ответ с полями браузера → порт слушает, можно прицепляться. (Windows: `curl.exe`
или `Invoke-RestMethod http://localhost:9222/json/version`.)

**Attach и готовность связки:**
```bash
timeout 15 agent-browser --cdp 9222 snapshot -i
```
Вернулось дерево с рефами `@eN` → агент в авторизованной вкладке.

## Инвариант attach

- `--cdp 9222` на **каждой** команде — это attach к запущенному Chrome Beta.
  Альтернатива — `agent-browser connect 9222` разово, но `--cdp` на каждой команде
  надёжнее и не зависит от состояния демона.
- Без `--cdp` команда поднимает **отдельный детектируемый Chromium без логинов** —
  не нашу сессию. Это самый частый скрытый провал.
- `--session <name> connect 9222` — баг: `connect` под `--session` создаёт пустую
  вкладку `about:blank` вместо attach к существующим (проверено v0.22.3, поведение
  то же в v0.26). Не использовать.
- Многовкладочность в одном логине — через `tab` (общие cookie), НЕ через
  `--session` (в v0.26 это отдельный изолированный браузер со своими cookie).

Хранение сессии между прогонами есть и другими путями (`--state <file>`,
`--session-name`, auth-vault `auth save/login`), но для нашего субстрата это не
нужно: persistent-логины держит сам профиль `--user-data-dir`, а вход делает
человек.

## Честная граница антибота

Реальный профиль Chrome Beta снимает часть identity-сигналов автоматизации (это и
есть смысл attach к настоящему браузеру вместо managed-Chromium). Но CDP оставляет
**detectable-следы**: включённый `Runtime.enable`, артефакты `cdc_` и прочее видят
Cloudflare, DataDome и подобные. Проверить отсутствие грубого флага можно:
```bash
agent-browser --cdp 9222 eval 'navigator.webdriver'   # ожидаемо false/undefined
```
но это не делает сессию невидимой для серьёзного антибота.

**Правило:** не патчить и не пытаться обходить. Упёрлись в антибот или CAPTCHA —
**стоп, отдать человеку** (проходит проверку руками в том же окне, затем даёт
продолжить). Обход детекта в задачи скилла не входит.
