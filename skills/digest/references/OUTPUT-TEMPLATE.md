# Target output shape: digest

This is a **template**, not an example. Placeholders in angle or square brackets
(`<claim>`, `<locator>`, `<verbatim quote>`) show the **shape** and must be replaced
with real content from the source. Do not fill the template with invented text: that
directly contradicts the skill's anti-hallucination rules. Checked worked examples sit
next to this file: a PDF example on a real paper in `EXAMPLE-digest-pdf.md`, and docx
and md examples in `EXAMPLE-digest-docx.md` and `EXAMPLE-digest-md.md`.

The shape is the same for every format (PDF, docx, md, txt); only what goes into the
"Locator" column changes (page · section and paragraph · line; see the anchor table in
`SKILL.md`).

Mandatory parts: the checked anchor table (every ⚠ resolved) and the final reference
sections (`## Reference-list entry` with APA 7, plus GOST on request, and
`## Citation (.bib)`). Without them the digest is not finished.

---

```
# Digest: <Authors, Year — Short title>

**Biblio:** <Authors> (<Year>). <Title>. <Journal/conference/preprint>. <DOI/URL>.
**Read:** <locator range — pages or sections>
**Format:** <PDF / docx / md / txt>  ·  **Extraction trust:** <digital-born |
scan/OCR | fallback: skill N unavailable>  ·  **Date:** <YYYY-MM-DD>

## The gist in one line
<What the work is about and its main finding, in one sentence of your own.>

## Problem and gap
<Which problem is addressed; what was wrong or missing before> (<locator>).

## Method
<What exactly was done: approach, model, study design, procedure> (<locator>).

## Data / material
<Sample, dataset, sources, size; how it was collected> (<locator>).
<If the paper does not say — "not stated", not a guess.>

## Results
<Main results with specific numbers and locators. Only what is in the text.>
- <result 1 with a number> (<locator>)
- <result 2 with a number> (<locator>)

## Contribution and conclusions
<What the authors claim as new; their own conclusions> (<locator>).

## Limitations
<Limitations the authors name themselves> (<locator>).
<+ ones you noticed — mark them "mine".>

## Claims anchored to the source (checked)

Every load-bearing claim and every number is a separate row. The "Locator" column
follows the anchor table in SKILL.md (PDF "p. N"; docx "§section, para. N"; md/txt
"line N"). The "Checked" column is filled in during the self-check pass: the agent
re-opens the locator and looks for the verbatim quote in the re-opened text. Found → ✓.
Not found or different → fix the locator/claim surgically to match the source, or
mark it "⚠ not confirmed". A digest with unresolved ⚠ is not handed over as finished.

| Claim | Locator | Verbatim quote | Section | Checked |
|---|---|---|---|---|
| <claim 1 in your own words> | <locator> | "<verbatim quote from the source>" | <Section> | ✓ |
| <claim 2 in your own words> | <locator> | "<verbatim quote from the source>" | <Section> | ✓ |
| <number/result> | <locator> | "<verbatim quote with the number>" | <Section> | ✓ |
| <claim not found verbatim> | <locator?> | "<text searched for>" | <Section> | ⚠ not confirmed |

**Self-check log.** Rows: <N>. Confirmed: <N> × ✓. ⚠ flags: <N>. Actually re-opened
during the check: <list the locators and how — Read of a page / section / line
range>. The check is portable: only re-reading the same file, no external scripts and
no Python.

## Gaps and questions
- <What the paper lacks / what stayed unclear.>
- <Limits of a fallback extraction, if no pdf/docx skill was available.>
- <What to check, what to compare with, what to look for next> (→ lit-search).

## Citation metadata
<Authors in full, in the paper's order> · <Year> · <Title> · <Journal/proceedings> ·
<Volume/issue> · <Pages> · <DOI/URL> · <Access date, if online>.
Gaps: [verify].

## Reference-list entry

Formatted by digest itself following references/bibtex-fields.md. Lines ready to paste:

APA 7 (default): <Surname, I. I., & Surname, I. I. (Year). Article title. Journal, volume(issue),
XX–YY. https://doi.org/DOI>
GOST R 7.0.100-2018 (on request, for Russian-language lists): <Surname, I. I. Article title / I. I. Surname, I. I. Surname //
Journal. — Year. — Vol. X, no. Y. — P. XX–YY.>

Missing fields: [verify], never invented.

## Citation (.bib)

The BibTeX entry is the source's memory for a reference manager (the type depends on
the source). Shape for a preprint:

@misc{<citekey>,
  author        = {<Surname, Name and Surname, Name>},
  title         = {<Title>},
  year          = {<Year>},
  eprint        = {<arXiv ID>},
  archivePrefix = {arXiv},
  primaryClass  = {<category, e.g. cs.CL>},
  url           = {<https://arxiv.org/abs/...>}
}

Shape for a journal article:

@article{<citekey>,
  author  = {<Surname, Name and …>},
  title   = {<Title>},
  journal = {<Journal>},
  year    = {<Year>},
  volume  = {<volume>},
  number  = {<issue>},
  pages   = {<XX--YY>},
  doi     = {<10.xxxx/xxxx>}
}
```

---

## How to read the "Checked" column

- **✓**: the agent re-opened the locator (page / section / line range) and found this
  quote verbatim in the re-opened text.
- **⚠ not confirmed**: the quote was not found at the given locator or differs; the
  claim was either fixed surgically to match the source or marked unconfirmed, and all
  certainty was removed from its wording. Such a digest cannot be handed over as
  finished: first resolve the ⚠ (confirm it or move the claim to "Gaps" as "not
  stated").

The check is **portable**: only re-reading the same file by the agent itself, no
external scripts and no Python.
