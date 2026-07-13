# BibTeX: типы записей, поля и примеры

Справочник к навыку `cite`. Слева — обязательные поля (без них запись некорректна),
справа — полезные опциональные. Ниже — развёрнутые примеры в BibTeX, APA 7 и ГОСТ.

## Типы записей и поля

| Тип | Что это | Обязательные | Частые опциональные |
|---|---|---|---|
| `@article` | Статья в журнале | author, title, journal, year | volume, number, pages, doi, month, note |
| `@inproceedings` | Доклад в сборнике конференции | author, title, booktitle, year | editor, pages, publisher, organization, address, doi |
| `@book` | Книга целиком | author **или** editor, title, publisher, year | volume/number, series, address, edition, isbn |
| `@incollection` | Глава в сборнике/книге | author, title, booktitle, publisher, year | editor, pages, series, address, doi |
| `@misc` | Препринт, веб-ресурс, датасет, ПО | (нет строго обязательных) | author, title, year, howpublished, url, urldate, eprint, archivePrefix, doi, note |
| `@techreport` | Технический отчёт | author, title, institution, year | number, address, type, url |
| `@phdthesis` / `@mastersthesis` | Диссертация / магистерская | author, title, school, year | address, type, url |
| `@online` (biblatex) | Онлайн-ресурс | author/title, year/date, url | urldate, note |

Замечания:
- В `@misc` формально обязательных полей нет, но осмысленная запись требует хотя бы
  author (или organization), title, year и url/eprint.
- Препринт arXiv: `@misc` с полями `eprint = {2401.01234}`,
  `archivePrefix = {arXiv}`, `primaryClass = {cs.CL}`.
- Имена: `author = {Фамилия, Имя and Фамилия, Имя}`. Порядок — как в источнике.
- Кириллица: оборачивай в `{}` слова, где важен регистр, чтобы стиль его не «съел».
- `doi`: только код, `10.1234/abcd`, без префикса `https://doi.org/`.

## Пример 1 — статья в журнале

**BibTeX:**
```bibtex
@article{ivanova2023method,
  author  = {Ivanova, Anna and Petrov, Sergei},
  title   = {A comparative study of retrieval methods},
  journal = {Journal of Information Science},
  year    = {2023},
  volume  = {49},
  number  = {3},
  pages   = {412--430},
  doi     = {10.1177/01655515211012345}
}
```

**APA 7:**
Ivanova, A., & Petrov, S. (2023). A comparative study of retrieval methods.
*Journal of Information Science, 49*(3), 412–430.
https://doi.org/10.1177/01655515211012345

**ГОСТ Р 7.0.100–2018:**
Ivanova, A. A comparative study of retrieval methods / A. Ivanova, S. Petrov //
Journal of Information Science. — 2023. — Vol. 49, no. 3. — P. 412–430.

## Пример 2 — доклад на конференции

**BibTeX:**
```bibtex
@inproceedings{smith2024prompting,
  author    = {Smith, John and Lee, Mei},
  title     = {Prompting strategies for long-context models},
  booktitle = {Proceedings of the 2024 Conference on Empirical Methods},
  year      = {2024},
  pages     = {1123--1138},
  publisher = {Association for Computational Linguistics},
  doi       = {10.18653/v1/2024.emnlp-main.88}
}
```

**APA 7:**
Smith, J., & Lee, M. (2024). Prompting strategies for long-context models. В
*Proceedings of the 2024 Conference on Empirical Methods* (сс. 1123–1138).
Association for Computational Linguistics. https://doi.org/10.18653/v1/2024.emnlp-main.88

**ГОСТ:**
Smith, J. Prompting strategies for long-context models / J. Smith, M. Lee //
Proceedings of the 2024 Conference on Empirical Methods. — [S. l.] : Association for
Computational Linguistics, 2024. — P. 1123–1138.

## Пример 3 — книга

**BibTeX:**
```bibtex
@book{kahneman2011thinking,
  author    = {Kahneman, Daniel},
  title     = {Thinking, Fast and Slow},
  publisher = {Farrar, Straus and Giroux},
  year      = {2011},
  address   = {New York},
  isbn      = {9780374275631}
}
```

**APA 7:**
Kahneman, D. (2011). *Thinking, fast and slow*. Farrar, Straus and Giroux.

**ГОСТ:**
Kahneman, D. Thinking, Fast and Slow / D. Kahneman. — New York : Farrar, Straus and
Giroux, 2011. — 499 p.

## Пример 4 — глава в сборнике

**BibTeX:**
```bibtex
@incollection{orlov2022ethics,
  author    = {Orlov, Dmitry},
  title     = {Этика автономных агентов},
  booktitle = {Философия искусственного интеллекта},
  editor    = {Соколова, Мария},
  publisher = {Наука},
  address   = {Москва},
  year      = {2022},
  pages     = {77--104}
}
```

**ГОСТ:**
Орлов, Д. Этика автономных агентов / Д. Орлов // Философия искусственного
интеллекта / под ред. М. Соколовой. — Москва : Наука, 2022. — С. 77–104.

## Пример 5 — препринт arXiv (@misc)

**BibTeX:**
```bibtex
@misc{chen2024agents,
  author        = {Chen, Wei and Garcia, Luis},
  title         = {Self-verifying agents for long-horizon tasks},
  year          = {2024},
  eprint        = {2403.04567},
  archivePrefix = {arXiv},
  primaryClass  = {cs.AI},
  url           = {https://arxiv.org/abs/2403.04567}
}
```

**APA 7:**
Chen, W., & Garcia, L. (2024). *Self-verifying agents for long-horizon tasks*.
arXiv. https://arxiv.org/abs/2403.04567

## Пример 6 — веб-ресурс (@misc с датой обращения)

**BibTeX:**
```bibtex
@misc{who2023ai,
  author       = {{World Health Organization}},
  title        = {Ethics and governance of artificial intelligence for health},
  year         = {2023},
  howpublished = {\url{https://www.who.int/publications/...}},
  urldate      = {2026-07-13}
}
```

**ГОСТ (электронный ресурс):**
Ethics and governance of artificial intelligence for health [Электронный ресурс] /
World Health Organization. — 2023. — URL: https://www.who.int/publications/...
(дата обращения: 13.07.2026).

## Мини-памятка по различиям стилей

- **APA 7** — автор-год, инициалы, курсив у названия журнала/книги, DOI как полный
  URL `https://doi.org/…`. Sentence case у названия статьи.
- **ГОСТ Р 7.0.100–2018** — области через ` . — `, ответственность через `/`,
  редакторы через `/ под ред.`, страницы `С.`/`P.`, для онлайна — `[Электронный
  ресурс]` и `(дата обращения: …)`.
- **BibTeX** — ты описываешь поля, а стиль (`.bst` / biblatex-стиль) сам решает, как
  их отрисовать. Поэтому важнее всего заполнить поля полно и честно.
