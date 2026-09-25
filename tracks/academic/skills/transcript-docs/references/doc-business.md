# doc-business — structure of the "call minutes-as-contract" + adaptivity

**One adaptive artefact, not a zoo of templates.** There is one extraction (see
`schema.md`); the call type changes only the **projection**: which sections are
promoted and which are suppressed. This is **re-weighting sections, NOT
re-extraction**. The principle: **content is sovereign, format is rendering** —
the content from the JSON is sovereign, the shape of the document is only the way
it is served.

The document, its section headings and its labels are written in the language
of the recording; the headings below are given in English as the reference
names.

## Call-type auto-classifier

`meeting_meta.type_confidence` decides the mode:

- **> 0.75** — the type is picked automatically, the document renders silently
  with the type noted in the header;
- **0.5–0.75** — **ask** the user: "looks like a TYPE call, right? or ALTERNATIVE?";
- **< 0.5** — the general template (all always-on sections at neutral weight) + a
  **flag** "the call type could not be determined".

Conditional sections **COLLAPSE when empty** — a guard against bloat: no data for
a section, no section in the document (abstention, `schema.md` §4).

---

## Always-on sections (1–6)

### 1. Header / metadata

Call type (+ confidence flag if < 0.75), date, participants with roles
(**our side | external side**), confidentiality tier, the timecode range of the
whole call. Source: `meeting_meta`.

### 2. The gist in 30 seconds (BLUF)

Five lines with bold labels — answers the request "what did we agree on":

- **Outcome** — the main result of the call;
- **What changed** — the delta against the previous state;
- **Key risk** — **the one thing** most likely to break the plan (not a list);
- **Next milestone** — a date;
- **Ask** — what we expect from the reader (or "no decisions required").

Each line refers to a specific `decision` / `risk` / `action_item` with a
timecode. BLUF comes first, before the details (Bottom Line Up Front).

### 3. Decision log

For each decision: **ID**, the decision as an outcome, **status**, the triggering
context, options (including **"do nothing"**), rationale, **rejected options with
"why not"**, who decided + **reversibility** (type-1/type-2), review date/trigger.
`evidence_quote` + timecode. Answers "what to record".

**Logging threshold** (otherwise the item does not go into the log): costly to
undo **OR** cross-functional **OR** still important in 6 months **OR** there were
rejected options. Small operational items like "agreed to call again" do not go
into the log.

### 4. Action items as contracts

For each: **owner / due date / definition of done / dependencies / link to the
decision / status**. Two tiers (from `commitment_tier`):

- **COMMITTED IN THE CALL** (`committed_in_meeting`);
- **INFERRED** (`inferred_implicit`, tag `[INFERRED]`).

A missing `owner` or `due` → a **visible GAP flag** ("owner not named", "deadline
not named"), never an invention. Answers "action items" and "deadlines".

### 5. RAID register

Risks / assumptions / issues / dependencies (from `risks[]`, `entry_type`).
**RAID is a core section of the document, NOT a separate call type.**
Disambiguate by the tense of the statement:

- present tense ("we're already behind", "it doesn't work"; «уже отстаём») =
  **Issue**;
- conditional ("if the vendor slips", "we might not make it"; «может не успеть»)
  = **Risk**.

Answers "potential problems".

### 6. What to watch

The top 3..5 **watch items by severity**, **recommendation-first** (not a flat
dump). For each: the statement, severity, **verbatim quote + speaker +
timecode**, why it matters, the next step; a **SAID vs INFERRED** label. At the
top of the section, a **"risk temperature of the call"** line (the overall
assessment). Directly answers the user's request "what should we watch".

---

## Conditional sections (7–11, collapse when empty)

### 7. Participants and decision rights (DACI / RAPID)

Who is Driver / Approver / Contributor / Informed. For **decision-making and
cross-organisation** calls. Source: `participants` + `decisions.decision_maker`.

### 8. What needs a decision / asks

Where sign-off from outside the room is needed. If a question has **no
decision** → it turns into an **action item with an owner** (someone has to get
that decision) instead of hanging.

### 9. Confidence, inferences, contradictions

Three buckets: **SAID | INFERRED | RECOMMENDATION** (from `provenance_label`).
Flags for contradictions within the call (`tensions`). Low-confidence items →
"check the recording". An explicit "not stated in the transcript" for gaps.

### 10. Level of agreement and tone

Per topic: consensus / contested / unresolved (from `agreement_signals`). Catches
the difference between **"pushed through"** and **"real buy-in"** — recorded
neutrally through `dissenters` + a quote.

### 11. Parking lot and next steps

What was deferred (+ when we return to it), whether a confirmation round is
needed, the next contact. Source: `open_questions` +
`tensions.resolution = deferred`.

---

## Adaptivity matrix: call type → section emphasis

| Call type | What dominates | What shrinks | Tone / special |
|---|---|---|---|
| **project sync / stand-up** | blockers (RAID) + action items | decision log condensed | operational |
| **client call** | "what we recorded" per side; participants **always-on** | internal kitchen | formal, **zero jargon** |
| **decision meeting** | decision log **in full depth** + DACI (section 7) | — | decision rights explicit |
| **kickoff** | goals + **scope IN/OUT** (out-of-scope against scope creep) + RAID + RACI | — | project boundaries |
| **status** | "what changed" + "what needs a decision" (section 8) | — | delta-oriented |
| **1:1** | rolling mode (`doc_mode`), high sensitivity | public sections | confidential |

`doc_mode`: **rolling** (accumulating, e.g. a 1:1) versus **point_in_time** (a
snapshot of one call). `scope_creep_signals` from the schema feed the kickoff
section scope IN/OUT and section 6 "what to watch".
