# Runbook: questions to your own PDF folder (local RAG)

How to ask questions about your own collection of papers and get answers **with page
references** rather than general musings. "RAG" here, in plain words: the agent finds the
relevant passages in your PDFs itself and answers from them, citing the source and the page.

For a small or medium collection you need neither a database nor a separate server: the
agent reads the files in `materials/` directly. It relies on the `digest` skill.

---

## How to lay out the materials

1. Put the PDFs (and other texts) into the **`materials/`** folder at the root of your
   working folder.
2. Give the files meaningful names, `Author_Year_short-title.pdf`, so that both you and the
   agent can refer to a specific work more easily.
3. Files in `materials/` are **not versioned** (see `.gitignore`): they are your personal
   copies and do not go into git.
4. If you want order in a large collection, create subfolders by topic:
   `materials/topic-A/`, `materials/topic-B/`.

## How to ask (a single document or two)

> Using the file `materials/<name>.pdf`, answer the question: "`<question>`". Answer
> **only** from the text of the paper. Give a page reference for every statement; where you
> cite the author's wording, quote it verbatim in quotation marks. Whatever the paper does
> not contain, say so, "not found in the paper"; do not fill it in.

## How to ask (across the whole collection)

> Look through the PDFs in `materials/` and answer: "`<question>`". First say which files
> contain an answer, then bring them together. For every point, **file + page**. If the
> works disagree, show the disagreement instead of averaging it out. Invent nothing.

Tip: if there are many files, ask for **navigation** first and the deep answer afterwards;
this saves time and does not hit the limit of a single pass:

> First, one line per PDF in `materials/`: what it is about. Then I will tell you which
> ones to go deeper into.

## An answer with page references: what to demand

A good "RAG answer" here always:
- **is tied to a page** — "…(file `Smith_2021.pdf`, p. 7)", not "somewhere in the paper";
- **separates quote from paraphrase** — verbatim text in quotation marks, your conclusion
  on a separate line marked as interpretation;
- **is honest about a gap** — if the materials contain no answer, the answer is "not found",
  not an excuse to compose something plausible;
- **does not mix sources** — a fact from one paper is not attributed to another.

---

## Limitations (important to understand)

- **The volume per pass is limited.** The agent cannot "load" hundreds of PDFs at once:
  there is a ceiling on the amount of text in one line of reasoning. In practice, up to
  ~5–15 papers per question can be read directly; beyond that, either narrow the question
  down to the files you need, or go in two steps (navigation → deep analysis of the
  selected ones), or split the collection into thematic batches.
- **Scans and complex layouts.** A PDF that is an image (a scan) or a multi-column layout
  with tables and formulas extracts poorly. In that case run OCR/extraction first (for
  example with the OCR mode of the `latex-document` skill or a tool such as `ocrmypdf`),
  and only then ask questions about the text.
- **This is not a "smart search across the whole library".** Here the agent reads the
  files you put into `materials/`. If you need search across a large library you have
  already built, that is Zotero: it has full-text and semantic search (see `zotero.md`).
- **Page numbers come from the document, not from imagination.** Demand real numbers; if
  the PDF has no pagination, the agent gives the page's position in the file and says so.
- **Freshness.** The answer reflects only what is in `materials/` at the time of the
  question. Added new PDFs? Repeat the request so that the agent takes them into account.

## When you need a "real" vector RAG

If you really have many PDFs (dozens to hundreds) and ask questions all the time, direct
reading will not be enough: you need an index (a vector database) that finds the relevant
passages in advance. Two practical routes without infrastructure of your own:
- **Through Zotero:** put the papers into the library and use its full-text and semantic
  search through the `zotero` server; it plays the role of the index (see `zotero.md`).
- **A separate RAG server** can be connected as one more MCP server, but that is a
  technical setup beyond this runbook; `materials/` + Zotero is enough for most work.
