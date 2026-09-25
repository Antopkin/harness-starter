---
name: lit-search
description: >
  Search for and first review of academic literature. How to search (arXiv
  directly, web search, a browser to paid e-resources and a university library when
  you have access), how to filter out what is irrelevant, how to assemble a mini
  review with verifiable citations. Anti-hallucination at the core: never invent
  sources. Triggers: "find literature", "literature review", "what is known
  about…", "find papers on", "lit-search". NOT: a digest of your own paper, use
  digest; NOT: formatting a reference, use digest (reference formatting is part of
  digest).
---

# lit-search — searching for and a first review of the literature

Helps you find relevant research on a topic, filter out the noise and assemble a
short review with honest, verifiable references. This is the first step of research:
scouting the field, not writing the paper.

Next in the chain: to write a detailed digest of a paper you found and format its
reference for the bibliography in the same pass, use `digest` (it covers both the
digest and the reference formatting).

## The iron rule: never invent sources

A hallucinated source is the worst mistake in this work. It costs more than finding
nothing.

- **Cite only what you actually opened.** Every source in the review is a work you
  found through search and confirmed to exist (you opened the page, saw the abstract,
  took the identifier). Do not assemble a "plausible" reference from memory.
- **Do not fill in fields.** If you do not know the year, DOI or authors, do not
  guess. Leave a gap and mark it `[verify]`.
- **Separate fact from paraphrase.** "The abstract says X" ≠ "the work proves X". In
  the review write what you actually read, not what you inferred from the title.
- **Every source gets an identifier.** A DOI, an arXiv ID or a direct URL by which
  the work can be found again. No identifier means the source is not confirmed.
- **Zero results is a valid answer.** If nothing reliable turned up on the topic, say
  so. Do not fill the void with invention.

## The working cycle

1. **Refine the query.** Phrase the topic as a research question: subject + aspect +
   (optionally) population/period/method. From the question, write down 3–6 key
   terms and their synonyms, in the user's language and in English (most research is
   published in English). If the topic is ambiguous, show 2 readings and ask which is
   meant.
2. **Search** (see "Where to search"). Start with 2–3 venues, combine the terms.
3. **Filter** by title and abstract (see "How to filter"). Keep the funnel narrow.
4. **Read the shortlist** in layers: abstract → introduction and conclusions → deeper
   if needed. A deep digest of a single paper is already `digest`.
5. **Assemble the mini review** using the template below, with citations and
   identifiers.

## Where to search

Start with what is free and open; move to paid resources when you have access.

**Open access (start here):**
- **arXiv** (`arxiv.org`): preprints in physics, CS, mathematics and quantitative
  fields. Search on the site directly or through web search: `topic site:arxiv.org`.
  Every work has an arXiv ID (e.g. `2401.01234`); take it.
- **Web search across research venues**: use whatever web search tool you have.
  Useful operators: `filetype:pdf`, `site:`, quotes for an exact phrase. Good
  targets: **Semantic Scholar**, **Google Scholar**, **OpenAlex**, **PubMed**
  (medicine/biology), **DOAJ** (open journals), **SSRN** (economics/law/social
  sciences), **CORE**, **PhilPapers** (philosophy).
- **Reading a page directly**: when you have the URL of a work or of a results list,
  open it with a web page reading tool and extract the abstract and metadata.

**Paid resources and a university library (when you have access):**
- Through the **browser** (a browser control tool, if connected), go into subscription
  databases under your own university login: **Scopus**, **Web of Science**,
  **JSTOR**, **ScienceDirect**, **Springer**, **eLibrary/RSCI**, your library's
  e-book systems. Log in yourself; do not ask me to enter other people's passwords.
- Universities often have an **access proxy** (EZproxy) or single sign-on; go in
  through the library portal and the full texts open.
- No full text behind the paywall? Check for an open version: **Unpaywall**, a
  preprint on arXiv/SSRN, a PDF on the author's site or in a university repository.

**If you have special MCP tools connected** (e.g. `paper-search`, `jina`, `exa`,
`zotero`), use them to speed up search and metadata extraction. But do not depend on
them: the basic cycle works on plain web search + page reading.

## How to filter

A fast funnel: "title → abstract → a quick skim". Discard at every step.

Keep a work if:
- it answers your question directly (not a neighbouring topic);
- it is a verifiable source: there is a journal/conference/repository and an
  identifier;
- it is (usually) recent if the field moves fast; for the foundations, the key older
  works are needed too;
- it is well cited OR is clearly a recent or niche result (few citations are not
  always a minus for a new work).

Red flags, be wary:
- no author, affiliation, year or journal; the "journal" looks predatory;
- loud claims without data or method; the result cannot be reproduced;
- the source cannot be found anywhere except one suspicious page;
- you could not open the work and confirm it exists → **do not include it**.

## Mini review format

```
# Mini literature review: <topic>

**Question:** <the research question in one sentence>
**Queries:** <which terms/venues were used>
**Search date:** <YYYY-MM-DD>  ·  **Venues:** <arXiv, Scholar, …>

## What the field says (synthesis)
2–4 paragraphs: the main lines of work, where there is agreement, where there is
dispute, where there is a gap. Back every claim with a reference [n]. Do not
generalise beyond what you read.

## Key sources
1. Authors (Year). Title. Journal/conference/repository.
   - Identifier: DOI / arXiv ID / URL
   - Gist in 1–2 lines: what they do, the main finding (from the abstract/text)
   - Relevance: how it helps your question
2. …

## Gaps and next steps
- What is missing from what you found; which questions are open.
- What is worth reading in depth and formatting for the bibliography (→ digest).

## Not confirmed / in doubt
- Sources you could not open or verify. Stated openly, not disguised.
```

## What to record for every source

So that you can later assemble a correct reference (`digest`) without searching
again, save for every work right away: the **authors** (in full, in the order given
in the paper), the **year**, the **exact title**, the **journal/conference/publisher**,
the **volume/issue/pages**, the **DOI** (or arXiv ID), the **URL**, and the **access
date** (for online resources). Mark whatever is missing `[verify]`; do not invent it.

## Reply in the language of the user's request

Write the review and the explanations in the language of the user's request. Keep the
titles of works, author names and technical identifiers (DOI, arXiv ID) in the
original.
