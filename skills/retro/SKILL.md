---
name: retro
description: Experimental. Run a retrospective on a Claude Code session and propose the cheapest durable fixes to the agent's environment (checks, pointers, reviewer rules, trimmed instruction files). Proposes only; applies nothing without the user's go.
disable-model-invocation: true
argument-hint: "[session-id or path to a transcript .jsonl]"
---

# Retro

**Experimental.** This skill is new and its digest depends on the Claude Code transcript format, which may change; treat its findings as a first pass and check them before acting on them.

The user has asked for a **retrospective**. You are not judging the work done in the session; you are looking for friction in the agent's **environment** and proposing changes that make the next run smoother. Answer in the language of the user's request.

This skill is user-invoked: you start it yourself with `/retro`. The `disable-model-invocation` flag that stops the agent from starting it on its own is honoured only by Claude Code; OpenCode and Codex may still invoke it automatically, and their transcripts are not in the format the digest reads.

This skill only proposes. Nothing is written, installed or wired until the user says go, item by item or for the whole list.

## Steps

1. **Build the digest.** Run the prefilter beside this file:

   ```bash
   bash <this skill's directory>/scripts/digest.sh ${CLAUDE_SESSION_ID}
   ```

   The argument above is the running session's id, filled in when this skill loads; if the user named another session id or a transcript path, pass that instead. Without an argument the script falls back to the newest transcript of the current project in Claude Code's own transcript store, `~/.claude/projects/<cwd-slug>/<session>.jsonl`, which may belong to a parallel session; it then warns on stderr, naming the file it guessed and any other transcript in the project that changed in the last ten minutes. Relay those warnings to the user in the first lines of your answer. The script writes the digest to `$TMPDIR` as `retro-<session>.digest.txt` and prints that path. The jq program in `scripts/digest.jq` keeps user turns, tool names, errors, hook blocks, permission denials, API errors and oversized tool results, one line each with its transcript line number, secrets masked, long text cut.

   If the script exits non-zero, stop and say so in the first line of your answer, loudly: the transcript was missing, or the digest came out empty. Name the path it looked at and ask the user for the session id or path. Never report "no friction" for a session you could not read.

2. **Classify the friction.** Dispatch one `reader` agent to read the digest (and, where a digest line is too thin, the transcript lines it points to). Give it the seven categories below, the redaction rule and the fix principle.

   - Output language: English.
   - Length cap: 800 words.
   - Return shape: a list of `{category, evidence, proposed_fix, fix_kind}`, where `evidence` names digest line numbers and quotes only the signal lines, and `fix_kind` is one of `check`, `pointer`, `reviewer-rule`, `trim`, `tooling`, `access`, `rule`.

   A short session with a digest of a few dozen lines you may classify yourself instead of dispatching.

3. **Check before proposing.** For each candidate, look at what already exists: the repo's own lint, test and CI commands, the hooks in the settings, the instruction files, and the memory in `memory/`. A check that exists but is unwired or silently broken is the finding, not a reason to build a second one.

4. **Present the proposals** to the user, most severe first. For each: the category, the evidence (digest line numbers and the signal lines), the proposed fix, its kind, and where it would live. Then wait. Apply nothing until the user says go.

## The seven categories

- **Navigation pointers.** The agent spent turns finding a file or a fact. Would a one-line pointer in an instruction file or a doc have sent it straight there? Are there hidden dependencies between files?
- **Missing checks.** The agent made a mistake that a linter, type check, test, hook or CI job could have caught. A repo with no guardrail at all (no pre-commit hook, no CI job running its checks) is itself a finding.
- **Reviewer rules.** The review stage let a mistake through. Should the reviewer get a new rule, or should an existing rule be removed or clarified?
- **Oversized instruction files.** `CLAUDE.md`, `AGENTS.md` or another always-loaded file is large; steering in it belongs in a check, a reviewer rule or a reference file read on demand.
- **Expensive tool calls.** A call returned far more than it needed (the `LARGE-RESULT` lines), a search was repeated, or a tool is token-hungry. Could a prefilter, a narrower query or a script do it cheaper?
- **Instructions that change nothing.** Lines in steering files that do not alter the agent's behaviour: restated defaults, rules nobody could break, advice the model already follows.
- **Missing information.** A crucial fact was not available to the agent: logs it could not see, a service it could not read, a decision nobody wrote down.

## The fix principle

Propose the cheapest fix that stays fixed. **A mechanical mistake gets a check (hook, test, gate), not a written rule.** A fixed syntactic pattern, a banned command, an import shape or a file-location rule is mechanical: build the check in the repo's existing linter, a hook or a CI job, whichever is cheapest there. Keep written rules for genuine judgement calls, and put them where they are read at the right moment: reviewer rules in the review stage, not in the implementer's always-loaded file. `references/fix-placement.md` explains why the reviewer, not the implementer, should carry standards, and which file holds what.

When a fix does need instruction text (a pointer, a reviewer rule, a trimmed section), write it the way `../skill-creator/references/writing-for-agents.md` describes, and show the user the exact text you propose.

## Redaction

Transcripts carry secrets: keys pasted into a prompt, tokens in a command, credentials in a tool's output. The digest masks the obvious shapes, but the mask is not a guarantee.

- Never paste a secret into your answer, a proposal, or a file. Write `<REDACTED>` in its place.
- Quote only the signal lines: the error, the blocked command's first words, the denial reason. Do not paste whole tool outputs or whole user turns.
- If a secret did leak into the transcript, say that it did and where (line number), and propose rotating it, without repeating it.

Adapted from mattpocock/skills@c55ee46 in-progress/retro (MIT).
