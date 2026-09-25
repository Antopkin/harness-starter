# Academic overlay: working with sources

> **For the human (read these three lines and you are done).**
> This is the academic overlay for working with sources; it sits **on top of** the base harness.
> The base lives in the root of this same repository. Install it first (in the root, tell your agent:
> "read INSTALL.md and set up the harness for my tool"), and then, still in the root, say:
> **"read tracks/academic/README.md and add the academic overlay"**. The agent does the rest.

---

## From here on: instructions for the agent

You are a coding agent (Claude Code, OpenCode or Codex). You have been asked to "add the
academic layer". The overlay lives in `tracks/academic/` of this repository; the base
(`harness-starter`) lives in its root, and the root is your working folder: every command
below is run from the root. This is an **add-on** to the base harness you have already
installed: it does not replace the base rules and skills, it adds one layer on top of them,
**source discipline**, plus the skills, MCP servers and runbooks that serve that layer.

Work in small steps. Before you copy or edit anything, show the user a one- or two-line
plan. Do not touch anything outside the working folder without asking. Secrets and other
people's keys are neither read nor committed (the rule from the base `AGENTS.md` applies).

### Step 0. Look around: what the overlay contains

```
tracks/academic/           ← the overlay inside the base harness repository
├── README.md              ← this file (how to install the overlay)
├── AGENTS.academic.md     ← rules addendum: source integrity, method, reproducibility
├── skills/                ← 12 academic skills, one folder each: skills/<name>/SKILL.md
│   └── shared/            ← shared files, not a skill: transcript-io.md (input for transcript-*)
│                            and handoff_schemas.md (data contracts of the paper pipeline)
├── mcp/
│   ├── README.md          ← how to connect two MCP servers (paper search + Zotero)
│   └── .mcp.json.example  ← config template with placeholders instead of keys
└── runbooks/              ← step-by-step recipes for source work
    ├── lit-review.md      ← a literature review from question to bibliography
    ├── eresources.md      ← paywalled e-resources and your university library via the browser
    ├── rag.md             ← questions to your own PDF folder, answered with page references
    └── zotero.md          ← search, notes and annotations in your own Zotero library
```

If a file from this list is missing, do not invent it: tell the user what is missing and
carry on with what is there.

### Step 1. Make sure the base harness is already installed

The overlay relies on the base, which lives in the root of this same repository. Check that
the root has `AGENTS.md` (the single rule set of the base) and, for Claude Code, a `CLAUDE.md`
with the line `@AGENTS.md`, and that the base skills have been laid out following the steps
of the root `INSTALL.md`.

- **If the base is not set up yet** (skills not laid out, `CLAUDE.md` not wired) — stop and
  ask the user to **install the base first** (in the repository root, tell the agent: "read
  INSTALL.md and set up the harness for my tool"). Without the base there is nothing to put
  the academic layer on. Wait for the base and come back to step 2.
- **If the base is in place** — carry on.

### Step 2. Wire in the overlay rules (`AGENTS.academic.md`)

The addendum `tracks/academic/AGENTS.academic.md` is read **together with** the base
`AGENTS.md`, not instead of it. Import it **in place**; do not copy it into the root. A copy
drifts away from the overlay, and every path inside the addendum is written relative to the
repository root, so it only resolves from where it already lives. Depending on the tool:

- **Claude Code** does not read rule files other than `CLAUDE.md` on its own. Add the line
  `@tracks/academic/AGENTS.academic.md` to the root `CLAUDE.md`, right below the line
  `@AGENTS.md`. The addendum is then loaded together with the base rules. You can check what
  actually loaded with the `/memory` command.
- **OpenCode and Codex** read the root `AGENTS.md` **natively** but follow no imports. Add a
  short pointer line at the end of the base `AGENTS.md`, for example:
  `> For academic work, read tracks/academic/AGENTS.academic.md together with this file.`

### Step 3. Wire in the academic skills

The overlay skills live in `tracks/academic/skills/<name>/SKILL.md`. Each one has a `name` in
its frontmatter (matching the folder name) and a `description` (which the tool uses to decide
when to apply the skill); all our skills already have both. Next to a skill you may find
`references/`, `templates/` or `agents/`: these are its materials and part of the skill; do
not throw them away.

To make the skills work in **all three** tools, lay them out in two places: `.claude/skills/`
(Claude Code) and `.agents/skills/` (Codex). OpenCode needs no copy of its own: it reads the
compatible paths and picks up either of the two.

```
mkdir -p .claude/skills && cp -R tracks/academic/skills/. .claude/skills/
mkdir -p .agents/skills && cp -R tracks/academic/skills/. .agents/skills/
```

Copying **adds to** the base skills already installed; it does not overwrite them. How they
are invoked:

- **Claude Code** — by name with `/` (`/deep-research`, `/paper-audit`, …) or automatically
  from the `description`. Caveat: if the `.claude/skills/` folder did not exist when the session
  started, Claude Code only notices the new skills after a restart.
- **OpenCode** — shows the agent the list of skills with their `description` through the
  built-in `skill` tool and calls the one that fits the task by itself (not through `/`).
- **Codex** — picks a skill by matching the task against the `description`; the list and
  manual choice are available through the `/skills` slash command.

A skill marked user-invoked (`disable-model-invocation: true` in its frontmatter) stays manual
only in Claude Code; OpenCode and Codex ignore that key and may still invoke such a skill on
their own.

**If a skill is not picked up** (an old build of the tool), degrade gracefully: open the
relevant `tracks/academic/skills/<name>/SKILL.md` and follow its steps by hand. Integrity comes
from the rules in `AGENTS.academic.md`, not from the tooling; the skills only speed things up
and standardise them.

### Step 4. Set up the two MCP servers

The overlay connects two external tools: **`paper-search`** (searching and downloading
research papers across dozens of databases) and **`zotero`** (the user's own library). The
full step-by-step guide and where to get keys are in **`tracks/academic/mcp/README.md`**; a
ready config template is **`tracks/academic/mcp/.mcp.json.example`**.

In short: install `uv` (to run the servers), copy the template into the root as `.mcp.json`
(`cp tracks/academic/mcp/.mcp.json.example .mcp.json`) and replace `YOUR_..._KEY` /
`YOUR_..._ID` in it with the user's **own** keys. Leave the keys as **placeholders**: the user
fills them in personally; never write a real key into `.mcp.json.example` and never commit
`.mcp.json` to git. Most `paper-search` databases need no key at all. For details, Zotero's
local mode and how to check the connection, see `tracks/academic/mcp/README.md`.

### Step 5. Show where the runbooks are

Tell the user that `tracks/academic/runbooks/` holds step-by-step recipes for source work;
each step can be handed to the agent almost verbatim:

- `runbooks/lit-review.md` — a literature review: question → search → screening → PDF →
  digest → synthesis → references → saving to Zotero.
- `runbooks/eresources.md` — access to paywalled resources and your university library
  through the browser, within the legal frame.
- `runbooks/rag.md` — questions to your own PDF folder (`materials/`), answered with page
  references.
- `runbooks/zotero.md` — search, save notes and annotate in your own library through the agent.

### Step 6. Explain to the user what has been added

Briefly and without jargon, tell the user roughly the following (in your own words):

- The rules are now stricter about sources: **cite everything, invent nothing**, keep "what
  is said" apart from "where it comes from", record the search trail (the rules are in
  `AGENTS.academic.md`).
- Larger skills have arrived: **`deep-research`** (rigorous research on a question: systematic
  review, meta-analysis, fact-check), **`academic-paper`** (writing the paper itself),
  **`academic-paper-reviewer`** and **`paper-audit`** (running a draft past "reviewers" and
  checking its integrity), **`academic-pipeline`** (all of these as one run), the **`latex-*`**
  family (LaTeX documents and papers) and the **`transcript-*`** family (interview transcripts,
  where speech is data).
- The agent can now **search for papers across dozens of research databases** and **work with
  your Zotero library**, through two MCP servers (once you fill in the keys).
- Work with PDFs and quotes and the literature review are laid out as recipes in
  `tracks/academic/runbooks/`.
- In one sentence: **"the academic overlay is on"** — the agent keeps source discipline, can
  research, write and review, searches the databases and remembers your library.

---

## Overlay skills

| Skill | What it is for | When to call it |
|---|---|---|
| `deep-research` | Rigorous research on a question: systematic review, meta-analysis, fact-check, synthesis of many sources | A big research question that needs a protocol and a literature review |
| `academic-paper` | Writing the paper itself (IMRaD, review, case study, policy brief), citations, bilingual abstract | The material is gathered and it is time to write |
| `academic-paper-reviewer` | Simulated peer review: several independent reviewers plus an editorial decision | Before submission, to run the draft past "reviewers" |
| `paper-audit` | Integrity audit: claims without a source, invented quotes, banned phrasing | Checking the honesty of a finished text before you hand it in |
| `academic-pipeline` | Orchestrates the full pipeline: research → write → integrity check → review → revise → re-review → finalize | You want to take a paper through every stage in one run instead of chaining the steps by hand |
| `transcript-verbatim` | Verbatim correction of ASR output: fix recognition errors only, keep the speech word for word | Transcripts of interviews or focus groups where **speech is data** |
| `transcript-polish` | Readable, coherent prose from spoken language that keeps meaning and intent | A transcript has to become readable for analysis |
| `transcript-docs` | A business document from a call: agreements, action items, deadlines and risks, each with a timecoded quote | You need minutes or a record of what was agreed |
| `latex-document` | General LaTeX work: create and compile documents, convert to and from PDF, OCR of scanned PDFs, diagrams, latexdiff | Any `.tex` work or pdflatex/xelatex compilation |
| `latex-fix` | Fixes LaTeX compilation errors by analysing the log file | A `.tex` file will not build: compile errors, missing packages, a broken bibliography |
| `latex-paper-en` | Assistant for a finished English LaTeX paper: compilation, grammar, bibliography, translation, experiment sections | An English paper for IEEE/ACM/Springer/NeurIPS/ICML |
| `latex-proofread` | Two-phase proofreading of a LaTeX paper: infrastructure (preamble, macros, cross-refs, citations, figures) plus content (grammar, clarity, narrative) | The final read before submitting to a venue such as ICRA/RSS/NeurIPS/T-RO/CVPR |

The backbone of literature work, the `lit-search` skill (search and first overview) and the
`digest` skill (a source-anchored digest of a paper that ends with a formatted reference and a
BibTeX entry), already comes with the base harness; the overlay adds the larger skills. Each
skill is a folder `tracks/academic/skills/<name>/` with a `SKILL.md`; open any `SKILL.md` to
see what it does and which triggers fire it. The `transcript-*` family relies on the shared
file `skills/shared/transcript-io.md`, and the paper pipeline on `skills/shared/handoff_schemas.md`
(both are copied together with the skills).

## Where to go next

- `AGENTS.academic.md` — the rules of source integrity and method: six rules on how to
  handle sources, data and conclusions.
- `tracks/academic/mcp/README.md` — connecting the two MCP servers and where to get keys.
- `tracks/academic/runbooks/` — recipes for frequent operations (literature review,
  e-resources, RAG over PDFs, Zotero).
