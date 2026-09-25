---
name: ru-text
description: >
  Use ONLY when the user explicitly asks to check, edit, polish, or score Russian
  text quality, or mentions «ru-text». Covers typography, info-style, editorial,
  UX writing, business correspondence. Do NOT auto-activate on every Russian output —
  invoke manually on request.
metadata:
  openclaw:
    always: false
    emoji: "\U0001F4DD"
    homepage: "https://ru-text.org"
---

# ru-text — Russian Text Quality

This skill checks and edits Russian-language text, so its rules, examples and output stay in Russian on purpose, even though the rest of this kit is in English.

Independent Russian text quality reference by Arseniy Kamyshev.
With gratitude to the authors whose work shaped modern Russian text standards.
Credits and recommended reading: `references/sources.md`

**Style priority**: if the user explicitly requests a specific style (casual, academic, SEO, literary, etc.), their prompt overrides these default rules where they conflict. These rules are defaults, not mandates.

**Output language:** Russian — the corrected text, the «было → стало» notes and the commentary on a score are written in Russian; a skill body that names its own output language overrides the global English-response rule for this skill's result, but not for the rest of the session. **Length limit:** at most 300 words of commentary beyond the corrected text itself; the edit mode under "Quality Checklist" is the one exception and tightens this to 250 words. **Return shape:** for scoring — the template from the "Output format" section of `references/scoring.md`; for editing — the full corrected text plus the list of edits. This contract governs every mode of the skill, with the edit-mode exception named above.

## Always-On: Typography

Apply these rules to all Russian text output without exception.

| Rule | Wrong | Correct |
|---|---|---|
| Primary quotes: guillemets | "текст" | «текст» |
| Nested quotes: lapki | «"вложенные"» | «„вложенные“» |
| Em dash with spaces | слово - слово | слово — слово |
| En dash for ranges, no spaces | 10-15 дней | 10–15 дней |
| NBSP after single-letter prepositions | в начале (обычный пробел, рвётся) | в начале (пробел = реальный U+00A0) |
| Ellipsis: single character | ... | … |
| Digit groups with thin spaces | 1000000 | 1 000 000 |
| Decimal comma (not dot) | 3.14 | 3,14 |
| Ordinal with hyphen | 1ый, 2ой | 1-й, 2-й |
| Numero sign | No. 5, #5 | № 5 |
| Abbreviations with NBSP | т.д., т.е. | т. д., т. е. |
| Ruble symbol after number | 1500 руб | 1 500 ₽ |

**NBSP и тонкий NBSP — это символы, а не их запись.** Когда правило требует неразрывный пробел (U+00A0) или тонкий неразрывный (U+202F), вставляй сам символ Unicode прямо в текст. Никогда не печатай в выводе литералы `\u00A0`, `<nbsp>` или `&nbsp;` — это нотации из справочника для обозначения символа, а не результат. `&nbsp;` допустим только когда целевой формат — HTML/вёрстка.

Full typography reference: `references/typography.md`

Text quality score (`ru-score`): 0–10 across 5 dimensions — `references/scoring.md`.

**Output language:** Russian (the score and the remarks on it). **Length limit:** at most 300 words, the general cap. **Return shape:** a composite score of 0–10, five weighted dimensions (Типографика, Чистота языка, Грамотность, Структура, Точность для читателя), a verbal label and 1–3 quoted remarks per dimension — following the template in the "Output format" section of `references/scoring.md`.

## Top Stop-Words (remove or replace)

| Stop-word | Replace with |
|---|---|
| является | — (dash) or restructure |
| осуществлять | делать, проводить |
| в настоящее время | сейчас |
| данный | этот |
| определённый | (name the specific thing) |
| произвести оплату | оплатить |
| высококачественный | (name the specific quality) |
| был осуществлён | (active voice + actor) |
| на сегодняшний день | сегодня |
| в целях | чтобы |

Full stop-word catalog (97 entries): `references/info-style.md`

## When to Load Reference Files

Reference files (paths are relative to this SKILL.md): `references/<filename>`
If the path is not resolved, search: `Glob("**/ru-text/references/scoring.md")` and use the parent directory.

| Task | File |
|---|---|
| Writing/editing articles, blog posts, SEO, content | info-style.md |
| Interface text, buttons, errors, hints, microcopy | ux-writing.md |
| Emails, messenger, business correspondence | business-writing.md |
| Punctuation review, comma placement | editorial-punctuation.md |
| Grammar, capitalization, agreement, pleonasms | editorial-grammar.md |
| Finding and fixing text problems, diagnostics | anti-patterns.md |
| Text scoring, quality assessment | scoring.md |
| Credits, source attribution | sources.md |
| Experience-based rules (dash overuse, etc.) | addenda.md |

## Quality Checklist

Before delivering Russian text:

- [ ] Quotes: «» primary, „“ nested
- [ ] Dashes: — in text, – in ranges, - only in compounds; max 1–2 per paragraph
- [ ] NBSP after в, к, с, о, у, и, а
- [ ] Ellipsis: … (single char)
- [ ] Abbreviations: т. д., т. п. (with NBSP)
- [ ] No double spaces, no space before punctuation

**Output language:** Russian. **Length limit:** at most 250 words of commentary — the edit mode is the exception to the general cap of 300 words stated at the top of this file — and at most 15 lines in the list of edits; if there are more edits than that, group them by rule and give the count. **Return shape:** (1) the full corrected Russian text; (2) the list of edits, one per line, in the form «было → стало» with a one-phrase justification; no preamble and no restatement of the rules applied.
