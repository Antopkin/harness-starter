# pipeline — the transcript-docs pipeline and the subagent contract

The pipeline is built for **delegation to one subagent per file** and processing
in **one pass** (see `../shared/transcript-io.md` §4–5). main does not process the
transcript itself: it delegates, waits for the JSON and composes the document.
Splitting one file between subagents is **not allowed** — parallelism is by file
only.

The end-to-end invariant chain: **EXTRACT → SYNTHESIZE → bounded AUDIT → render**.
The final document is composed **ONLY from the extracted structured layer (JSON)**,
never directly from the raw text. Every item of the document carries a timecode
quote. The full anti-hallucination model and its invariants are in `schema.md`.

Everything below works for a recording in any language. The document, the JSON
values and the quotes stay in the language of the recording.

---

## Step 0. Input

The preferred input is one **WITH timecodes** (`*_dialog.txt` or
`*_transcript.json`): every item of the document quotes a timecode, so the
timecode on a turn is the anchor of trust. Format recognition is in
`transcript-io.md` §2.

- **Cleaned text without timecodes** (`*_text.txt`, a paste into the chat) is
  acceptable: the locator degrades to the **turn / speaker number**, but
  `evidence_quote` is still mandatory. Citation is not switched off; only the
  precision of the anchor is lost.
- **Raw ASR output** (unprocessed JSON or a machine transcript with ASR noise) —
  **gently warn**: "the input looks like raw ASR; ASR noise is tolerable for a
  business document, but names/titles/numbers may be distorted by the machine.
  Run `transcript-polish` (readability) or `transcript-verbatim` (accuracy of
  names/numbers) first?" Do not block — ASR noise is acceptable for the business
  track, and the user decides.

---

## Step 1. EXTRACT (delegated to a subagent, one pass)

main delegates ONE file to ONE subagent. The subagent sees the **whole**
transcript in one pass, builds the neutral `speaker_glossary` (transcript-io.md
§3) and extracts grounded JSON strictly per `schema.md`.

### Subagent contract (pass it inline in the prompt)

1. Return **A SINGLE valid JSON object** per the schema in `schema.md`. **No**
   prose wrapper before or after it, **no** ``` fence. Only the JSON object.
2. `evidence_quote` is an **exact substring of the RAW text** as it appears in the
   transcript **BEFORE** speakers are renamed, plus a timecode (or turn number)
   as the anchor. Do not paraphrase the quote.
3. **An unstated field is OMITTED**, not guessed and not filled with a
   placeholder. An empty field is more honest than an invented one (abstention is
   first-class, see `schema.md`).
4. **Ambiguous speaker → `owner="unknown"`** (for action_items, `owner_speaker`
   per the schema rules). "We" / "the team" / "someone" → `UNASSIGNED`, not a
   name.
5. Provenance on EVERY object: `observed | inferred | recommendation`. Anything
   inferred (not said outright) is `inferred` only; never silently upgrade it to
   `observed`.
6. Every number / date / name / commitment resolves to ≥1 `evidence_quote`. Do
   not invent an ungrounded number — omit it (at render time it becomes "not
   stated").
7. One pass, the whole file. A continuation marker such as `[TO BE CONTINUED]`
   is FORBIDDEN (transcript-io.md §5).

Each subagent's prompt carries: the goal (extract JSON per the schema), the
boundaries (write no prose, do not guess, do not upgrade provenance), what to
produce (one JSON object), and how main will assemble it (parse the JSON and
compose the document).

**Output language:** the language of the recording — JSON values are not translated, and `evidence_quote` stays a verbatim substring of the raw text. **Length limit:** at most 25 words in one `evidence_quote`. **Output format:** a single valid JSON object per `schema.md` — `meeting_meta`, `decisions[]`, `action_items[]`, `risks[]`, `tensions[]`, `agreement_signals[]`, `scope_creep_signals[]`, `open_questions[]`, `attention_points[]`, `key_points[]`, `topics_outline[]`, `participants[]`.

---

## Step 2. SYNTHESIZE (compose, in main)

main composes the "call minutes-as-contract" **strictly from the structured
layer**. The writer invents nothing — there is nothing to invent, the material
comes only from the JSON. The structure and the re-weighting of sections by call
type are in `doc-business.md`.

- Every item of the document carries `evidence_quote` + timecode (or turn number).
- The always-on typography of the recording's language is applied **at compose
  time**: real Unicode characters for quotation marks, dashes, range dashes, NBSP
  and ellipses — not the literals ` ` / `&nbsp;` / `--`. For a Russian
  recording the rules come from `skills/ru-text/SKILL.md`; do not copy them.
- `inferred` items go into a separate block with a visible `[INFERRED]` tag
  (written in the language of the recording) and carry a clarifying question
  (see `schema.md`).

**Output language:** the language of the recording; `evidence_quote` is quoted as spoken, without translation. **Length limit:** at most 120 words per section item; BLUF ≤ 5 items, ≤ 12 items in each section, anything past the threshold goes into an appendix as a separate block rather than being thrown away. **Output format:** sections 1–11 of the "call minutes-as-contract" per `doc-business.md`.

---

## Step 3. VERIFY (ADVISORY self-check, NOT a hard gate)

This is the **bounded AUDIT** of the invariant chain. The second stage may only
**delete / downgrade confidence / collapse** an item — never fabricate a new one
(the asymmetry is the trust mechanism, see `schema.md`). A light self-check, not
a numeric gate:

- **(a) Citation check.** Every item of the document has an `evidence_quote` +
  timecode. An item without a quote is dropped or explicitly flagged (never left
  silently).
- **(b) Coverage.** Every extracted decision / action item / risk appears in the
  document. This guards against **silent loss** during composition: if 7
  decisions were extracted, the decision log must hold 7 (or an explicit trace of
  why an item was collapsed).
- **(c) Empty ≠ success.** If **0 items** were extracted, flag "empty / it looks
  like the call had no decisions or tasks; check that this is the right
  transcript" instead of reporting a successful generation.

**No numeric RAGAS gate.** A hard numeric threshold falsely fails normal
documents. Instead there are **visible confidence flags** on disputed items
(`source_confidence: low` → a "check the recording" line) and the mandatory eval
invariants from `schema.md`: `fabricated_commitments == 0`,
`ungrounded_quantities == 0`. `abstention_rate` measures how rich the transcript
is, not a defect: empty sections are normal.

---

## Batch over many files

N transcripts → a wave of subagents, **one per file**, file-disjoint, in parallel
(a soft guide of 5–10+, not a ceiling; transcript-io.md §4). main collects the
JSON objects and composes one document per file (or a combined one, if asked).
There is a sync barrier between files: wait for all the JSON, then compose.

**Output language:** the language of each recording, both for each subagent's JSON in the wave and for the assembled documents; a combined document over recordings in different languages uses the language of the user's request and keeps every `evidence_quote` untranslated. **Length limit:** at most 25 words in one `evidence_quote`; at most 120 words per section item of the document. **Output format:** from a subagent, a single valid JSON object per `schema.md`; from main, a document per `doc-business.md`; the contract applies to every subagent of the wave.
