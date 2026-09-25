# Orchestration matrix

Read this when a task arrives and you have to decide what runs it — a shell utility, the main session itself, or a wave of subagents — and which model each part gets. This file is the single home of the parallelism numbers and of the model-tiering formula; the other instruction files point here instead of restating them.

The model names below (sonnet for the cheap tier, opus for the strong one) are Claude's. In OpenCode or Codex, read them as "the cheapest adequate model" and "the strongest model you have".

## Quick decision tree

```
New task
├─ Solvable with grep, awk, sed or jq?
│    → the shell. No model, no agent: exact, free, milliseconds.
├─ Research, search, corpus reading? → `reader` or `shell-reader` on
│  sonnet, 3-5 agents, one source each
├─ Bulk of similar items on one recipe? → prefilter in code first, then
│  agents at roughly 60 items each, 15-18 per round, sync barrier
├─ Code change over more than three files? → file-disjoint partition,
│  one agent per part, 5-10 per wave
├─ Architectural decision? → 3-7 Plan agents, one perspective each
├─ Audit of a finished artefact? → code: 4-5 read-only reviewers;
│  text: /academic-paper-reviewer then /paper-audit
├─ Academic reading, or an argument to develop? → research-analyst and
│  the academic skills; "read it and think" stays in main
├─ Long Russian or LaTeX deliverable? → sequential chain of skills
└─ One small connected edit? → main does it itself
```

## Lookup table

| Pattern | Subagents | Skills | Width | Notes |
|---|---|---|---|---|
| Research, exploration, corpus mining | `reader` or `shell-reader` x 3-5 on sonnet, research-analyst | `/deep-research` (academic track) when the sources are external | 3-5 | partition by source |
| Academic research, literature review | research-analyst x 2-3, `reader` | `/lit-search`, `/deep-research` | 2-3 | partition by topic or source |
| Reading a text and developing ideas from it | main itself; one `reader` when the corpus is large | `/writing-guru` for narrative | sequential | reasoning belongs in main, not in technical agents |
| Writing an academic paper | — | `/academic-paper`, end to end `/academic-pipeline` | sequential | structure, citations, bilingual abstracts |
| Reviewing an academic text | research-analyst for facts | `/academic-paper-reviewer` then `/paper-audit` | sequential | not code-reviewer or architect |
| Bulk per-item processing | a `reader` or a specialist per batch | — | 15-18 per round | prefilter first, sync barrier between rounds |
| Code audit or hardening wave | architect, code-reviewer, silent-failure-hunter, security-engineer | `/review` | 4-5 | read-only prompts |
| Bug investigation | `shell-reader` x 1-2 on sonnet, silent-failure-hunter | `/diagnose` | 2-3 | reproduce before fixing |
| Strategic or business question | general-purpose reasoning, recommendation first | offer `/mckinsey` to the user; never invoke it silently | sequential, plus a devil's advocate | conclusion first, then the reasoning |
| Plan-mode design | Plan x 3-7 | `/grill-me` on the drafts | 3-7 | one perspective or hypothesis each |
| Technical plan audit | architect, silent-failure-hunter, code-reviewer, prompt-engineer, a general-purpose spec checker, a clean-room reader as the built-in `Plan` agent (always present), and a devil's advocate above 200 lines | — | 3-7 | cast and gate are settled in `workflow-orchestration.md`; each reviewer writes its report to the path the orchestrator assigns |
| Academic or written plan audit | research-analyst, a devil's advocate | `/academic-paper-reviewer`, `/paper-audit` | sequential | no technical reviewers |
| Russian deliverable | — | `/writing-guru` then `/ru-text` | sequential | chain |
| LaTeX document | — | `/latex-document`, `/latex-proofread`, `/latex-fix` | sequential | compile loop |
| Refactor or architecture change | architect, code-reviewer, python-pro or postgres-pro | `/improve-codebase-architecture` | 3 read-only, then execute | design, then implementation |
| Subagent-heavy implementation | one specialist per file-disjoint part | `/tdd` | 5-10 with `isolation: "worktree"` | one task, one agent |
| Documentation | documentation-engineer, prompt-engineer | `/code-documenter` or `/doc-coauthoring` | 2 | interface reference or guide |
| Security audit | security-engineer, silent-failure-hunter, architect | — | 3-5 | read-only prompts |
| Schema, migration, database | postgres-pro, data-engineer, silent-failure-hunter | — | 3 for design, 1 to execute | the executing step is gated |
| Verification after implementation | code-reviewer, data-engineer for the data side | — | 2 | binary gates with exact commands |
| Handoff between sessions | — | `/handoff`, typed by the user; `/pickup` in the next session | sequential | the file is carried over by hand |

The academic skills (`/lit-search` aside) live in the academic track and are only there if you installed it.

## How wide a wave should be

There are two modes, and they behave differently. In an engineering wave — code, review, research, design — do not economise, but let the width be the number of genuinely independent, file-disjoint pieces of work rather than an ambition: a task with three parts is three agents, not ten, and reading one file is a `Read`, not an agent. In bulk classification of similar items, run a cheap deterministic filter in code first and give the agents only the remainder, at roughly sixty items per agent.

The numbers, in one place: research and reconnaissance 3-5 in parallel; bulk per-item processing 15-18 per round with a sync barrier between rounds; design in plan mode 3-7; code waves 5-10 over disjoint files, with `isolation: "worktree"` in project repositories; audits 4-5; bulk classification about 60 items per agent after the prefilter. Treat them as guidelines, not ceilings, and reconsider them when the model generation changes.

Subagents plus context engineering are the first bet on any sizeable task: each agent gets its own context, and main keeps its own for synthesis and for the decisions the user has to see. Give every agent a tight, self-contained prompt — one sentence of context, concrete actions, the paths it must not touch, a structured return format and a word cap — because an agent has no memory of the session and drifts into long prose without one. Parallelism is for implementation as much as for research. Main is the brain, not the hands: delegate edits, shell work, investigation chains and verification runs, and continue an agent that is already alive through a message to it rather than redoing its work yourself.

## Fresh agents or a fork

In Claude Code, a subagent of type `fork` starts from the current conversation and inherits its prompt cache, so it is cheap to launch and already knows what has happened. Use it for a follow-up on work the session has just done and for an adversarial re-check that needs the session's own context. Use a fresh agent when the work is isolated and file-disjoint: a clean context is the point, and the session's history would only be noise. The built-in Explore and Plan agents do not inherit the always-on instruction file, so brief them completely — which is also what makes Plan the right reader for a clean-room review of a plan.

## When not to parallelise

Two agents editing one file collide, so a file has exactly one owner. A step that consumes the output of the previous one runs after it, or the second agent guesses and the work is redone. A single chain of reasoning — an issue tree, a diagnostic loop — breaks when it is split across agents. A task for one specialist, or a change that touches the frontmatter, the body and a table of the same file, costs more in coordination than it saves.

## After a wave

Wait for every agent before launching the next wave; a sync barrier is not optional. Check before starting that each file has one owner. Ask each agent for a structured return — verdict, files, differences, errors — rather than free prose, and cap it at 500 to 1500 words so the results do not flood main.

## Concurrency and cost

Cost grows roughly linearly with the number of agents, and a subagent-heavy session spends on the order of seven times what a single-threaded one does. What an agent costs before it has done anything depends on its type. An audit of 30 days of Claude Code transcripts on one working harness gave these tokens for the first API call:

| Agent type | First-call tokens |
|---|---|
| default Workflow type, CLI | ~29K |
| default Workflow type, Desktop | 43-55K |
| Explore | ~26K |
| Plan | ~23K |
| restricted-tools roles | 13-16K |
| lean types (one-line prompt) | 4.9-9.0K; `reviewer`, which keeps the always-on instruction file, 12.1K |

The difference is what the agent is handed at startup. A type whose `tools:` list leaves out Skill, ToolSearch, Agent and `mcp__` tools gets no skill listing, no deferred MCP tool names, no agent roster and no tool schemas. In that audit the default Workflow type, the most expensive row, made 78 % of all spawns. Agents in one wave do not share a prompt cache — the claim was checked and refuted — so each of them pays its own startup.

Three is the point of saturation for agents reasoning over the same single task; a file-disjoint wave is bounded by the number of disjoint parts, not by that figure. Agents do not nest — delegation is one level deep. Anything requested beyond what the harness runs at once queues safely. For scale, a recorded anti-case is 49 agents burning 887 thousand tokens in a minute.

## Agent types

Every dispatch — in Claude Code, every Workflow `agent()` call with its `agentType` — names one of the five lean types defined in `agents/` or a restricted role whose `tools:` list leaves out Skill, ToolSearch, Agent and `mcp__` tools. The lean types are these:

- `reader` — Read, Grep and Glob on sonnet, for reading waves and reconnaissance.
- `shell-reader` — the same with Bash added, on sonnet, when the reading needs `git log`, a script or a command's output.
- `web-reader` — web fetch and search on sonnet.
- `editor` — Read, Edit, Write, Glob, Grep and Bash, on sonnet by default; pass `model: 'opus'` when it edits instruction files.
- `reviewer` — Read, Grep, Glob and Bash on opus, and it keeps the always-on instruction file, because its verdicts are judged against your rules.

All of them except `reviewer` carry `omitClaudeMd: true`, a Claude Code frontmatter key that drops CLAUDE.md — and with it `AGENTS.md`, which CLAUDE.md imports, and the instruction to read `memory/MEMORY.md` — from their context. Whatever such an agent must honour therefore travels in its prompt. The `tools:` and `model:` keys are Claude Code mechanics as well; for OpenCode, `../hooks/opencode-agents-sync.py` translates them (see `hooks-overview.md`).

Reading waves go to `reader` or `shell-reader` on sonnet, not to Explore, which starts at about twice the tokens and carries a skill listing and MCP tool names it never uses. Explore, Plan, the default Workflow type and `general-purpose` are allowed only as a named exception, with the reason written in a comment beside the call in the script: the phase needs skills, MCP tools or nested agents, or it needs the clean-room property of Plan, which reads without the always-on instruction file.

## Call budget

The lifetime cost of an agent is its calls times its context, because every API call re-reads a context that keeps growing. In the audit above the median agent made 55-119 calls, the median lifetime input of a workflow agent was 124.8K tokens, and general-purpose agents reached 158 times their first call. So the number of calls is the lever. Give the agent its paths rather than letting it search for them; tell it to batch its reads, and to replace many Reads with one script that prints what it needs; and cap the calls in the prompt with a sized line such as "your budget is about <2 x files you must edit + 10, at most 150> tool calls, and past it you stop with a partial report". An open-ended coding agent — fix until the tests pass — also gets an iteration ceiling: a number of fix-and-run rounds after which it stops and reports where it stands.

## Mandatory prefilter

A Workflow that fans out over more than 20 similar items runs a deterministic prefilter in code first — a missing required marker makes an item an automatic negative, an exact match an automatic decision — and reports the kept and dropped counts with `log(`, for example `log('prefilter: kept ' + kept.length + ', dropped ' + dropped.length)`, so the numbers are visible in the run rather than inferred afterwards. The plan names the prefilter in its Subagent strategy. The anti-case is a fact-checking run that spent 852 agents and 41.9M tokens on items no filter had narrowed.

## Model tiering

The formula outlives model names. Work where a mistake is expensive and the result goes outward or into durable doctrine — client-facing prose, adversarial verification, production writes, edits to the always-on instruction files — gets the strongest model available. Work that is cheap and reversible — bulk classification, read-only reconnaissance, mechanical stages that follow a finished recipe — gets the cheapest adequate one.

**Phase models.** The current calibration: reading phases and mechanical phases that follow a finished recipe run on sonnet; verdicts, adversarial verification, synthesis, memory consolidation and edits to instruction files run on opus, and so does complex, architectural and context-loaded work, where main has already gathered the context and delegates "think on this and give me a verdict". The main session stays on the strongest model — that is a deliberate choice for quality.

Set `model` explicitly when spawning each agent, or pick a lean type whose frontmatter pins it. In the audit above, 90 % of Workflow runs defaulted to Opus: a phase that inherits the session's model silently sends cheap read-only reconnaissance to the expensive one.

State the output language in the dispatch prompt of a cheap-model phase whenever that text survives into a file or a user-facing answer: the cheaper model can quote a standing language rule and still answer in the language of its input, so the rule has to travel with the task rather than be inherited. This covers working machinery only — a skill that names its own output language still wins. The same briefing applies to the built-in `Explore` and `Plan` agents for a different reason: they do not load the always-on instruction file at all, so an `Explore` agent was once measured inheriting the session's model while seeing no standing rules and no language directive. Whatever they must honour, say it in their prompt.

## The dispatch contract

Language is one part of three. A dispatch whose output is durable — it survives into a file, a report, a deliverable or an answer the user reads — names all three at the dispatch point: the output language, a length cap in words or characters, and the return shape, meaning an explicit field list, a named template file or a schema. The three fail in different ways and so have to be stated separately. Without the language the phase answers in whatever language its input was in. Without the cap the reply grows until the model runs out of things to say, and the caller pays for the difference. Without the shape the caller parses prose, which is the one thing a structured return exists to avoid. The kit's rule decides which language to name: text addressed to the user follows the language of the user's request, and text written into an existing document follows that document's language. Where the language follows from the material in that way, name the condition instead of a language: the language of the user's request for the answer, the language of the paper for text written into the paper, the language of the source recording for a transcript.

The contract belongs beside the dispatch rather than in a preamble, because a phase is read where it is invoked. A new skill inherits the rule by being written against it: an audit of one skill corpus found the three parts missing in thirty-odd places and missing together, which is what a single unwritten convention looks like from the outside.
