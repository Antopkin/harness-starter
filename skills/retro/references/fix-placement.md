# Where a fix belongs

Read this when a retro proposal needs a home and it is not obvious which file or mechanism should carry it.

## Implementation versus review

Work goes through two stages, implementation and review. The implementing agent carries the most **context pressure**: it explores, writes code and debugs failures, and every always-loaded line competes with that work.

The reviewing agent carries the least. It receives a diff, so it explores little and rarely debugs. That makes the reviewer, not the implementer, the right carrier for coding standards. A standard written into the implementer's always-loaded file costs tokens on every turn of every session; the same standard given to the reviewer costs them once per review.

## Mechanical or judgement

Classify each violation before placing its fix.

- A **mechanical** violation has a fixed shape: a syntactic pattern, a banned API or command, an import form, a file in the wrong place. It gets a deterministic check, full stop: a custom rule in the repo's own linter, a pre-commit or tool hook, a test, or a CI job, whichever the repo's language and existing guardrails make cheapest. Default to building the check over writing the rule.
- A **judgement call** has no fixed shape: consistency across files, "matches the surrounding style", a design trade-off. No check can substitute for it, so it becomes a reviewer rule.

## Which file holds what

- `CLAUDE.md` / `AGENTS.md`: pushed into the context of every agent in the repo (or in every repo, for the global one). Use them sparingly, mostly for **navigation pointers** to other files. Steering that lives here and could be a check or a reviewer rule should move.
- Reviewer rules (a `CODING_STANDARDS.md`, a review skill, or the reviewer agent's own prompt): read during review, not implementation. When the standards file grows past about a thousand lines, split it into docs and leave pointers.
- Docs and reference files: loaded on demand, reached through a pointer from another file. Look for an existing doc before writing a new one.
- Memory in `memory/`: facts that matter across sessions, such as a decision nobody wrote down or where a service's logs live, indexed from its `MEMORY.md`. Use it for missing information that has no better home in a doc.
- Skills: their description sits in every context, so use them for knowledge an agent must be able to find, or for commands the user runs.
- Hooks, tests, linters, CI jobs: the home of every mechanical fix. A hook that already exists but is not wired in the settings, or a CI job that silently passes, is a finding in its own right.

Adapted from mattpocock/skills@c55ee46 in-progress/retro (MIT).
