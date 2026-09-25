# schema — canonical extraction schema + citation contract + speakers + anti-hallucination invariants

The single source of truth on **what the subagent extracts** and **by which rules
it becomes text**. The subagent returns A SINGLE valid JSON object per this schema
(the contract is in `pipeline.md` §1). Anti-hallucination is the heart of the
skill; it has no file of its own, it all lives here, in the "Invariants" section.

Field names are fixed English keys. Field values — statements, quotes, names,
enum-like status words in rendered text — stay in the language of the recording.

---

## 1. Canonical extraction schema

Base arrays + enriching fields. **An unstated field is omitted**, never filled
with a placeholder (see §4 "Abstention").

### `meeting_meta` (object)

```
call_type, type_confidence (0..1), date, duration,
attendees_internal[], attendees_external[], facilitator,
confidentiality_tier, doc_mode (rolling | point_in_time), source_file
```

### `decisions[]`

```
statement (outcome), rationale, alternatives_considered[],
decision_maker, status (Proposed | Accepted | Deferred | Cancelled | Superseded),
reversibility (type-1 irreversible | type-2 reversible + who reverses it),
review_trigger, supersedes (ID of the superseded decision),
evidence_quote, start_ts
```

### `action_items[]`

```
task, owner_speaker (EXACTLY one name; "we"/"the team"/"someone" → UNASSIGNED),
due (date or trigger; if none → UNASSIGNED),
definition_of_done, dependencies,
commitment_tier (committed_in_meeting | inferred_implicit),
status, evidence_quote, start_ts
```

### `risks[]` (RAID entities)

```
entry_type (risk | assumption | issue | dependency),
description,
# by type:
#   risk        → probability, impact, severity
#   assumption  → validation_method, impact_if_false
#   issue       → root_cause, target_date
#   dependency  → producer, slip_impact
owner, status, evidence_quote, start_ts
```

### `tensions[]`

```
topic, positions { speaker → stance },
resolution (resolved | deferred | abandoned),
conflict_type (task | process | relationship),
evidence_quote, ts
```

### `agreement_signals[]`

```
topic_or_decision_id,
level (consensus | majority | contested | unresolved),
dissenters[], evidence_quote, ts
```

### `scope_creep_signals[]`

```
who_asked, what_added, tradeoff_acknowledged, evidence_quote, ts
```

### Simple arrays

```
open_questions[], attention_points[], key_points[],
topics_outline[], participants[]
```

### Claim-level metadata (on ALL schema objects)

```
provenance_label (observed | inferred | recommendation),
source_confidence (high | low + reason),
grounded (bool)
```

---

## 2. Citation contract

- **The locator is the turn's range**, for example `[1.12 - 19.07]`. The input
  gives a timecode **per turn, not per word** — so the citation honestly points
  at the turn and does not pretend to word-level precision. **Do not over-claim**
  the precision of the anchor.
- If the input has no timecodes, the locator degrades to the **turn / speaker
  number**. `evidence_quote` stays mandatory in every case.
- `evidence_quote` is checked against the **RAW text + timecode anchor** — that
  is, against the transcript **BEFORE** speakers are renamed. **NEVER** against
  the text after mapping to `owner_speaker` / display names (otherwise the quote
  stops being an exact substring of the source).
- **`evidence_quote` is ONE continuous substring of ONE turn.** Do not stitch
  fragments of different turns together with `…` — such a "quote" stops being an
  exact substring and breaks the grounding check. If a claim rests on several
  turns, give them as separate quotes with separate timecodes
  (`evidence_quote`, `evidence_quote_2`, … each with its own `start_ts`).
- A quote is never translated, even when the document is read by someone who
  does not speak the language of the recording.

---

## 3. Speakers

- The neutral `speaker_glossary` is built by `../shared/transcript-io.md` §3;
  this skill maps the neutral entry onto `owner_speaker` (its own family label).
- **Ambiguous speaker → `'unknown'`** (for action_items: `UNASSIGNED`).
  "We" / "the team" / "someone should" is not an owner, it is `UNASSIGNED`.
- **Neutral outcome language:** record *what was decided*, not "who pushed whom
  over" / "who won". `tensions` and `agreement_signals` describe the positions
  neutrally, through `evidence_quote`, not judgementally.

---

## 4. Anti-hallucination invariants (the heart of the skill)

### Stage chain — asymmetry as the trust mechanism

**EXTRACT → SYNTHESIZE → bounded AUDIT → render.** The final text is composed
**ONLY from the structured layer (JSON)**, never directly from the raw text. The
bounded audit (the second stage) may **only delete / downgrade / collapse** —
remove an item, lower its confidence, collapse an empty section. It **NEVER
fabricates** a new item. This asymmetry (an edit can only subtract, never add) is
the mechanism that makes the document trustworthy.

### Provenance on EVERY claim

| label | meaning | how it is rendered |
|---|---|---|
| `observed` | **SAID** outright in the transcript | high confidence, plain text |
| `inferred` | **INFERRED** from indirect signals | visible `[INFERRED]` tag, separate block, carries a clarifying question; **NEVER silently upgraded** to a firm claim |
| `recommendation` | the agent's **RECOMMENDATION**, not from the transcript | an explicit "recommendation" label |

Tags and labels are rendered in the language of the recording.

`inferred` stays `inferred` until the user confirms it. A silent upgrade
`inferred → observed` is forbidden.

### Grounding: no number without grounding

Every decision / commitment / number / date / name resolves to **≥1
`evidence_quote` + timecode**. An ungrounded number is **not smoothed over** and
not guessed — it is rendered as **"not stated in the transcript"**. The rule is
strictest for quantities: an invented figure in a business document costs more
than any gap.

### Abstention is first-class

An empty section is **more honest than filler**. If the call had, say, no
recommendations, the section says "no recommendation yet, X is needed" instead
of inventing one. Empty sections collapse (see `doc-business.md`), but "empty" is
a valid, non-defective outcome.

### Quality eval gates (for the verify stage)

Mandatory binary invariants:

- `fabricated_commitments == 0` — not a single commitment that is absent from the
  transcript;
- `ungrounded_quantities == 0` — not a single number without an `evidence_quote`.

Tracked (not a gate):

- `abstention_rate` — the share of empty/abstaining sections. **A measure of how
  rich the transcript is**, not a defect: a thin call yields many empty sections,
  and that is normal. No numeric RAGAS gate is applied (it falsely fails normal
  documents) — see `pipeline.md` §3.
