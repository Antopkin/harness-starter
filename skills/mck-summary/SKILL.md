---
name: mck-summary
description: "Pyramid executive summary in the Big-3 consulting style, built from material you already have. Slash call /mck-summary [topic or path]."
argument-hint: "topic or path to the material"
disable-model-invocation: true
---

A thin wrapper, not a copy. We do NOT rewrite the format rules: read the source and follow it.

User-invoked: `disable-model-invocation: true` is honoured only by Claude Code; OpenCode and Codex may still invoke this skill on their own.

1. **Read the source of the structure:** `../mckinsey/references/deliverables.md` §1 "Pyramid Executive Summary" (SCQA opening; the governing thought in the first or second paragraph; 3 MECE pillars, each with evidence; the So-What at the end; 250–500 words; no bullets in the main text).
2. **Assemble the summary** strictly on that skeleton from the material you were given (the topic or path in the argument).
3. **Run it through `/ru-text`** (typography plus info style) before delivering it, when the summary is in Russian.

**Output language:** the language of the user's request.

For full problem-solving work (issue and hypothesis trees, market sizing, push-back), do not use this skill; use the `/mckinsey` skill instead.
