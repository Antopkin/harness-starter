# Runbook: a literature review from question to bibliography

The full pipeline: **question → search → screening → download PDFs → digest → synthesis →
references → save to Zotero**. Every step is a request to the agent that you can paste into
the chat almost verbatim. The runbook relies on the `lit-search` and `digest` skills and on
the `paper-search` and `zotero` MCP servers (see `../mcp/README.md`).

> **The main rule of all source work: never invent sources.** The agent includes in the
> review only works it actually found and opened. Each one has an identifier (DOI, arXiv ID
> or URL). Whatever is missing is marked `[verify]`, not guessed. If nothing reliable turned
> up on the topic, the honest answer is "nothing found".

---

## Step 1. Formulate the question and the terms

We turn the topic into a testable research question and a set of keywords.

> Help me turn the topic "`<my topic>`" into a research question and list 4–6 key terms
> with synonyms in English and in my working language. If the topic is ambiguous, show
> 2 readings and ask which one I need.

Why a separate step: a bad query → noisy results → wasted time. English synonyms are a
must: most research is published in English.

## Step 2. Search through `paper-search`

We ask the agent to search several databases at once and return candidates, not a
finished conclusion.

> Using `paper-search`, find works for the query `<terms>`. Go through arXiv, Semantic
> Scholar, OpenAlex and `<PubMed for medicine / SSRN for the social sciences>`. Return
> 15–25 candidates as a table: authors, year, title, database, DOI/arXiv ID, a one-line
> gist from the abstract. Do not download anything yet.

Good to know:
- Databases by field: **arXiv / DBLP** — CS, physics, mathematics; **PubMed / Europe
  PMC / PMC** — medicine and biology; **SSRN** — economics, law, social sciences;
  **DOAJ / BASE / CORE / OpenAlex** — broad open access; **CrossRef** — when you already
  have a DOI and need the metadata.
- No MCP access? The `lit-search` skill does the same step with ordinary web search.

## Step 3. Screening

We narrow the funnel by title and abstract, before any downloading.

> From this list, keep the ones that directly answer the question `<question>`. Give one
> reason for each one you drop. Red flags: no author/year/journal, loud claims with no
> method, a work that exists nowhere except on one odd page. Keep the 5–8 most relevant.

Keep the funnel narrow: 6 papers read beat 25 references unread. The agent must show
borderline cases rather than drop them silently.

## Step 4. Download the PDFs into `materials/`

We fetch the full texts of what was kept: legally and from open access first.

> Download the PDFs of the selected works into the `materials/` folder. Use open access:
> `download_with_fallback` via arXiv/OpenAlex/Unpaywall. Anything behind a paywall with no
> open version: do not pull it, list it separately under "needs university access".

- A paywalled paper often has an open version: a preprint on arXiv/SSRN, a PDF on the
  author's site, the university repository, Unpaywall; the agent checks them automatically.
- Whatever remains behind a subscription goes to `eresources.md` (browser + university
  login). Shadow libraries are not used.
- Files in `materials/` are not versioned (see `.gitignore`): they are your personal copies.

## Step 5. Digest every PDF with `digest`

Every downloaded paper becomes a structured digest.

> Run `digest` on every PDF in `materials/` from this review. I need: the gist in one line,
> the problem/gap, method, data, results with numbers, limitations and verbatim quotes, with
> **a page for every quote and every number**. Whatever the paper does not contain, write
> "not stated"; do not make it up.

The digest rule: a quote only verbatim and with a page; the author's voice and your
conclusion on separate lines. The agent reads long PDFs in page ranges and keeps the real
page numbers. For a scan or a complex layout, run OCR first (for example with the OCR mode of
the `latex-document` skill or a tool such as `ocrmypdf`).

## Step 6. Synthesis: assemble a mini-review

We stitch the separate digests into a coherent review of the field.

> Assemble a mini-review from the digests: 2–4 paragraphs on what the field says, where
> it agrees, where it disagrees, where the gap is. Back every statement with a reference to
> a specific work [n]. Do not generalise beyond what was read. At the end, add a "Gaps and
> next steps" section and a "Not confirmed" section for works that could not be opened.

A synthesis is not five abstracts retold in a row but a map: lines of work, disagreements,
blank spots. All of it referenced to what was read.

## Step 7. Format the references with `digest`

From the collected metadata, a correct bibliography.

> Using `digest`, format the reference list for the selected works in `<APA 7 / GOST R
> 7.0.100-2018 / BibTeX>`. Take the metadata from the digests; where something is missing,
> mark it `% TODO: verify`; do not invent DOIs, pages or authors.

If `paper-search` is connected, the agent can fetch BibTeX by DOI through CrossRef, but the
automatic record is still checked against the source: such records contain errors in
authors and pages.

## Step 8. Save the result to Zotero

We put the digests and the synthesis back into the library, as notes attached to the
sources.

> For the works that are already in my Zotero library, find them through `zotero` and
> attach to each a note with its digest. Add the common tag `<review-topic>`. Save the
> mini-review itself as a separate note and tag it as well.

Important about "save to Zotero":
- The `zotero` server **writes notes, annotations and tags** to records that are already
  in the library. It does not create a **new** record (the paper itself).
- If a work is not in Zotero yet, add it yourself with the **Zotero Connector** button in
  the browser (from the paper's page or by DOI), then repeat the request: the agent will
  find the fresh record and attach the digest. Details are in `zotero.md`.

---

## The short version (one message)

When you want to launch the whole pipeline at once and leave the details to the agent:

> Let's do a literature review on "`<topic>`". Plan: (1) refine the question and the
> terms; (2) using `paper-search`, find 15–25 candidates across arXiv/Semantic
> Scholar/OpenAlex `<+ a field database>`; (3) keep 5–8 relevant ones and show the
> reasons for exclusion; (4) download their open PDFs into `materials/` and list the
> paywalled ones separately; (5) run `digest` on each, with pages for quotes; (6) assemble
> a mini-review with references [n] and a "Gaps" section; (7) format the reference list
> with `digest` in `<style>`; (8) put the notes and the synthesis into Zotero under the tag
> `<topic>`. Show the result after each step and invent nothing; mark anything unverified
> `[verify]`.
