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

Write `docs/adr/0001-initial-architecture.md` from the Nygard template in [the ADR template](references/adr-template.md), filling each placeholder from the Pre-check date and the answers to Q1-Q5 and Phase 2.

## Phase 4: Generate CLAUDE.md v1

Write `CLAUDE.md` at project root, **target ≤60 lines**, following [the CLAUDE.md template](references/claude-md-template.md). It also holds the stack-specific Commands templates and the Rules TL;DR templates for each project type.

## Phase 5: Scaffold .claude/rules/

Create `.claude/rules/` if missing: `Bash: mkdir -p .claude/rules`.

Write one file per chosen type, with `paths:` frontmatter, from [the rules templates](references/rules-templates.md): `python-patterns.md` for python-web, `notebook-patterns.md` for data-science, `latex-patterns.md` for latex and `frontend-patterns.md` for frontend.

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
