---
name: transcript-polish
description: "Not verbatim correction (transcript-verbatim), not a business document (transcript-docs). Deep editing of an ASR transcript in any language into clean written prose in the language of the recording: fillers removed, sentences and paragraphs rebuilt, meaning kept. Triggers: clean up the transcript, make it readable, polish transcript."
---

# transcript-polish — deep editing of transcripts

Turns a raw ASR transcript of speech into clear, coherent written text. It
removes fillers, rebuilds fragmented sentences, organises paragraphs and fixes
recognition errors — but keeps the speaker's original meaning, intent, personal
style, emphasis, humour and tone. It works on a recording in any language, and
the edited text stays in the language of the recording.

**Priority hierarchy** (inviolable): meaning > completeness of processing >
grammar and ASR correction > readability and style.

This is deep editing, not proofreading. If the speech must stay word for word and
only ASR errors should be fixed, that is `transcript-verbatim`. If a business
document (decisions, action items) is needed from a call, that is
`transcript-docs`.

## Input and delegation

Input-format recognition (`*_dialog.txt`, a Deepgram-style `*_transcript.json`,
plain `*_text.txt`, text in the chat), the neutral `speaker_glossary`, and the
"one subagent per file, one pass, batch by file" model all live in
`../shared/transcript-io.md`. Do not duplicate them here; read them there. main
does not process the transcript itself — it delegates to a subagent (the harness
rule "Delegate, and keep the main context clean").

Mapping the neutral glossary onto this skill's label: `display_name` → `{Name}:`.

**Output language:** the language of the recording (the "Typography" section below relies on this). **Length limit:** at most 150 words for the accompanying part of the subagent's answer; the edited text itself is not subject to the limit and is never shortened. **Output format:** the edited text, then the fields `glossary`, `unresolved_roles`, `annotations` (spelled out in "Prompt for the subagent"). The contract applies to every delegation from this section.

## Prompt for the subagent

Give the subagent the priority hierarchy (above) and the five editing steps:

1. **Basic cleanup** — remove ALL fillers and repetitions, fix
   grammar/spelling/punctuation.
2. **Structural editing** — rebuild fragments, split long sentences, organise
   paragraphs and transitions.
3. **Semantic refinement** — resolve ambiguities while keeping the meaning,
   clarify expressions, make terminology consistent.
4. **Final polish** — naturalness, a unified style and tone, a check that all ASR
   errors are gone.
5. **Editorial annotations** — mark interventions in `[...]`, written in the
   language of the recording: `[restored from context]`, `[inaudible]`,
   `[possibly meaning X]`, inserting missing words in brackets
   (`He said [that] he'd come`; in Russian, `Он сказал, [что] придёт`).

Details per step, special cases (names, numbers, lists, quotes, terms),
language-specific constructions, the prohibitions and ALL FOUR examples with
thought_process are in `references/editing-rules.md`. The subagent reads that
file in full before it starts.

**speaker_glossary (inline for the subagent):** build it from self-introductions
in the first 3–5 turns OR from a roster that was passed in; the entry is
`Speaker N → {role?, display_name?, evidence_turn}`. If the roles cannot be
determined and there is no roster, mark `[Roles not determined]` and escalate to
main; do NOT guess.

**Multiple speakers:** put a `{Name}:` label (curly braces) and start a new
paragraph at EVERY change of speaker, even for very short turns.

**One pass:** process the WHOLE file in one response. A continuation marker such
as `[TO BE CONTINUED]` in the output is FORBIDDEN — the file fits in the context
(`../shared/transcript-io.md` §5). The completeness principle stays inviolable:
do not shorten, do not skip parts, process the whole text.

**Output language:** the language of the recording; the result is a deliverable for a reader of that language, so a global rule such as "answer in English" does not apply to it, and the language named by the skill body takes precedence. **Length limit:** at most 150 words for the accompanying part of the subagent's answer (glossary, fields, remarks); the edited text itself is not subject to the limit — "One pass" above forbids shortening or truncating it. **Output format:** the edited text, then the fields `glossary:` (Speaker N → display_name, evidence_turn), `unresolved_roles:` (yes/no), `annotations:` (count by type: restored / inaudible / guess); the `[Roles not determined]` marker also stays in the text, but main decides on escalation from the `unresolved_roles` field. The contract covers the whole prompt of this section.

## Typography and ru-text

The output is coherent prose, so apply the always-on typography of the
recording's language when you compose the result: its proper quotation marks,
spaced or unspaced dashes as that language requires, an en dash for ranges,
non-breaking spaces where the language needs them. Write these typography
characters (the no-break space, the em dash and the rest) as real Unicode
characters, never as escape sequences or ASCII stand-ins such as ` `,
`&nbsp;` or `--`. For a Russian recording
`skills/ru-text/SKILL.md` is the single source of typography (guillemets «», a
spaced em dash —, non-breaking spaces after one-letter prepositions); read it
there and do not copy the rules.

For a Russian recording, add a recommendation at the end of the output: "If you
like, run the result through `/ru-text` for information style and stop-word
cleanup" (that is already beyond transcript editing).

## Output

At the end, ask the user WHERE to save (see `../shared/transcript-io.md` §6):

- (a) next to the source → suffix `*_dialog_polished.txt`;
- (b) at a path the user gives;
- (c) in the chat only.

## Navigator

| Task | File |
|---|---|
| Full editing rules + 4 examples with thought_process | `references/editing-rules.md` |
| Input format, speaker_glossary, delegation, one pass, output question | `../shared/transcript-io.md` |
| Typography of a Russian recording (always-on, single source) | `skills/ru-text/SKILL.md` |

## Triggers

Use this skill when a transcript has to become readable: "clean up the transcript", "make it readable", "remove the filler words", "tidy up the transcript", "edit the transcript", "polish transcript", or the same request in the language of the recording (for example «вычисти транскрипт», «причеши расшифровку»). The edit preserves the speaker's meaning and intent while the spoken debris goes away. Keeping the speech word for word belongs to transcript-verbatim, and a business document from the call belongs to transcript-docs.
