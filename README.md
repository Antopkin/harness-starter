# harness-starter: a starter harness for coding agents

Install jq first (brew install jq / apt install jq). The guards that protect your secrets and your git history parse their input with jq, and without it they refuse to run. The `fill-form` skill also needs the agent-browser CLI and a Chrome started with `--remote-debugging-port=9222`.

A harness is what turns a coding agent from a chatbot into a disciplined worker. It consists of four things: **rules** (how to behave), **skills** (ready-made procedures for frequent tasks), **agent roles** (focused subagents the main session can delegate to) and **memory** (facts that survive session restarts), with **guards** that enforce the most important rules. This repository is a ready starter set of all of them, working in **Claude Code, OpenCode and Codex** from a single file layout.

It suits anyone who is starting to work with coding agents: clone it and the harness is at hand.

> **For the agent.** If you were asked to "set up the harness", open `INSTALL.md` and follow it.

## Quick start

```
git clone https://github.com/Antopkin/harness-starter
cd harness-starter
```

1. Open your agent in this folder: Claude Code, OpenCode or Codex.
2. Tell it: **"read INSTALL.md and set up the harness for my tool"**.
3. The agent works out which tool it runs in, puts the rules, skills, agent roles and guards where that tool expects them, and explains what it did.
4. Check the installation with the first exercise in `hello.md`; it takes a couple of minutes.

## What's inside

| What | Where | Why |
|---|---|---|
| Rules | `AGENTS.md` (plus the `CLAUDE.md` wrapper) | One rule set: think before coding, change only what was asked, prove the result, ask before merging, keep secrets out |
| Contexts | `contexts/` (six files) | Rules read on demand: plans and orchestration, git workflow, guards, research routing, writing quality |
| Skills | `skills/`: 38 base skills | Ready-made procedures for frequent tasks, listed below |
| Agent roles | `agents/`: 21 agent roles | Subagents for reading, reviewing, editing, research and engineering specialities |
| Guards | `hooks/` and `.claude/settings.json` | Block edits to secret files, destructive commands and pasted keys; keep the Read and Grep tools away from `.env*` files (except `.env.example` and `.env.sample`) and the Claude credential store, in Claude Code and through the bridge in OpenCode (a shell `cat` of an `.env` file is not guarded) |
| Memory | `memory/MEMORY.md` | Index of the facts the agent remembers between sessions, with an example note |
| Installer | `INSTALL.md` | Step-by-step instructions for the agent itself |
| First exercise | `hello.md` | A one-minute check that everything is connected |
| Recipes | `runbooks.md` | Frequent operations: reading a web resource, rolling back an edit, adding your own skill |
| Tracks | `tracks/` | Overlays for a field of work; currently one, academic, with 12 academic skills |

### The base skills

- **Code:** `review` (two-axis review of a diff), `test` (pytest tests), `tdd` (Red-Green-Refactor), `diagnose` (debugging hard bugs), `explain` (explaining code), `triage-issue` (root cause and an issue with a TDD fix plan), `improve-codebase-architecture` (deepening opportunities), `zoom-out` (a higher-level map of the code), `code-documenter` (docstrings and API docs), `init-architecture` (a starting rule set and first ADR for a new project), `safe-reader` (read-only exploration).
- **Writing:** `ru-text` (Russian typography and editing), `writing-guru` (narrative strategy), `style-extract` (an author's style profile), `writing-fragments` (exploring a text before it has a structure; experimental), `doc-coauthoring` (co-writing documentation and specs), `mckinsey` (issue trees, market sizing, push-back in the Big-3 manner), `mck-summary` (a pyramid executive summary of finished material), `canvas-design` (posters and static visual pieces).
- **Sources:** `lit-search` (literature search), `digest` (a source-anchored digest of a paper with a reference entry), `write-from-digests` (a memo built only from finished digests), `web-parse` (structured capture from an already signed-in web session), `fill-form` (filling a web form with read-back checks and a human gate before submitting).
- **Git hygiene:** `git-finalize` (commit, push, pull request, one CI check, stop before merge), `git-clean-gone` (remove local `[gone]` branches and their worktrees), `git-worktree-status` (a read-only survey of worktrees and branches with a CI column).
- **Planning and thinking:** `grill-me` (an interview about a plan until you share an understanding), `grill-with-docs` (the same, checked against CONTEXT.md and ADRs), `wayfinder` (a map of decision tickets for work too big for one session), `to-questionnaire` (open questions turned into a questionnaire for one recipient).
- **Work cycle:** `handoff` (a compact handoff to the next session), `pickup` (resuming from the latest handoff), `retro` (a retrospective that proposes cheap durable fixes; experimental), `wizard` (a bash wizard for steps only you may perform, such as entering credentials).
- **Meta:** `skill-creator` (create and test your own skill), `find-skills` (discover and install published skills), `claude-automation-recommender` (recommend Claude Code automations for a codebase).

Skills marked user-invoked run only when you call them, and that holds only in Claude Code; OpenCode and Codex may still start them on their own. The full table with triggers is in `INSTALL.md`, section "Skills in the starter".

### Russian-language tools

Most of the kit is in English, but a few tools deal with Russian. `ru-text` is written in Russian and checks Russian text. The `transcript-*` skills of the academic track work in any language and answer in the language of the recording. `contexts/writing-quality.md` keeps an English and a Russian lexicon of weak phrasing.

## Tool matrix

The rules and skills are the same for every tool; only the file layout differs, and the agent sets it up from `INSTALL.md`:

| Tool | Rules | Skills (folder) | Agent roles | Guards | Calling a skill |
|---|---|---|---|---|---|
| **Claude Code** | `CLAUDE.md` → the line `@AGENTS.md` | `.claude/skills/` | `.claude/agents/` | hooks in `.claude/settings.json` | `/name` or automatic pick-up by description |
| **OpenCode** | `AGENTS.md` natively | reads `.claude/skills/` and `.agents/skills/`, so no copy of its own is needed | synced into `.opencode/agent/` | the guard bridge plugin, with known gaps | the built-in `skill` tool |
| **Codex** | `AGENTS.md` natively | `.agents/skills/` | a role file read as a persona | this starter does not wire Codex hooks yet; the rules apply as AGENTS.md prose | automatic pick-up plus the `/skills` list |

## Tracks

**[`tracks/academic/`](tracks/academic/README.md)** is an academic overlay on top of the base: an addendum of source-integrity rules (`AGENTS.academic.md`), 12 academic skills for research, paper writing, simulated peer review, integrity audits, LaTeX and transcripts, two MCP servers (paper search across dozens of scholarly databases and a personal Zotero library) and step-by-step recipes in `runbooks/`.

Installation: first the base (see the quick start), then tell the agent at the repository root: **"read tracks/academic/README.md and add the academic overlay"**. The addendum is imported in place, not copied to the root: in Claude Code add the line `@tracks/academic/AGENTS.academic.md` to `CLAUDE.md`; in OpenCode and Codex add to `AGENTS.md` a line telling the agent to read `tracks/academic/AGENTS.academic.md` for academic work.

## Licence and attribution

Licence: the original parts are MIT, Copyright © 2026 Oleg Antopkin ([LICENSE](LICENSE)); four academic skills (`academic-paper`, `academic-paper-reviewer`, `academic-pipeline`, `deep-research`) and their shared `tracks/academic/skills/shared/handoff_schemas.md` are CC BY-NC 4.0; `paper-audit` and `latex-paper-en` are "Academic Use Only" per their author; every third-party item, its author and its licence are listed in [CREDITS.md](CREDITS.md). Third-party items keep their own licences (see [CREDITS.md](CREDITS.md)).
