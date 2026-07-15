---
name: latex-proofread
description: "Двухфазный пруфридинг LaTeX-статей. Фаза 1: аудит инфраструктуры (preamble, макросы, cross-ref, цитаты, фигуры). Фаза 2: ревью контента (грамматика, научная ясность, нарратив, нотация). Основано на LimHyungTae/awesome-claudecode-paper-proofreading."
metadata:
  version: "1.0"
  last_updated: "2026-03-14"
  source: "https://github.com/LimHyungTae/awesome-claudecode-paper-proofreading"
---

# LaTeX Paper Proofreading — Двухфазный аудит

Строгий двухфазный пруфридинг LaTeX-статей уровня ICRA, RSS, NeurIPS, T-RO, CVPR.

## Быстрый старт

```
/latex-proofread main.tex
/latex-proofread main.tex --phase 1     # только инфраструктура
/latex-proofread main.tex --phase 2     # только контент
```

## Триггеры

Используй этот скилл когда пользователь хочет:
- проверить LaTeX-статью перед подачей
- найти ошибки в preamble, макросах, цитатах
- вычитать текст на грамматику, ясность, нотацию
- проверить workspace на скрытые ошибки (TODO, плейсхолдеры)

Ключевые слова: proofread, вычитка, проверить статью, latex proofread, check paper, ревью tex

## НЕ триггерить

| Сценарий | Используй |
|---|---|
| Исправить ошибки компиляции по .log | `/latex-fix` |
| Написать статью | `/academic-paper` |
| Рецензия на статью (академическая) | `/academic-paper-reviewer` |
| Аудит качества (scoring) | `/paper-audit` |

---

## Рабочий процесс

### Подготовка (перед обеими фазами)

1. Прочитай корневой `.tex` файл
2. Найди все `\input{...}` и `\include{...}` рекурсивно
3. Прочитай все подключённые файлы (`sections/*.tex`, `shortcuts.tex`, `preamble.tex`, и т.д.)
4. Прочитай все `.bib` файлы из `\bibliography{...}`
5. Делай это молча, до любого вывода

### Фаза 1 — Аудит инфраструктуры LaTeX workspace

> **НЕ модифицируй файлы во время Фазы 1. Только детектируй и репортируй.**

#### Проверки (C1-C9)

| # | Проверка | Описание |
|---|---|---|
| C1 | Preamble | Дубли/конфликты/неиспользуемые/отсутствующие пакеты. cleveref, hyperref, caption, math packages |
| C2 | Порядок пакетов | hyperref → cleveref, amsmath → mathtools, xcolor → tikz, caption → subcaption |
| C3 | Макросы | \methodname без \xspace, дубли, конфликты имён, \etalcite, subscript consistency |
| C4 | Cross-references | Смешанные \Cref/\cref/\ref, ручные "Fig.", множественные ссылки |
| C5 | Именование меток | Префиксы fig:/tab:/eq:/sec:/alg:, дубли, неиспользуемые, сломанные |
| C6 | Цитаты и библиография | \cite без записи в .bib, дубли ключей, качество BibTeX, ~\cite{} |
| C7 | Фигуры и таблицы | Отсутствующие файлы, плейсхолдеры, абсолютные пути, позиция \label |
| C8 | Скрытые ошибки | TODO/XXX/FIXME, несогласованные названия, шаблонный контент, \vspace хаки |
| C9 | Академическое письмо | Единицы (\,), тысячные разделители, et al., \ie/\eg, state-of-the-art, акронимы |

#### Формат вывода Фазы 1

```
**`файл.tex`**
[N]  L.XX   Описание проблемы | Предложение

CRITICAL
  [N]  Файл — краткое описание
MAJOR
  [N]  Файл — краткое описание
MINOR / STYLE
  [N]  Файл — краткое описание

Infrastructure Suggestions:
- ...
```

### Фаза 2 — Ревью контента

> **НЕ переписывай текст. Только детектируй и репортируй.**

Персона: строгий рецензент уровня ICRA, RSS, NeurIPS, T-RO, CVPR.

#### Категории (A-I)

| # | Категория | Описание |
|---|---|---|
| A | Язык и грамматика | Subject-verb agreement, tense consistency, passive voice, Oxford comma |
| B | Качество языка | Опечатки (CRITICAL), номинализация, filler expressions, citation-as-noun |
| C | Научная ясность | Overclaiming, causal gaps, unsupported limitations, undefined symbols |
| D | Структура и поток | Introduction, Related Work, Methodology, Experiments — полная проверка |
| E | Фигуры, таблицы, подписи | Self-containedness подписей, bold/underline convention, reference order |
| F | LaTeX-форматирование | Thin spaces, thousands separators, consistent references, \ie/\eg macros |
| G | Abstract и Conclusion | WHY→PROBLEM→HOW→RESULTS, no citations in abstract, single paragraph |
| H | Консистентность нотации | Symbol overload, boldface vectors, coordinate frame notation |
| I | Дефисы | Compound adjectives, -ly adverb rule, context-dependent checks |

#### Формат вывода Фазы 2

```
Paper quality: GOOD / NEEDS REVISION / MAJOR REVISION

| Type     | Count |
|----------|-------|
| CRITICAL |       |
| MAJOR    |       |
| MINOR    |       |
| STYLE    |       |

[Полный список по файлам]
[Группировка по severity]
[Caption Review]
[LaTeX Formatting Patterns]
[Optional Polishing Suggestions]
```

---

## Фаза Fix — после обеих фаз

После вывода всех проблем, жди решения пользователя:

- `fix safe` — только однозначные опечатки и грамматические ошибки
- `fix all critical` — только CRITICAL
- `fix all` — все предложенные исправления
- `fix [номера]` — конкретные проблемы (например `fix 1, 3, 5`)
- `discard [номера]` — пропустить конкретные

**НЕ модифицируй файлы до подтверждения пользователем.**

### Правила исправления

- **Без em dashes** (`—`) — заменяй на запятую, точку с запятой, двоеточие или перестраивай предложение
- Не добавляй AI-характерные конструкции

---

## Severity Levels

| Уровень | Значение |
|---------|---------|
| CRITICAL | Исправить до подачи |
| MAJOR | Важная проблема ясности/корректности |
| MINOR | Грамматика или формулировка |
| STYLE | Опциональное улучшение |

---

## Язык вывода

Следует языку пользователя. Академическая терминология на английском.
