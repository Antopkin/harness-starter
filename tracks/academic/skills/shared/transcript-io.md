---
name: transcript-io
description: Foundation reference for the transcript-* skill family (transcript-verbatim, transcript-polish, transcript-docs). Input-format recognition, neutral speaker glossary, single-pass delegation model, continuation-marker ban, output-location question. Loaded by reference from the three transcript skills — not invoked directly.
disable-model-invocation: true
---

# transcript-io — shared input and delegation model

This file is the single source of truth on **input** and **execution** for the
`transcript-*` skill family. Its consumers (`transcript-verbatim`,
`transcript-polish`, `transcript-docs`) **link to this file and do NOT
reimplement its rules**: format recognition, turn assembly, the neutral glossary,
the delegation model and the question of where to save the output. One producer,
three consumers: if a consumer redefines how ASR output is assembled, or starts
guessing roles on its own, the family drifts apart. Don't.

The skills work on a recording in any language, and everything they write stays
in the language of the recording. Nothing here depends on one language; where an
example shows a particular language, it only illustrates the rule.

Boundary: only the neutral model lives HERE. Mapping speaker roles onto concrete
labels (`{Interviewer}`, `{Name}:`, `owner_speaker`) is done by EACH skill on its
own side, not by this file.

---

## 1. Purpose

- The single source for the three `transcript-*` skills; consumers link here and
  do NOT duplicate the rules of this file.
- Mapping the neutral glossary onto concrete labels happens on each skill's side,
  NOT here. This file goes as far as a neutral `speaker_glossary` and no further.

---

## 2. Input-format recognition

FOUR formats are supported. If the input fits none of them, **escalate to main,
do not guess**.

**`*_dialog.txt`** — blocks `[start - end] Speaker N:`, followed by the multi-line
text of the turn; an empty line separates turns. The speaker label is whatever
the converter wrote, in the language of the recording (`Speaker N:`,
`Спикер N:`, `Sprecher N:`…); treat any of them the same way:

```
[00:00:04 - 00:00:11] Speaker 0:
Hello, let's begin. Tell me a little about yourself and your role.

[00:00:12 - 00:00:31] Speaker 1:
Sure. I work as a product manager and I'm responsible for onboarding.
```

**`*_transcript.json`** — raw Deepgram-style ASR JSON. The words sit at the path
`results.channels[].alternatives[].words[]`, and each element is
`{word, start, end, speaker, punctuated_word}`. Assembling turns:

- group consecutive `words` with the same `speaker` into one turn;
- build the turn text from `punctuated_word` (with punctuation), not from `word`;
- the turn's timecode = `start` of the group's first word .. `end` of its last word;
- a change of `speaker` closes the current turn and opens the next one.

**plain `*_text.txt`** — continuous text without speaker markup and without
timecodes.

**text pasted in the chat** — the user put it straight into a message, no file.

---

## 3. speaker_glossary in NEUTRAL form

Entry structure: `Speaker N → {role?, display_name?, evidence_turn}`. It is built
from self-introductions in the first 3–5 turns OR from a roster the user passed
explicitly. `evidence_turn` is the number of the turn that `role`/`display_name`
were taken from.

The numbering "Speaker 0 / Speaker 1" is **NOT fixed across files**: you cannot
assume that "Speaker 0" is always the interviewer. Only the content of the first
turns or the roster binds a number to a person.

EACH skill maps the neutral glossary onto its own labels:

| Skill                | Mapping of the neutral entry onto its label |
|----------------------|------------------------------------------|
| `transcript-verbatim`| roles → `{Interviewer}` / `{Respondent}` |
| `transcript-polish`  | `display_name` → `{Name}:` |
| `transcript-docs`    | owning speaker → `owner_speaker` |

Labels are written in the language of the recording (for a German interview,
`{Interviewer}` / `{Befragte}`; for a Russian one, `{Интервьюер}` / `{Респондент}`).
**NO mapping happens HERE** — the table only describes what the consumer will do.

**Fallback:** if the roles cannot be determined from the first turns and no roster
was passed, mark `[Roles not determined]` (in the language of the recording) and
escalate to main. Guessing roles is NOT allowed — otherwise each skill guesses in
its own way and the labels drift apart.

---

## 4. Execution model — delegation

main does **NOT process the transcript itself** — this keeps the main session's
context clean (reading and processing go through subagents).

- main delegates a file to **ONE subagent**: the subagent reads the file and the
  rules of the specific skill, works through it in **one pass** and returns the
  result (text or JSON) to main.
- **Batch:** N files → a wave of subagents, **one subagent per file**
  (file-disjoint, in parallel; a soft guide of 5–10+, not a ceiling).
- Parallelism is **by file, NOT by chunks of one file**. A single file is never
  split between subagents.

---

## 5. One pass, no continuation marker

The subagent processes the whole file in one response. A continuation marker such
as `[TO BE CONTINUED]` in the output is **FORBIDDEN**.

Rationale: the inputs fit in the context. A long interview transcript runs to
about 16,000 words (≈ 21k tokens), while a current frontier model's context
holds hundreds of thousands of tokens or more. The margin is huge.

The only fallback is a hypothetical file whose **OUTPUT** does not fit in one
response (on the order of >30,000 words): the subagent **continues on its own in
the next response**, WITHOUT inserting a marker into the body of the text. The
marker does not appear in any scenario.

---

## 6. Output

At the end of processing the subagent/skill asks the user **WHERE to save the
result**:

- (a) next to the source;
- (b) at a path the user gives;
- (c) in the chat only.

The concrete suffixes of output file names are decided on each skill's side, not
here.
