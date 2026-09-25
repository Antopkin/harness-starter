# AGENTS.academic.md — the academic overlay addendum

This is an **add-on** to `AGENTS.md` for work with academic sources. It is read
**together with** that file, not instead of it: all the base rules (think before
coding, simplicity, surgical edits, prove the result, keep away from secrets) still
apply. This file adds one layer on top, **the discipline of research integrity and
method**, and shows which overlay skills carry it out.

Everything here is written for **anyone who uses the overlay**, not for a particular
person: it works out of the box, the keys are your own, and so are the paths and the
library.

> **Why a separate file.** The base `AGENTS.md` teaches the agent to behave carefully
> in any kind of work. Academic work adds what the general rule set lacks: how to
> handle sources, data and conclusions so that the work can be **trusted and
> reproduced**. Those rules follow below.

---

## How to switch this layer on

The addendum stays where it is, at `tracks/academic/AGENTS.academic.md`, and is imported
in place rather than copied into the root; every path in it is written relative to the
repository root. To make the agent read it:

- **Claude Code:** add the line `@tracks/academic/AGENTS.academic.md` to `CLAUDE.md`, below
  the line `@AGENTS.md`. Copy the overlay skills to where the tool calls them with `/`
  (`mkdir -p .claude/skills && cp -R tracks/academic/skills/. .claude/skills/`, as in
  `tracks/academic/README.md`).
- **OpenCode / Codex:** these tools read `AGENTS.md` directly; add a line to it telling the
  agent to read `tracks/academic/AGENTS.academic.md` for academic work. Skills are wired in
  natively: Codex looks for them in `.agents/skills/`,
  OpenCode reads both `.agents/skills/` and `.claude/skills/`. Copy them there
  (`mkdir -p .agents/skills && cp -R tracks/academic/skills/. .agents/skills/`), and both
  call them on their own by `description`.
- **At the start of every session** read this file together with `AGENTS.md`: the
  integrity rules must hold from the first step, not after the fact.

---

## The rule above all: the source must be provable

Academic work exists so that another person can **follow your tracks and arrive at the
same place**. A reference lets the reader find the source; a quote lets them see what
you saw; a search log lets them repeat the search. Any invented source, DOI or page
number breaks the very purpose of the work. That is why the six rules below are not a
formality but the core of this overlay.

## 1. Cite everything, invent nothing

- **Every non-trivial claim carries where it comes from.** Not "it is known that…" but
  "X (Author, year, DOI/arXiv ID/URL, p. N)". Common knowledge can go without a
  reference; a specific fact, number or someone else's conclusion only with one.
- **Never make up a bibliography.** Source, DOI, page number, authors and year come
  only from a source you actually opened. An invented "plausible" reference is the
  worst mistake you can make here, worse than finding nothing.
- **No source? Say so plainly.** "I found no reliable source on this", "not verified",
  "no source" are valid, honest answers. We do not fill a gap with a guess. Zero
  results is a result too.
- **Confirm existence.** A source in the work is one you opened: you saw the page,
  abstract or PDF and took its identifier (DOI, arXiv ID, stable URL). If you could not
  open and confirm it, **leave it out** and move it to a "not confirmed" section.
- **Mark a missing field `[verify]`;** do not guess the year or fill in authors "from
  memory".

## 2. Claim ≠ source

Keep apart **what is said** and **where it comes from**, and within that, **what the
source says** and **what you inferred**. Give every non-trivial statement an explicit
provenance label:

- **IN THE SOURCE** — stated or shown directly in the work; carries a locator (page,
  section, table).
- **INFERRED** — your interpretation on top of the source. Mark it explicitly and **do
  not quietly promote** it to fact. "The abstract says X" ≠ "the work proves X".
- **ASSESSMENT / RECOMMENDATION** — your judgement, not the content of the source.

The author's voice and your conclusion go on **separate lines**. A paraphrase is not a
quote: verbatim text only in quotation marks and with a page (see the `digest` skill).

## 3. Reproducibility: record the search trail

So that a search can be repeated, write down for every pass through the literature:

```
Query:     <exact terms / query string, as typed>
Date:      <YYYY-MM-DD>
Searched:  <arXiv, Semantic Scholar, PubMed, Scopus, …>
Version:   <edition / preprint vX / access date for an online resource>
```

- **The query, verbatim.** "Looked for stuff on emotions" cannot be reproduced;
  `("emotion regulation" AND adolescents) 2015..2024` can.
- **The date is mandatory:** database and web search results change over time.
- **The version of a source matters:** a preprint ≠ the published version; a 2nd
  edition ≠ the 1st. For an online resource, record the access date.

## 4. Transparency of method

- **Both quantitative and qualitative data.** Do not pick only what suits the
  conclusion. A contradicting fact is shown, not hidden.
- **Do not bend the conclusion towards what you want.** Formulate the question and the
  hypothesis **before** you look at the data; report negative and null results too. If
  you found the opposite of what you expected, write exactly that.
- **Show the funnel.** How many you found → how many you excluded and why → how many
  you read. Show borderline exclusions instead of dropping them silently (see
  `tracks/academic/runbooks/lit-review.md`).
- **Separate description → interpretation → recommendation.** These are three
  different layers; do not mix them in one sentence.

## 5. Take care when translating terms

- **Keep the term, do not swap the meaning.** A term has a precise scope; a
  near-synonym in another language often shifts the meaning (`agency`, `validity`,
  `bias`, `framework`, `salience`). Give the translation as a gloss with the original
  in brackets next to it; do not replace it silently.
- **Mark a translated quote "(trans.)"** and keep the original next to it. A verbatim
  quote in quotation marks stays in the language of the source: a translation inside
  quotation marks distorts the data.

## 6. Take care when generalising from a single case

- **n=1 is neither a field nor a population.** One interview, one paper, one dataset
  is an illustration or a hypothesis, not proof. The scope of the conclusion equals the
  scope of the evidence.
- **Do not turn one informant's remark into "people think X".** One voice speaks for
  itself. A generalisation needs either a sample or an explicit caveat, "based on a
  single case".
- **"Recent/niche" ≠ "insignificant", but also ≠ "established".** Keep a single result
  as a single result until others confirm it.

---

## Overlay skills and tools

The backbone of literature work already exists in the base harness: **`lit-search`**
(search and first overview) → **`digest`** (a digest of a PDF or other document with a
page or locator for every quote, ending with a formatted reference in APA 7 / GOST /
BibTeX). Both are built around preventing hallucinated sources. The full step-by-step
pipeline is `tracks/academic/runbooks/lit-review.md`; the search accelerators (paper
databases and Zotero) are in `tracks/academic/mcp/README.md`.

On top of the backbone the overlay adds larger skills (they live in
`tracks/academic/skills/`):

| Skill | What it is for | When to call it |
|---|---|---|
| `deep-research` | Rigorous research on a question: systematic review, meta-analysis, fact-check | A big research question that needs a protocol and a synthesis of many sources |
| `academic-paper` | Writing the paper itself (IMRaD, review, case study, policy brief), citations, bilingual abstract | The material is gathered and it is time to write |
| `academic-paper-reviewer` | Simulated peer review (several independent reviewers) | Before submission, to run the draft past "reviewers" |
| `paper-audit` | Integrity audit: claims without a source, invented quotes, banned phrasing | Checking the honesty of a finished text before you hand it in |
| `transcript-verbatim` | Verbatim correction of ASR output: fix recognition errors only, keep the speech word for word | Transcripts of interviews or focus groups where **speech is data** |
| `transcript-polish` | Readable, coherent prose from spoken language that keeps the meaning | A transcript has to become readable for analysis |

The overlay's other skills (`academic-pipeline`, `transcript-docs` and the `latex-*`
family) are listed in the overlay README, `tracks/academic/README.md`.

The overall flow: **research** (`deep-research` / `lit-search`) → **digest**
(`digest`) → **writing** (`academic-paper`) → **self-audit** (`paper-audit`) →
**review** (`academic-paper-reviewer`) → **references** (`digest`). The qualitative
branch: interview → `transcript-verbatim` / `transcript-polish` → analysis → `digest`
for the references. The `transcript-*` family relies on the shared input file
`tracks/academic/skills/shared/transcript-io.md`.

**How a skill is invoked** (by tool):

- **Claude Code:** by name with `/` (`/deep-research`, `/paper-audit`, …) or
  automatically from the description in the frontmatter.
- **OpenCode:** the built-in `skill` tool picks a skill by the description in the
  frontmatter (skills live in `.agents/skills/` or the compatible `.claude/skills/`).
- **Codex:** automatic pick by description plus the `/skills` list for manual choice
  (skills live in `.agents/skills/`).
- A skill marked user-invoked (`disable-model-invocation: true`) stays manual only in
  Claude Code; OpenCode and Codex may still invoke it on their own.
- **No skill at hand?** The basic loop still works: stick to rules 1–6 of this file
  and do the steps by hand (for literature, follow `tracks/academic/runbooks/lit-review.md`). Skills
  speed things up and standardise them, but integrity comes from the rules, not from
  the tooling.

## Keys and secrets

- **Keys of external services appear only as placeholders in examples.** The overlay's
  MCP servers (`zotero`, `paper-search` and embedding providers) need **personal**
  keys. Every example and template uses `YOUR_..._KEY` / `YOUR_..._ID`, never a real
  key. The real key lives only in the local `.mcp.json` in the repository root, which
  stays out of git (see `tracks/academic/mcp/README.md`).
- **The base guardrails of `AGENTS.md` apply.** We do not read, edit or commit
  `.env*`, `*token*`, `*secret*`, `*credentials*`; we do not print keys into logs or
  error messages.

## Method memory

Following the memory rule in `AGENTS.md`: after a correction and as the work goes on,
write to `memory/` what should outlive the session: search queries and databases that
worked, quirks of access to resources, the term translations you chose, sources you
have already screened and rejected. That way the next session does not repeat the
same search or reopen the argument about the same term. Secrets never go into memory,
only facts about the work.

---

**In short:** this addendum is an integrity layer on top of the usual rules. Cite
everything and invent nothing; keep the claim apart from the source; record the search
trail; be transparent about method; take care with translation and with
generalisation. The tools for doing so are in `tracks/academic/skills/`,
`tracks/academic/mcp/` and `tracks/academic/runbooks/`.
