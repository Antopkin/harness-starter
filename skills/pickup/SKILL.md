---
name: pickup
description: "Pick up work from the most recent (or a given) handoff document. Slash invocation: /pickup [path]."
argument-hint: "optional: path to a handoff .md"
disable-model-invocation: true
---

A pointer, not a copy of the ritual. The canonical instructions for the agent picking up the work are already embedded in every handoff document (`skills/handoff` writes them verbatim), so they are NOT duplicated here. The skill is user-invoked (`disable-model-invocation: true`); only Claude Code honours that flag, so OpenCode and Codex may still invoke it on their own.

1. **Find the handoff.** If a path was passed as an argument, use it. Otherwise take the most recent one in `plans/handoffs/`: `ls -t plans/handoffs/*.md 2>/dev/null | head -1`.
2. **Read the whole file** and follow ITS embedded instructions: the sections "⚡ Instructions for the agent picking this up", Memory refs (load them first), Suggested skills, Active plan.
3. **EXECUTED contract.** If the first line of the file is `> EXECUTED …`, the handoff is already closed: do not execute it again; ask the user what to do.
4. **No handoffs**: say so plainly and make nothing up.

Pairs with `/handoff` (which writes); this skill reads. To execute a finished plan, do not come here; use the trigger "execute the plan …" instead (see `contexts/workflow-orchestration.md` § Plan execute pickup).
