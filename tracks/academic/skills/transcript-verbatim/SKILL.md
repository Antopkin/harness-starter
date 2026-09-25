---
name: transcript-verbatim
description: "Not deep rewriting (transcript-polish), not a business document (transcript-docs). Verbatim correction of an ASR transcript in any language: fixes recognition errors only (names, merged or cut words, phonetic swaps), keeps speech as spoken, in the language of the recording. Triggers: fix the recognition, correct ASR errors, keep the speech as is."
---

# transcript-verbatim

A verbatim ASR corrector. It fixes **only** the errors of machine speech
recognition (for example Deepgram nova-3); the speakers' speech stays
**verbatim** — fillers, repetitions, false starts, the colloquial register and the
word order all survive. It is meant for interviews and research transcripts where
the speech is the data. It works on a recording in any language, and the
corrected transcript and the correction log stay in the language of the
recording.

## Input and delegation

Input-format recognition, assembling the neutral `speaker_glossary`, the
delegation model (one subagent per file, one pass, batch by file), the
continuation-marker ban and the "where to save" question live in
`../shared/transcript-io.md`. **Do not duplicate** those sections; main links to
them and delegates.

Mapping neutral roles onto this skill's labels: roles → `{Interviewer}` /
`{Respondent}` (focus group → `{Respondent 1}`, `{Respondent 2}`…), written in the
language of the recording (a Russian interview uses `{Интервьюер}` /
`{Респондент}`). The fallback for roles that cannot be determined is
`[Speaker roles not determined automatically]`.

## Do not apply ru-text or any style pass

The output is deliberately verbatim. Information style, filler cleanup and
formalisation would destroy the speech register and devalue the data. Do **NOT
recommend** ru-text or any other style pass here, whatever the language.

## Prompt for the subagent

main delegates ONE file to ONE subagent. Inline the rules below in the prompt;
pass the full error taxonomy **by reference** to
`references/correction-rules.md`; pass `speaker_glossary` inline.

Because the subagent sees the WHOLE file in one pass, rule 8 (systemic errors →
once in the log with "repeats N times, timecodes [first]…[last]") and role
detection work straight away, with no cross-chunk merge.

**8 cardinal rules (inline):**

1. Keep ALL fillers of the recording's language (English: um, uh, like, you know, I mean; Russian: ну, вот, как бы, типа, эээ) — they are data, not rubbish.
2. Keep ALL repetitions, self-corrections, false starts and broken-off phrases.
3. Keep the structure of speech: do not split, do not merge, do not change the word order.
4. Keep the speech register: colloquial stays colloquial, do not formalise.
5. Fix ONLY the MACHINE's errors: wrong words, distorted names/titles, truncated words, ASR gender or agreement errors.
6. Mark uncertain fixes as `[?guess?]` and inaudible spots as `[inaudible]` (in the language of the recording).
7. Process the WHOLE file in ONE pass. A continuation marker such as `[TO BE CONTINUED]` is FORBIDDEN (see transcript-io.md §5).
8. A systemic error (one word wrong throughout the text) → fix ALL occurrences, record it ONCE in the log as "(repeats N times)".

**Forbidden (forbidden_actions, in brief):** deleting fillers, repetitions or any
fragments; restructuring or merging sentences; polishing for readability;
formalising colloquial speech; adding words or logical connectives; changing
punctuation (unless it is an obvious ASR error); correcting the speaker's
grammar.

**Error taxonomy and all examples** (proper_names, institutions, named_objects,
toponyms, abbreviations, word_errors, semantic_substitution — A DANGEROUS
PATTERN, fused_words, truncated_words, gender_errors) →
`references/correction-rules.md`.

**Output formats** (the `=== INTERVIEW ===` header, `{Role}:` turns without
timecodes, `=== CORRECTION LOG ===` with systemic and single sections) →
`references/correction-rules.md`.

**Output language:** the language of the recording; a rule such as "answer in English" does not apply to the transcript body or to the correction log — they are data, not an answer to the assistant. **Length limit:** at most 150 words per return to main — the full transcript and the log are written to files; the exception is option (c) "in the chat only" from the "Output" section, where the text goes into the answer in full. **Output format:** the fields `file` (path to the source), `out_transcript`, `out_log` (paths of the written files or `chat`), `systemic`, `single`, `uncertain`, `unclear`, `roles`. The contract applies to every subagent of this section, including a batch of files.

## Output

At the end, ask the user WHERE to save (see transcript-io.md §6):

- (a) next to the source → the transcript in `*_dialog_corrected.txt`, the log in `*_corrections.txt`;
- (b) at a path the user gives;
- (c) in the chat only.

## Navigator (task → file)

| Task | File |
|--------|------|
| Full taxonomy of ASR errors + all "original → correction" example pairs | `references/correction-rules.md` |
| 8 cardinal rules, forbidden_actions, speaker_identification (full) | `references/correction-rules.md` |
| Formats of the transcript and the correction log (verbatim) | `references/correction-rules.md` |
| Input-format recognition, speaker_glossary, delegation, one pass, output question | `../shared/transcript-io.md` |

## Triggers

Use this skill for interview and research transcripts that have to stay as spoken: "fix the recognition", "correct ASR errors", "verbatim correction", "keep the speech as is", "proofread the interview", "verbatim transcript correction", or the same request in the language of the recording (for example «поправь распознавание», «оставь речь как есть»). Fillers, repetitions, self-corrections and the colloquial register all survive the pass, and only what the recogniser got wrong is touched. Deep rewriting into readable prose belongs to transcript-polish, and a business document from the call belongs to transcript-docs.
