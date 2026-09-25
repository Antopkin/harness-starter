# CLAUDE.md v1 template (Phase 4)

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

## Commands template by type

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

## Rules TL;DR templates

**python-web**: "Async everywhere (httpx, aiosqlite). Pydantic v2 for schemas. Absolute imports from src."
**data-science**: "Seed control at top. Long experiments in .py, not notebooks. No side effects on import."
**latex**: "Engine: <Q2-engine>. Biber before final PDF. figures/ for assets, chapters/ for .tex inputs."
**frontend**: "One component per file. State: <Phase-2 state>. Commit generated output rarely."
