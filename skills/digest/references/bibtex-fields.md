# BibTeX: entry types, fields and examples

The single reference on formatting citations for the `digest` skill. On the left are
the required fields (without them an entry is invalid), on the right the useful
optional ones. Below are worked examples in BibTeX, APA 7 (the default style) and
GOST R 7.0.100-2018 (an option for Russian-language reference lists).

## Entry types and fields

| Type | What it is | Required | Common optional |
|---|---|---|---|
| `@article` | Journal article | author, title, journal, year | volume, number, pages, doi, month, note |
| `@inproceedings` | Paper in conference proceedings | author, title, booktitle, year | editor, pages, publisher, organization, address, doi |
| `@book` | Whole book | author **or** editor, title, publisher, year | volume/number, series, address, edition, isbn |
| `@incollection` | Chapter in an edited volume/book | author, title, booktitle, publisher, year | editor, pages, series, address, doi |
| `@misc` | Preprint, web resource, dataset, software | (none strictly required) | author, title, year, howpublished, url, urldate, eprint, archivePrefix, doi, note |
| `@techreport` | Technical report | author, title, institution, year | number, address, type, url |
| `@phdthesis` / `@mastersthesis` | PhD / master's thesis | author, title, school, year | address, type, url |
| `@online` (biblatex) | Online resource | author/title, year/date, url | urldate, note |

Notes:
- `@misc` formally has no required fields, but a meaningful entry needs at least
  author (or organization), title, year and url/eprint.
- arXiv preprint: `@misc` with the fields `eprint = {2401.01234}`,
  `archivePrefix = {arXiv}`, `primaryClass = {cs.CL}`.
- Names: `author = {Surname, Name and Surname, Name}`. Order as in the source.
- Cyrillic and other case-sensitive text: wrap words whose case matters in `{}` so the
  style does not "eat" it.
- `doi`: the code only, `10.1234/abcd`, without the `https://doi.org/` prefix.

## Example 1: journal article

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

**GOST R 7.0.100-2018:**
Ivanova, A. A comparative study of retrieval methods / A. Ivanova, S. Petrov //
Journal of Information Science. — 2023. — Vol. 49, no. 3. — P. 412–430.

## Example 2: conference paper

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
Smith, J., & Lee, M. (2024). Prompting strategies for long-context models. In
*Proceedings of the 2024 Conference on Empirical Methods* (pp. 1123–1138).
Association for Computational Linguistics. https://doi.org/10.18653/v1/2024.emnlp-main.88

**GOST:**
Smith, J. Prompting strategies for long-context models / J. Smith, M. Lee //
Proceedings of the 2024 Conference on Empirical Methods. — [S. l.] : Association for
Computational Linguistics, 2024. — P. 1123–1138.

## Example 3: book

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

**GOST:**
Kahneman, D. Thinking, Fast and Slow / D. Kahneman. — New York : Farrar, Straus and
Giroux, 2011. — 499 p.

## Example 4: chapter in an edited volume (a Russian-language source)

**BibTeX:**
```bibtex
@incollection{orlov2022ethics,
  author    = {Orlov, Dmitry},
  title     = {Этика ИИ},
  booktitle = {Философия ИИ},
  publisher = {Наука},
  address   = {Москва},
  year      = {2022},
  pages     = {77--104}
}
```

**GOST:**
Орлов, Д. Этика ИИ / Д. Орлов // Философия ИИ. — Москва : Наука, 2022. —
С. 77–104.

## Example 5: arXiv preprint (@misc)

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

## Example 6: web resource (@misc with an access date)

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

**GOST (electronic resource):**
Ethics and governance of artificial intelligence for health [Электронный ресурс] /
World Health Organization. — 2023. — URL: https://www.who.int/publications/...
(дата обращения: 13.07.2026).

## A short cheat sheet on how the styles differ

- **APA 7** (the default): author-date, initials, the journal or book title in
  italics, the DOI as a full URL `https://doi.org/…`. Sentence case for the article
  title.
- **GOST R 7.0.100-2018** (for Russian-language reference lists): areas separated by
  ` . — `, responsibility after `/`, editors after a second `/` with the Russian
  abbreviation for "edited by", pages as `P.` (or the Russian page mark for a Russian
  source, as in Example 4); for online sources, the electronic-resource mark and the
  access date shown in Example 6.
- **BibTeX**: you describe the fields, and the style (`.bst` or a biblatex style)
  decides how to render them. So what matters most is filling the fields completely
  and honestly.
