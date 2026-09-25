---
name: handoff
description: Compact the current conversation into a handoff document so another agent can pick up the work. Slash-only invocation - /handoff [optional focus of next session].
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

The skill is user-invoked (`disable-model-invocation: true`); only Claude Code honours that flag, so OpenCode and Codex may still invoke it on their own.

**When to use /handoff vs the Plan-audit rule:** Handoff = save state mid-work ("tired, let's continue tomorrow": session continuity). Plan-audit rule (see `contexts/workflow-orchestration.md`) = ship a plan for execution ("the plan is ready, handing it to a clean session"). If you are in plan mode and the plan is ready to finalise, use the Plan-audit rule, not handoff.

1. Path: `plans/handoffs/$(date +%Y-%m-%d)-<short-slug>.md`, under the project root. Create `plans/handoffs/` if it doesn't exist (`mkdir -p`). If the target path already exists, bump the slug (`-2`, `-3`) — never overwrite a previous handoff.

2. The doc must let a fresh agent pick up cold. Use exactly this section order. The first section is **fixed canonical text** — reproduce it verbatim, do not rephrase or summarise. Optional sections are omitted entirely (no empty header) when there's nothing to put in them.

   ```markdown
   # Handoff: <slug>

   ## ⚡ Instructions for the agent picking this up

   Read this whole file carefully. Describe how you are taking on the task:
   which working principles, problems, value and next steps you understood.
   Ask me plenty of open questions before you act.

   **Subagent policy:** guard your context window as the main working
   session. For research, search, reading and exploration, launch
   specialised subagents (by type or with skills). Run them in parallel
   and in waves where the tasks are independent. One task = one subagent.

   Load the Memory refs below first, then look at Suggested skills.

   ## Goal
   One paragraph — what we're trying to accomplish.

   ## Principles and decisions from this session
   (optional — omit the whole section if nothing to capture)

   ## State
   Done / in flight / blocked.

   ## Open questions
   (optional — unresolved forks or things the user needs to answer; omit if none)

   ## Next step
   The single most concrete next action.

   ## Active plan

   If `plans/` has a plan file relevant to this session, link it by path. Don't restate its contents. Use "—" if none.

   ## Memory refs
   2–5 entries from `memory/MEMORY.md` the next session must load. Pick by relevance to the work, not all of them.

   ## Suggested skills
   Which skills the next session should reach for, by name.
   ```

3. Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

4. If the user passed arguments to `/handoff`, treat them as a description of what the next session will focus on and tailor Goal / Next step accordingly.

5. After writing, print the absolute path so the user can paste it into the next session.

6. **EXECUTED contract.** The session that executed a handoff (carried its task through to the end) adds the line `> EXECUTED <YYYY-MM-DD> — <outcome in one sentence>` at the very top of the file. That way the next reader sees at once that the handoff is closed and does not execute it again.

**Output language:** the language of the user's request for the prose you write yourself, while the template's headers and the canonical instruction block are reproduced verbatim as written above and the user's own wording is quoted as spoken. **Length cap:** at most 800 words for the whole handoff document — State and Open questions at most seven bullets each, Next step one sentence; whatever does not fit belongs in a plan or a memory note referenced by path. **Return shape:** the template's sections in the order given — Goal, Principles and decisions from this session (optional), State, Open questions (optional), Next step, Active plan, Memory refs (give the path `memory/MEMORY.md` once, then a bullet list of 2-5 named entries from it, half a line each on why that entry matters), Suggested skills (a bullet list of bare skill names, one per line, no prose) — followed by the written file's absolute path printed to the user. This contract governs every phase of this skill.
