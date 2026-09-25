# Path-scoped rules templates (Phase 5)

Write one file per chosen type, with `paths:` frontmatter:

## python-web → `.claude/rules/python-patterns.md`

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

## data-science → `.claude/rules/notebook-patterns.md`

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

## latex → `.claude/rules/latex-patterns.md`

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

## frontend → `.claude/rules/frontend-patterns.md`

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
