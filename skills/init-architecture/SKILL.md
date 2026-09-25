---
name: init-architecture
description: Interactive wizard that generates CLAUDE.md v1, ADR-001 (Nygard template), and path-scoped .claude/rules/ for a new project. Asks about project type (python-web / data-science / latex / frontend), stack, and key architectural forks, then writes the scaffold. DO NOT TRIGGER when project already has CLAUDE.md at repo root.
disable-model-invocation: true
allowed-tools: Read Glob Grep Write AskUserQuestion Bash(mkdir:*) Bash(ls:*) Bash(date:*)
argument-hint: [project-name-optional]
---

# /init-architecture — 5-phase project bootstrap wizard

You are an architecture bootstrap assistant. Your job: gather minimum info about the project, then generate `CLAUDE.md v1`, `docs/adr/0001-initial-architecture.md`, and one path-scoped rules file under `.claude/rules/`.

This skill is user-invoked (`disable-model-invocation: true`). Only Claude Code honours that flag; OpenCode and Codex may still start it on their own, so if you are running there and the user did not ask for a project bootstrap, do not run it.

Plans for the new project live in `plans/` at the project root (plan mode output, multi-step plans, wayfinder maps under `plans/wayfinder/<effort>/`); the generated CLAUDE.md names that folder in its Landmarks.

## Pre-check (always run)

1. `Glob: CLAUDE.md` at project root. If already exists, ask via AskUserQuestion: "CLAUDE.md already exists. Rebuild it and related scaffold? (yes will overwrite)". If `no` → exit with message "No changes made."
2. `Glob: docs/adr/*.md`. If any exist, warn user: "Existing ADRs found. The wizard will create 0001; adjust numbering manually if conflict."
3. `Bash: date +%Y-%m-%d` — capture today's date for ADR.

## Phase 1: Gather context

Ask **one AskUserQuestion at a time** (do not batch). Save all answers — you need them in Phases 3-5.

### Q1 — project purpose (open-ended)

Use a 2-option AskUserQuestion with label "Describe in one paragraph" vs "Describe in one sentence" — the user's "Other" free-text answer is what you actually read. Then store the sentence.

Simpler alternative: skip Q1 as AskUserQuestion and just ask in plain text: "What does this project do? (1-2 sentences)" — then wait for reply.

### Q2 — project type (single-select)

Use AskUserQuestion:
- **python-web** — FastAPI / Flask / Django, HTTP API
- **data-science** — Jupyter / pandas / ML experiments
- **latex** — thesis, CV, paper, long-form document
- **frontend** — React / Vue / Svelte SPA or SSR

### Q3 — primary stack (plain text)

"What's the main language/framework? (e.g., FastAPI + SQLAlchemy, Next.js + React, pure Python + pandas, XeLaTeX + biber)"

### Q4 — existing structure (automated + confirm)

Run `Glob: src/ tests/ notebooks/ main.tex package.json pyproject.toml` at project root.

- If empty or only README.md → **green-field**, skip confirm.
- If code exists → AskUserQuestion: "Existing code detected. Integrate scaffold into existing layout (preserve structure) OR only add .claude/CLAUDE.md without touching layout?"

### Q5 — architectural forks (single-select, stack-dependent)

Based on Q2 answer, ask via AskUserQuestion:

**python-web**: "sync or async?" | "monolith or microservices?" (ask two questions sequentially)
**data-science**: "notebook-first (analysis in .ipynb) or src/-modules (reusable code)?"
**latex**: "single-file main.tex or chapter-based (chapters/*.tex)?"
**frontend**: "SPA (client-only) or SSR (Next.js/Nuxt)?"

Save answer(s).

## Phase 2: Type-specific options

Based on Q2, ask 2-3 additional forks via AskUserQuestion (single-select). Save each answer.

### python-web
- **Database**: sqlite / postgres / mysql / none
- **ORM**: SQLAlchemy / Tortoise / raw SQL
- **Auth**: JWT / session / OAuth / none

### data-science
- **Experiments**: Weights & Biases / MLflow / DVC / git-only
- **Environment**: uv / poetry / conda / venv

### latex
- **Engine**: XeLaTeX / pdfLaTeX / LuaLaTeX
- **Bibliography**: biber + biblatex / bibtex

### frontend
- **Framework**: React / Vue / Svelte / Solid
- **Meta-framework**: Next.js / Nuxt / SvelteKit / Vite-only
- **State**: Zustand / Redux / Pinia / TanStack Query / Context

## Phase 3: Generate docs/adr/0001-initial-architecture.md

Create directory if missing: `Bash: mkdir -p docs/adr`.

Write `docs/adr/0001-initial-architecture.md` using Nygard template:

```markdown
# ADR-0001: Initial architecture

**Status:** Accepted
**Date:** <date from Pre-check step 3>

## Context

<purpose from Q1> — a <type from Q2> project built with <stack from Q3>.

<existing-structure note from Q4, 1 sentence>

## Decision

| Area | Choice | Rationale |
|---|---|---|
| Type | <Q2> | <brief reason from user's own words> |
| Primary stack | <Q3> | <brief reason> |
| <Phase-2 area 1> | <choice> | <brief reason> |
| <Phase-2 area 2> | <choice> | <brief reason> |
| <Phase-2 area 3> | <choice> | <brief reason> |
| <Q5 fork> | <choice> | <brief reason> |

## Consequences

### Positive
- <2-3 bullets inferred from choices>

### Negative
- <1-2 bullets — trade-offs of the choices>

### Open questions
- <1-2 bullets — things not decided yet that may require future ADRs>
```

## Phase 4: Generate CLAUDE.md v1

Write `CLAUDE.md` at project root, **target ≤60 lines**, Karpathy-inspired structure:

```markdown
# <Project name — infer from dir name or ask>

<One-line purpose from Q1, stripped to essentials.>

Stack: <Q3>. <Key Phase-2 choices summarized, one line>.

---

## Core principles

- State assumptions. Push back when warranted. Ask when unclear.
- Minimum code. No speculative features. No abstractions for single-use.
- Surgical changes — touch only what's required.
- Define success criteria. Verify before done.

## Landmarks

<Detect or infer from Q2/Q3. Examples below.>

- Entry: <path — e.g., src/main.py for python-web, main.tex for latex>
- Schemas: <if applicable>
- DB: <if applicable>
- Tests: <if applicable>
- Docs: CONTEXT.md (domain lexicon), docs/ (per-area), docs/adr/ (decisions)
- ADRs: docs/adr/
- Plans: plans/ (plan mode output and multi-step plans; wayfinder maps in plans/wayfinder/<effort>/)

> Durable docs (CONTEXT.md, docs/*.md) carry a `<!-- doc-meta: Updated/Covers/Source-rev/Status -->`
> freshness header, so an agent can tell whether a doc is sworn against current code. Prime from these
> docs before reading code.

## Commands

<4-6 stack-specific commands from the template table below>

## Rules (TL;DR)

<2-4 bullets specific to the stack — use template below>

## Architecture Decisions

- ADR-001 → docs/adr/0001-initial-architecture.md
```

### Commands template by type

**python-web (FastAPI + uv)**:
```
uv run uvicorn src.main:app --reload    # dev
uv run pytest tests/ -v                  # tests
ruff format src/ && ruff check src/      # lint
```

**data-science (uv)**:
```
uv run jupyter lab                       # notebooks
uv run pytest tests/                     # tests
uv run python -m src.pipeline            # run pipeline
```

**latex (XeLaTeX + biber)**:
```
latexmk -xelatex main.tex                # build PDF (auto biber)
latexmk -c                               # clean aux files
```

**frontend (Next.js + npm)**:
```
npm run dev                              # dev server
npm run build                            # production build
npm test                                 # tests
```

Adjust command names if user picked different tools (poetry instead of uv, pnpm instead of npm, pdflatex instead of xelatex).

### Rules TL;DR templates

**python-web**: "Async everywhere (httpx, aiosqlite). Pydantic v2 for schemas. Absolute imports from src."
**data-science**: "Seed control at top. Long experiments in .py, not notebooks. No side effects on import."
**latex**: "Engine: <Q2-engine>. Biber before final PDF. figures/ for assets, chapters/ for .tex inputs."
**frontend**: "One component per file. State: <Phase-2 state>. Commit generated output rarely."

## Phase 5: Scaffold .claude/rules/

Create `.claude/rules/` if missing: `Bash: mkdir -p .claude/rules`.

Write one file per chosen type, with `paths:` frontmatter:

### python-web → `.claude/rules/python-patterns.md`

```markdown
---
paths: ["src/**/*.py", "tests/**/*.py"]
---

# Python patterns

- Async everywhere — httpx.AsyncClient, aiosqlite, ARQ. No requests/sqlite3 sync.
- Pydantic v2 for all schemas in src/schemas/. Frozen dataclasses for agent results.
- Absolute imports from src.: `from src.X import Y`. No relative imports.
- Error handling at system boundaries (FastAPI routes, external API calls) only. Trust internal code.
- Module-level docstrings required: role + links to specs.
- Changed a public interface here → update its owning doc (CONTEXT.md / docs/) in the same change; refresh the doc's `doc-meta` Source-rev. Stale docs are correctness bugs.
```

### data-science → `.claude/rules/notebook-patterns.md`

```markdown
---
paths: ["notebooks/**/*.ipynb", "src/**/*.py"]
---

# Notebook patterns

- Seed control: `np.random.seed(42)` + `torch.manual_seed(42)` at top of every notebook/script that randomizes.
- Long experiments → .py scripts in src/, not notebooks. Notebooks for exploration only.
- No side effects on import (data loading, model loading). Use functions called explicitly.
- Results to data/processed/ or outputs/ — both gitignored.
- Env: <from Phase 2>. Lock file committed, virtual env not.
- Changed a pipeline interface or data contract → update its doc (CONTEXT.md / docs/) in the same change; refresh the doc's `doc-meta` Source-rev. Stale docs are correctness bugs.
```

### latex → `.claude/rules/latex-patterns.md`

```markdown
---
paths: ["**/*.tex", "**/*.bib"]
---

# LaTeX patterns

- Engine: <from Phase 2>. Set magic comment `% !TEX program = <engine>` at top of main.tex.
- Bibliography: <from Phase 2>. Run bib tool before final PDF. latexmk handles this automatically.
- Assets: figures/ for .pdf/.png/.jpg. diagrams/ for .tex inputs (TikZ, PGF).
- Compilation sequence (if not using latexmk): <engine> → <bib-tool> → <engine> → <engine>.
- Don't edit .aux, .log, .bbl — regenerated each build.
- Restructured chapters or changed the build → update the docs/README describing structure in the same change; refresh its `doc-meta` Source-rev.
```

### frontend → `.claude/rules/frontend-patterns.md`

```markdown
---
paths: ["src/**/*.{ts,tsx,js,jsx,vue,svelte}"]
---

# Frontend patterns

- Framework: <from Phase 2>. <Meta-framework from Phase 2>.
- State: <from Phase 2>. Use local state first; lift to global only when shared.
- Component convention: one component per file, `ComponentName.<ext>`. Colocate tests.
- Styles: <ask or default: Tailwind v4 / CSS modules>. Avoid inline styles.
- Bundle size: check via `npm run build --analyze` before landing large deps.
- Changed a component's public props/contract → update its owning doc (CONTEXT.md / docs/) in the same change; refresh the doc's `doc-meta` Source-rev. Stale docs are correctness bugs.
```

## Phase 6: Verify and summarize

Report to user:

```
✓ Created files:
  - CLAUDE.md (<N> lines)
  - docs/adr/0001-initial-architecture.md (<N> lines)
  - .claude/rules/<stack>-patterns.md (<N> lines)

Next steps:
  1. Review CLAUDE.md — adjust to taste (Landmarks paths especially).
  2. Commit baseline:
       git init  # if not already a repo
       git add .
       git commit -m "chore: init project architecture"
  3. When making your next architectural decision, create ADR-002.
  4. Use `architect` agent for design consultation on new features.
```

## Rules for this skill

- **Generate ONLY** the 3 files listed (CLAUDE.md, ADR-001, one rules file). Nothing else.
- **Use `mkdir -p`** (idempotent) for directory creation.
- **No code generation** — don't write src/ files, don't init package.json, don't install dependencies.
- **No git commands** — suggest them in Phase 6, don't execute.
- **Consistency**: ADR-001 decisions table must match CLAUDE.md Commands/Rules TL;DR selections.
- **On ambiguity**: ask user, don't assume. A quick clarifying question beats a wrong file.
- **Exit after Phase 6** — do not volunteer to start implementing the project.
