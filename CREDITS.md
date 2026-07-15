# CREDITS — атрибуция и лицензии

Репозиторий собран из оригинальных материалов и нескольких сторонних навыков.
Оригинальные части покрыты лицензией MIT (см. `LICENSE`). Сторонние навыки сохраняют
собственные лицензии и авторство: их LICENSE-файлы и упоминания авторов лежат внутри
навыков как есть — не удаляй их и при копировании навыков в `.claude/skills/` /
`.agents/skills/` переноси вместе с ними.

## Сторонние навыки

### `skills/skill-creator` — Anthropic (Apache-2.0)

Навык создания, улучшения и оценки навыков из открытой коллекции навыков Anthropic.
Распространяется под Apache License 2.0 — полный текст лицензии сохранён в составе
навыка: `skills/skill-creator/LICENSE.txt`.

### `skills/ru-text` — Арсений Камышев

«Independent Russian text quality reference by Arseniy Kamyshev»
(`skills/ru-text/SKILL.md`, homepage: <https://ru-text.org>). Формулировки в навыке —
авторские; список работ-вдохновителей с благодарностями (А. Горбунов, М. Ильяхов,
А. Э. Мильчин и Л. К. Чельцова, И. Бирман, Нора Галь, Д. Э. Розенталь и другие)
сохранён как есть в `skills/ru-text/references/sources.md`. Перечисленные там авторы
и издатели навык не рецензировали и не одобряли — ссылки даны как атрибуция
вдохновения и рекомендация к чтению.

### `tracks/academic/skills/` — академическое семейство, Cheng-I Wu

Навыки `academic-paper`, `academic-paper-reviewer`, `deep-research`, `paper-audit`,
`academic-pipeline` — единое семейство академических навыков (написание статьи,
симуляция рецензирования, глубокое исследование, аудит целостности, оркестрация
конвейера); навыки перекрёстно ссылаются друг на друга как один конвейер. Мейнтейнер
указан в метаданных самих навыков: **Cheng-I Wu** (`tracks/academic/skills/academic-paper-reviewer/SKILL.md`
и `tracks/academic/skills/academic-pipeline/SKILL.md`, раздел Version Info — совпадают
дата обновления, формат таблицы и состав зависимостей).
Отдельного файла лицензии в составе этих навыков нет; они включены с указанием
авторства, версии и changelog'и авторов сохранены внутри `SKILL.md` как есть.

### `tracks/academic/skills/latex-proofread` — LimHyungTae/awesome-claudecode-paper-proofreading

Основан на открытом репозитории **LimHyungTae/awesome-claudecode-paper-proofreading**
(источник указан в `SKILL.md`, поле `metadata.source`, и в описании навыка).
Отдельного файла лицензии в составе навыка нет; атрибуция и версия сохранены внутри
`SKILL.md` как есть. Лицензия/авторство — по исходному репозиторию.

## Оригинальные части (MIT, © 2026 Oleg Antopkin)

- Свод правил `AGENTS.md` и аддендум `tracks/academic/AGENTS.academic.md`.
- `README.md`, `INSTALL.md`, `hello.md`, `runbooks.md`, `memory/`,
  README и runbooks академического трека.
- Базовые навыки: `explain`, `review`, `test`, `tdd`, `diagnose`, `writing-guru`,
  `style-extract`, `lit-search`, `pdf-digest`, `cite`, `handoff`.
- Навыки трека: `transcript-verbatim`, `transcript-polish` и общий файл
  `skills/shared/transcript-io.md`.
- Конфигурация MCP: `tracks/academic/mcp/README.md` и `.mcp.json.example`
  (только плейсхолдеры, без ключей).

## Внешние зависимости (в репозиторий не входят)

Академический трек подключает два открытых MCP-сервера — Python-пакеты
`paper-search-mcp` и `zotero-mcp`. Они не распространяются с этим репозиторием:
пользователь ставит их сам через `uvx`/`pip`, здесь лежит только шаблон конфига
с плейсхолдерами. У пакетов свои авторы и лицензии — смотри страницы самих пакетов.

## Правило при доработке

Добавляешь сторонний навык — сохрани его LICENSE и авторские упоминания внутри
каталога навыка и впиши источник и лицензию сюда.
