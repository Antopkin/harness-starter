# agent-browser — примитивы для заполнения формы (заземлено по справке CLI)

Источник истины — установленный CLI, **v0.26.0**. Синтаксис ниже выписан из
`agent-browser --help` и справок подкоманд (`agent-browser <cmd> --help`). Если
твоя версия отвечает иначе — доверяй справке своей версии и
`agent-browser skills get core --full`, а не этому файлу.

**Инвариант:** `--cdp 9222` на КАЖДОЙ команде (attach к запущенному Chrome Beta) и
hard-timeout вокруг каждого вызова:

```bash
timeout 15 agent-browser --cdp 9222 snapshot -i
```

## Расхождение со старым хендофом (важно)

Ранний хендоф утверждал, что команд `get value`, `wait` и `type` в CLI НЕТ и что
их нельзя использовать. **По справке v0.26.0 все три существуют.** Ground truth —
справка CLI, поэтому этот скилл ими пользуется. Ниже — реальный синтаксис. Ложные
запреты сняты; сохранена лишь содержательная осторожность вокруг read-back (см.
`get value` ниже и `failure-modes.md`).

## Обнаружение полей

| Задача | Команда | Заметка |
|---|---|---|
| A11y-дерево с рефами `@eN` | `snapshot -i` | `-i` — только интерактивные; у поля видны роль и accessible-name |
| То же, компактно / по глубине | `snapshot -i -c`, `snapshot -i -d <n>` | убрать пустые узлы / ограничить глубину |
| Снимок части страницы | `snapshot -i -s "<css>"` | скоуп по CSS, если форма — фрагмент |
| Скриншот (для human-gate) | `screenshot [path]`; `screenshot --annotate` | `--annotate` рисует метки `[N]` = рефы `@eN` |

Рефы `@eN` из snapshot действительны, **пока страница не менялась**. Любой ввод,
клик, переход, смена вкладки → рефы протухли → сделай `snapshot -i` заново перед
следующим шагом.

Iframe (частый случай — встроенная Google Form, платёжная рамка) **авто-инлайнится**
в snapshot: рефы полей внутри работают прозрачно. Глубокая вложенность или фокус —
`frame @eN` переключает контекст, `frame main` возвращает. Cross-origin iframe,
закрытый для a11y-дерева, молча пропускается — тогда `eval` в его origin или стоп.

## Сопоставление по роли и accessible-name (не по CSS)

`find` находит и сразу действует по семантическому локатору — это и есть
маппинг по роли+имени нативно, без CSS-селекторов:

```bash
agent-browser --cdp 9222 find label "E-mail" fill "user@example.com"    # текст по подписи — надёжно
agent-browser --cdp 9222 fill @e5 "user@example.com"                    # текст по рефу из snapshot
agent-browser --cdp 9222 find role button click --name "Отправить"      # кнопка по тексту — надёжно
```

- Локаторы: `label`, `role <role>` (+ `--name <accessible-name>`, `--exact`),
  `placeholder`, `alt`, `title`, `testid`, `first/last/nth`.
- Действия: `click` (по умолчанию), `fill`, `type`, `hover`, `focus`, `check`,
  `uncheck`. Действия `select` у `find` НЕТ — выпадающий список только командой
  `select <sel> "<value>"`.
- Преимущество `find` над `@eN`: он пере-резолвит элемент на каждом вызове,
  поэтому устойчивее к протуханию рефов. `@eN` быстрее при цепочке действий по
  одному снимку, но требует re-snapshot после каждого изменения.

> **Эмпирика (проверено на v0.26.0 + Chrome 151, живой браузер).** Для текстовых
> полей веди по `find label "<подпись>"` или по рефу `@eN` из snapshot — оба
> надёжны. `find role textbox --name "<имя>"` на практике НЕ находит input'ы, чей
> accessible-name задан через `<label>`/`aria-label` (отдаёт «Element not found»),
> хотя в snapshot они видны как `textbox "<имя>"`. Для кнопок `find role button
> --name "<текст>"` работает (name из текста). Флажок — `find label "<имя>" check`
> или `check @eN`. Выпадающий список — командой `select <sel> "<value>"`.

Роли, которые встречаются в формах: `textbox`, `checkbox`, `radio`, `combobox`,
`listbox`, `button`, `spinbutton` (числовой input), `searchbox`.

## Ввод значений

| Тип поля | Команда | Когда |
|---|---|---|
| Текст (очистить и вписать) | `fill <sel> "<текст>"` | основной путь для input/textarea; **очищает** поле перед вводом |
| Текст реальными нажатиями | `type <sel> "<текст>"` | печатает БЕЗ очистки (дописывает); autocomplete/маска/подсказки, где нужен посимвольный ввод |
| По фокусу, реальные keystroke | `focus <sel>` + `keyboard type "<текст>"` | когда компонент перехватывает события — реальные нажатия клавиш |
| По фокусу, без key-событий | `focus <sel>` + `keyboard inserttext "<текст>"` | вставка текста в обход key-событий |
| Флажок | `check <sel>` / `uncheck <sel>` | идемпотентны: если уже в нужном состоянии — no-op |
| Выпадающий список | `select <sel> "<value>" [<value>...]` | по value опции `<option>` |
| Загрузка файла | `upload <sel> <file> [<file>...]` | file-input |
| Нажать клавишу | `press <key>` | напр. `Enter`, `Tab`, `Control+a` |

`<sel>` — CSS-селектор, XPath или реф `@eN`. Лестница для React-полей, куда
`fill` не «встаёт»: `fill` → `type` → `eval` с dispatchEvent (`failure-modes.md`).

## Read-back verify (перечитать значение)

| Задача | Команда | Граница |
|---|---|---|
| Значение нативного поля | `get value <sel>` | живое DOM-значение input/textarea/select; **основной read-back** |
| Атрибут / состояние | `get attr <sel> <name>` | напр. `aria-checked`, `checked` |
| Состояние флажка | `is checked <sel>` | true/false |
| Текст элемента | `get text <sel>` | для не-input (метки, contenteditable рядом) |
| Кастом/React, где `.value` лжёт | `eval '<js>'` | **обязательный fallback**: `eval "document.querySelector('...')?.value"` или `.textContent` |
| Что изменилось после ввода | `diff snapshot` | сравнивает текущий снимок с предыдущим — видно, встало ли значение и не поехала ли остальная форма |

Почему одного `get value` (или одного re-snapshot) мало на кастомных полях:
`get value` читает DOM-свойство `.value`. Для нативного input это истина. Но у
React-контролируемого или contenteditable-виджета `.value` может быть пустым или
рассинхронизированным с тем, что реально уйдёт на submit, а re-snapshot покажет
только accessible-name. Поэтому для кастомных полей read-back обязан идти через
`eval` по конкретному свойству/состоянию виджета. Опора на ЕДИНСТВЕННЫЙ слабый
read = ложно-зелёный.

`eval` умеет читать stdin и base64 — удобно для многострочного JS без экранирования:

```bash
echo "document.querySelector('#bio')?.value" | agent-browser --cdp 9222 eval --stdin
```

## Ожидание (wait существует — цикл на snapshot не нужен)

```bash
timeout 20 agent-browser --cdp 9222 wait "@e5"                 # появления элемента
timeout 20 agent-browser --cdp 9222 wait --text "Спасибо"      # текста на странице (подстрока)
timeout 20 agent-browser --cdp 9222 wait --load networkidle    # затихания сети
timeout 20 agent-browser --cdp 9222 wait --url "**/success"    # смены URL по шаблону
timeout 5  agent-browser --cdp 9222 wait 2000                  # фиксированная пауза, мс
```

Оборачивай `wait` в shell-`timeout` как жёсткий потолок: `wait` ждёт условие,
`timeout` не даёт зависнуть навсегда. Запасной путь, если `wait` на селекторе
капризничает: короткий цикл повторных `snapshot -i` с проверкой появления
элемента.

## Навигация, вкладки, состояние

| Задача | Команда |
|---|---|
| Открыть URL | `open <url>` (алиасы `goto`, `navigate`) |
| Текущий URL / заголовок | `get url` / `get title` |
| Перезагрузка / назад / вперёд | `reload` / `back` / `forward` |
| Вкладки (общий логин) | `tab new --label <ярлык> <url>`, `tab <ярлык>`, `tab list`, `tab close <id>` |
| Консоль / ошибки страницы | `console`, `errors` |

Многовкладочность в одном Chrome — через `tab` (общие cookie/логин), НЕ через
`--session` (в v0.26 это отдельный изолированный браузер). Активная вкладка одна;
рефы принадлежат вкладке, снятой на момент snapshot — после `tab <...>` делай
`snapshot -i` заново.

## Чего действительно избегать

- `--session <name> connect 9222` — баг: `connect` создаёт пустую вкладку
  `about:blank` вместо attach к существующим (проверено на v0.22.3, поведение то
  же в v0.26). Коннект — только `--cdp 9222` на каждой команде.
- Голый `open <url>` без `--cdp` — поднимает отдельный детектируемый Chromium без
  логинов.
