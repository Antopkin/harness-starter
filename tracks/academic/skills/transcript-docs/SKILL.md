---
name: transcript-docs
description: "Not verbatim (transcript-verbatim), not readable text (transcript-polish). A business document from a call in any language: agreements, action items, deadlines, risks, each with a timecode quote; written in the language of the recording. Triggers: make a document from the call, meeting minutes, what did we agree on."
---

# transcript-docs

The business track of the `transcript-*` family: it turns a call transcript into a
**business document, the "call minutes-as-contract"** — what was agreed, the
agreements, what to record, action items with deadlines, participants, what to
watch, potential problems. It is the largest of the three transcript skills; all
the bulk lives in `references/`, and this file is only the map. It works on a
recording in any language, and the document is written in the language of the
recording.

## Input and delegation

Input-format recognition, the neutral `speaker_glossary`, the delegation model
(**one subagent per file, one pass, batch by file**), the continuation-marker ban
and the "where to save" question live in `../shared/transcript-io.md`. Do not
duplicate them here: main links and delegates.

- **Prefers input WITH timecodes** (`*_dialog.txt` / `*_transcript.json`) — every
  item in the document quotes a timecode. Without timecodes the locator degrades to
  the turn number, and the citation stays.
- **Raw ASR output** → gently warn and offer `transcript-polish` /
  `transcript-verbatim` first (ASR noise is tolerable for a business document).
  Details in `references/pipeline.md`.

**Output language:** the language of the recording — the subagent's JSON values are not translated, and `evidence_quote` stays a verbatim substring of the raw text. **Length limit:** at most 25 words in one `evidence_quote`. **Output format:** a single valid JSON object per `references/schema.md`; the contract applies to every subagent of this delegation model (one subagent per file).

## Pipeline

**EXTRACT → SYNTHESIZE → bounded AUDIT → render.** The subagent extracts grounded
JSON per the schema in one pass; main composes the document **strictly from the
structured layer** (not from the raw text); then an advisory self-check (citation,
coverage, "empty ≠ success"). Details and the subagent contract are in
`references/pipeline.md`.

**Output language:** the final document is in the language of the recording; the subagent's JSON values stay in that language, and `evidence_quote` is never translated. **Length limit:** at most 120 words per section item (`evidence_quote` at most 25 words), BLUF ≤ 5 items, ≤ 12 items in each section; anything past the threshold goes into an appendix as a separate block rather than being thrown away. **Output format:** sections 1–11 of the "call minutes-as-contract" per `references/doc-business.md`; the contract covers every phase of the EXTRACT → SYNTHESIZE → AUDIT → render chain.

## Schema

The subagent returns a single valid JSON object. Arrays: `meeting_meta`,
`decisions[]`, `action_items[]`, `risks[]` (RAID), `tensions[]`,
`agreement_signals[]`, `scope_creep_signals[]`, `open_questions[]`,
`attention_points[]`, `key_points[]`, `topics_outline[]`, `participants[]`. Every
object carries claim-level metadata (`provenance_label`, `source_confidence`,
`grounded`). The full schema and the citation contract are in
`references/schema.md`.

## Anti-hallucination (the heart of the skill)

- **Provenance on every claim:** `observed` (SAID) | `inferred` (INFERRED — a
  visible `[INFERRED]` tag, carries a clarifying question, never silently
  upgraded) | `recommendation` (RECOMMENDATION).
- **Grounding for every number:** number / date / name / commitment → ≥1
  `evidence_quote` + timecode. No grounding → "not stated in the transcript"; do
  not smooth it over.
- **Abstention is first-class:** an empty section is more honest than filler.
- **Compose only from the structured layer:** the bounded audit may only
  delete/downgrade/collapse, never fabricate.

The full version (including the eval gates `fabricated_commitments == 0`,
`ungrounded_quantities == 0`) is in `references/schema.md`. These statements are
short here and full there — they must agree.

## Document and adaptivity

One adaptive artefact: one extraction, projected onto the call type by
**re-weighting sections** (content is sovereign, format is rendering). Always-on
sections: header, BLUF "the gist in 30 seconds", decision log, action items as
contracts, RAID register, "what to watch". Conditional (collapse when empty): DACI,
asks, confidence/contradictions, level of agreement, parking lot. Call type →
section emphasis (the matrix) and the classifier thresholds are in
`references/doc-business.md`.

Detection cues (hedges, implicit commitments, ownerless items, vague deadlines,
unresolved disagreement, scope creep, false consensus), with paired examples in
several languages, are in `references/cue-catalogue.md`.

## Typography

Always-on typography of the recording's language is built into **compose**: real
Unicode characters for that language's quotation marks, dashes, range dashes,
non-breaking spaces and ellipses — **not literals** such as ` ` / `&nbsp;` /
`--`. For a Russian recording the rules come from `skills/ru-text/SKILL.md` (guillemets
«», em dash —, en dash –, NBSP); do not copy them here. The document is prose, so
for a Russian recording offer the full information style / stop-word pass as a
**recommendation** of `/ru-text` at the end rather than running it silently.

## Output

Ask where to save (transcript-io.md §6):

- (a) next to the source → `*_meeting-doc.md`;
- (b) at a path the user gives;
- (c) in the chat only.

## Navigator (task → file)

| Task | File |
|--------|------|
| The EXTRACT→SYNTHESIZE→AUDIT→render pipeline, subagent contract, advisory verify, batch | `references/pipeline.md` |
| Canonical extraction schema, citation contract, speakers, anti-hallucination invariants, eval gates | `references/schema.md` |
| Structure of the "call minutes-as-contract", sections 1–11, auto-classifier, type→emphasis matrix | `references/doc-business.md` |
| Multilingual catalogue of speech cues → category → section | `references/cue-catalogue.md` |
| Input format, speaker_glossary, delegation (1 subagent/file, 1 pass), one pass, output question | `../shared/transcript-io.md` |
| Always-on typography and information style/stop words for a Russian recording | `skills/ru-text/SKILL.md` |

## Triggers

Use this skill when someone asks for a document out of a call: "make a document from the call", "meeting minutes", "minutes from call", "what did we agree on", "action items from the call", "agreements and risks from the meeting", "what should we record from the meeting", "meeting doc", or the same request in the language of the recording (for example «протокол встречи», «о чём договорились»). The document also names the participants and the points that deserve attention, and every item carries its timecode quote, which is what keeps the output free of invention. The skill writes a document and puts nothing into a task tracker. Verbatim correction belongs to transcript-verbatim, and merely readable text belongs to transcript-polish.
