---
name: digest
description: >
  Source-anchored digest and abstract of a research paper, plus a ready-made
  reference entry. Formats: PDF, docx, md, txt. Every load-bearing claim and every
  number becomes a row in a table of claim, locator, verbatim quote, section and
  checked; the locator depends on the format (PDF is always a page, docx a section
  and paragraph, md/txt a line), and the agent itself re-opens each locator and
  re-checks each quote (portable, no scripts). At the end digest formats the
  reference itself, APA 7 by default and GOST R 7.0.100-2018 on request for
  Russian-language reference lists, and builds a BibTeX entry.
  Quotes only verbatim with a locator; "not stated" instead of a guess; never invent
  a DOI or pages. Triggers: "digest this PDF", "digest this docx", "summarize this
  paper", "abstract of the paper", "pull out the paper's claims", "format the
  reference", "reference list", "make a bibtex entry", "digest". NOT: finding
  literature on a topic (lit-search); NOT: summarizing a meeting or a chat.
---

# digest: a source-anchored digest of a research paper

The skill turns a research paper into a structured digest: what the work is about,
which method it uses, what it found and where its limits lie. It handles four
formats, **PDF, docx, md and txt**. What sets it apart is that every load-bearing
claim and every number is **anchored to a place in the source**: a locator, a
verbatim quote and a section, and the agent **re-opens that place itself** to confirm
that the quote stands where the digest says it does. The digest ends with a
ready-made reference-list entry (APA 7, optionally GOST) and a BibTeX entry. It is
for documents only (PDF, docx, md, txt); web and social content (x.com, Reddit, VK,
feeds) goes to the `web-parse` skill, and transcripts do not belong here.

A PDF is simply one case of `digest` (the locator is a page); one protocol covers
every format.

Place in the chain: find literature on a topic with `lit-search`; **digest a paper
you found and format its reference right away with `digest` (this skill)**. There is
no separate formatting step: digest itself produces the reference entry and the
BibTeX (see the final step below).

The target output shape lives in `references/OUTPUT-TEMPLATE.md`. Checked worked
examples: a PDF example (Hinton et al. 2015) in `references/EXAMPLE-digest-pdf.md`,
and docx and md examples in `references/EXAMPLE-digest-docx.md` and
`references/EXAMPLE-digest-md.md`.

## Routing: how to open the source

Choose the path **at step 0, before deep reading**. Do not confuse two layers of
delegation: choosing a path by format is part of `digest` itself, while the external
`pdf` and `docx` skills (text extraction) are separate skills that may not be
installed. Reference formatting is never delegated to another skill; digest builds
it itself (see the final step).

0. Identify the format: the file extension plus a quick look at the content.
1. **md / txt** → read the file directly (`Read` in Claude Code, the host's file-read
   tool elsewhere). The structure is native, trust is highest, no external skill is
   needed, and nothing can degrade by construction.
2. **docx** → if a `docx` skill is installed, delegate extraction to it (clean text
   plus the heading hierarchy), then digest. No such skill → graceful fallback:
   extract the text with `pandoc -t markdown file.docx`, which keeps the heading
   levels as `#` marks that the docx locator needs (plain-text converters flatten
   the headings), and record the limitation in the header and in "Gaps". If the binary cannot be read at all, say so and do not
   invent its content.
3. **PDF** → `Read` in page ranges; keep the document's real page numbers in the
   digest. Detect a scan or corruption: as a rule of thumb **more than 30 %
   unreadable**, garbled characters, words glued together, an almost empty text layer
   over a non-empty page image. If detection fires and a `pdf` skill is installed,
   delegate extraction to it (OCR, tables) and digest the clean text. No `pdf` skill →
   graceful fallback: work with whatever text layer exists; keep damaged fragments as
   they are, marked `[unreadable / OCR garble]`. "Repairing" OCR in your own words is
   forbidden (a "fixed" quote fails the verbatim check); mark doubtful sections
   `[check manually]` and check their quotes twice.

**Graceful-fallback invariant.** A missing `pdf` or `docx` skill never blocks the
work and is never a reason to invent. Always: the fallback route from the steps above
(direct reading for PDF, md and txt, the `pandoc` extraction for docx), an explicit
note of the extraction limitation in the output, lower trust and a stricter self-check. A claim
without a usable anchor goes to "Gaps" as "not stated" instead of getting a fake
anchor.

**Note for this kit:** the `pdf` and `docx` skills are proprietary and are not shipped
here. Unless you install your own, the fallback is **the main path, not an edge
case**, for scanned PDFs and for docx. The skill must produce a correct (if labelled)
digest with zero helper skills.

Trust ladder (the lower the rung, the stricter the check): digital-born with the
source file available (docx / md / LaTeX) → digital-born PDF → scan or OCR →
fallback (no extraction skill).

## Anchor by source type

"Page N" generalises to a **locator**: the smallest address that lets you (1) re-open
exactly that place and (2) find the verbatim quote in it. The locator differs by
format in content but not in role: there is one column in the table, and only what
you write in it changes.

| Format | Locator unit | What goes in the "Locator" column | Re-opening during the check |
|---|---|---|---|
| PDF | page; for tables and figures also the number or caption | `p. 4`; `p. 5, Table 1` | `Read` the same PDF on exactly that page |
| docx | heading path + paragraph number within the section | `§2.1 Method, para. 3` | re-read that heading's section (after extraction) |
| md | heading + line number | `## Results, line 42` | `Read` with offset/limit around the line |
| txt | line number or line range (no headings) | `lines 120–124` | `Read` with offset/limit around the lines |

Rules on top of the table:

- **A PDF locator always has a page number.** For PDF the locator ALWAYS carries the
  page (`p. N`); tables and figures add their number or caption ("Table 1"), but the
  page is always there. For **docx** the locator is the heading path (section or
  heading) plus the paragraph number within the section; for **md/txt** it is the
  heading (or its absence) plus the line number. Without that unit the locator is not
  ready for its format.
- **Granularity** is a structural unit of natural size (a paragraph, a section), not a
  character offset and not an isolated sentence; the quote itself is an exact short
  substring inside the locator.
- **Anchor tables and figures as a whole** by number or caption ("Table 1"), not by a
  fragment of a cell: on a second parse the table gets restructured and the verbatim
  check fails.
- **The source beats the render**: if the PDF's own docx / md / LaTeX lies next to
  it, take structure and anchors from the source and use the PDF to check page
  numbering.
- **Presumption of trust by format**: md/txt and docx have native structure and high
  trust; for PDF the heading hierarchy has to be reconstructed, so presume distrust
  and always check.

## Rule: a quote is verbatim and has a locator

- **Quotes are verbatim.** Put only the exact source text inside quotation marks. Do
  not "improve" the wording and do not translate inside the quotes (give a
  translation next to it, separately, marked "tr.").
- **Always give the locator** for every quote and every specific number or fact,
  following the anchor table above. No locator, no finished quote.
- **Keep the author's voice apart from yours.** "The author claims X" and "hence Y
  (mine)" are separate lines. Mark your own conclusions explicitly.
- **Do not make up results.** If a number is not in the text, write "not stated". Do
  not derive an "approximate" value and do not fill it in from memory.
- **A gap is a finding, not an invitation to invent.** Whatever the paper lacks
  (data, method, a limitation) goes into "Gaps", not into a guess.

## Reading protocol

1. **Metadata**: authors, year, title, journal or conference, DOI (for a preprint,
   the arXiv ID). You will need the same data for the final reference.
2. **Abstract and conclusions**: read the abstract and the conclusion first; they
   give the frame (problem → what was done → what came out).
3. **A full structural map**: walk the sections (Introduction, Related work, Method,
   Data, Results, Discussion, Limitations). Note where everything sits and under
   which locator (page, section, line).
4. **Walk along natural boundaries**: follow the structure, where **a section is a
   chunk**, rather than cutting by characters. Read the method and the results
   closely: that is where the facts most often get distorted in retelling. Write down
   numbers and quotes with their locators as you go, checking against the locator
   checklist in the anchor table.
5. **Anchor table**: build the structured table of claim · locator · verbatim quote ·
   section · checked (see below). Every load-bearing claim and every number gets its
   own row.
6. **Self-check**: re-open every row at its locator and confirm the quote (see
   below). Do not hand over a digest with unresolved ⚠.
7. **Reference and BibTeX**: the final, mandatory step. Format the reference yourself
   (APA 7, and GOST if asked for) and build the BibTeX entry following
   `references/bibtex-fields.md`; append both blocks to the end of the digest (see
   below).

## Anchor table: every claim tied to a place in the source

Instead of a prose list of quotes, use a **structured table**, the same for every
format. Columns:

| Claim | Locator | Verbatim quote | Section | Checked |
|---|---|---|---|---|

- **Claim** is atomic: one statement or one number, briefly in your own words. One
  table row is one fact, not a paragraph.
- **Locator** is the address from the anchor table (PDF `p. N`; docx `§section,
  para. N`; md/txt `line N`).
- **Verbatim quote** is the exact source text, in quotation marks. Shorten a long one
  with an inner `…`, but every fragment you keep must be verbatim. Do not translate
  inside the quotes.
- **Section** is a human-readable name (Introduction, 3 Method, 4.1 Results,
  Discussion…).
- **Checked** is `✓` or `⚠ not confirmed`, filled in during the self-check pass.

Rule: **every load-bearing claim and every specific number from the "Method",
"Results", "Contribution" and "Limitations" sections must have a row** in this table.
No row with a confirmed quote means the claim goes to "Gaps" as "not stated", not into
the body of the digest.

## Self-check: re-open and confirm every row

Once the table is built, run **a separate pass, independent of the draft**: checking
"from memory" does not count. There is one tool, re-reading the same file by the
agent itself, **with no external scripts and no Python**.

For **every** row of the table:

1. **Re-open the exact locator** with the recipe for its format from the anchor
   table: PDF, `Read` exactly that page; docx, re-run the same extraction (the same
   `docx` skill or the same `pandoc -t markdown` command) and re-read that heading's
   section in its output; md/txt, `Read` with offset/limit around the line.
2. **Find the verbatim quote** in the re-opened text. Normalisation tolerance:
   differences in whitespace, line breaks, hyphenation and ligatures are fine;
   paraphrase, swapped words or "improved" wording are not.
3. **Fill in the "Checked" column:**
   - found verbatim at this locator → `✓`;
   - not found, the text differs or the place is different → fix the locator or the
     claim **surgically to match the source** (you fix the claim, you never bend the
     quote) and check again; if it still cannot be confirmed → `⚠ not confirmed`, and
     every trace of certainty is removed from the claim's wording.
4. **A look back**: while the locator is open, check whether a significant statement
   nearby is missing from the digest (the reverse direction of the check).

**Do not hand over a digest with unresolved `⚠` as finished.** Either `✓`, or the
claim goes to "Gaps" as "not stated". Under the table keep a **self-check log**: how
many rows, how many ✓, how many ⚠, and which locators were actually re-opened and
how. It is the only protection against false-green ✓.

## Final step: reference and BibTeX (inside digest)

Reference formatting is part of digest: the skill is self-contained and calls no
other skill for it. A digest **is not finished without the final formatting**. The
single reference for entry types, required fields and APA 7 / GOST examples is
`references/bibtex-fields.md`; look there for the exact field set of a given source
type.

After the anchor table is checked:

1. Gather a metadata block (authors in the paper's order · year · title · source
   type · journal/conference or arXiv ID · volume/issue · pages · DOI/URL).
2. **Choose the entry type** from `references/bibtex-fields.md`: `@article`,
   `@inproceedings`, `@misc` (preprint/web) and so on.
3. **Fill in the fields** from the metadata. Mark gaps with `% TODO: verify`; **never
   invent** a DOI, pages, volume or authors. An honest gap beats an invented field.
4. **Output two blocks at the end of the digest:**
   - `## Reference-list entry`: a formatted **APA 7** line (the default), plus a
     **GOST R 7.0.100-2018** line when the user asks for it or the reference list is
     in Russian; both ready to paste into Word or Google Docs;
   - `## Citation (.bib)`: the BibTeX entry (the source's memory, for a reference
     manager).

Need ONLY the reference, without a digest? Use this final block on its own: standalone
reference formatting lives inside digest (triggers "format the reference", "make a
bibtex entry", "reference list").

## Several sources at once

Each source gets **its own digest** from the template, with its own anchor table and
its own BibTeX entry. Do not merge sources into one summary and do not attribute a
fact to the wrong paper: every quote and number must show its paper and its locator.
If you need a combined review of several papers on a topic, that is `lit-search`.

## Output language

Write the digest and its explanations in the language of the user's request. Keep
quotes in the original language; if needed, give a translation next to them marked
"tr.". Names, titles and DOIs stay as in the original.

## Digest skeleton

Below is the skeleton. The full target shape, with the table and the final reference
sections (APA 7 / GOST and .bib), is in `references/OUTPUT-TEMPLATE.md`.

```
# Digest: <Authors, Year — Short title>

**Biblio:** Authors (Year). Title. Journal/conference/preprint. DOI/URL.
**Read:** <locator range — pages or sections>
**Format:** <PDF / docx / md / txt>  ·  **Extraction trust:** <digital-born |
scan/OCR | fallback: skill N unavailable>  ·  **Date:** <YYYY-MM-DD>

## The gist in one line
What the work is about and its main finding, in one sentence of your own.

## Problem and gap
Which problem is addressed; what was wrong or missing before (locator).

## Method
What exactly was done: approach, model, study design, procedure (locator).

## Data / material
Sample, dataset, sources, size; how it was collected (locator). None: "not stated".

## Results
Main results with specific numbers and locators. Only what is in the text.

## Contribution and conclusions
What the authors claim as new; their own conclusions (locator).

## Limitations
Limitations the authors name themselves (locator) + ones you noticed (mark "mine").

## Claims anchored to the source (checked)
| Claim | Locator | Verbatim quote | Section | Checked |
|---|---|---|---|---|
| … | … | "…exact text…" | Section | ✓ |

## Gaps and questions
- What the paper lacks / what stayed unclear; limits of a fallback extraction.
- What to check, what to compare with, what to look for next (→ lit-search).

## Citation metadata
Authors (in full, in the paper's order) · Year · Title · Journal · Volume/issue ·
Pages · DOI/URL · Access date (if online). Gaps: [verify].

## Reference-list entry
APA 7 line (default), plus a GOST R 7.0.100-2018 line on request (ready to paste into Word/Google Docs).

## Citation (.bib)
BibTeX entry (see "Final step: reference and BibTeX").
```
