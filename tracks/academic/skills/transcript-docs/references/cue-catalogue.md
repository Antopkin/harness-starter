# cue-catalogue — multilingual catalogue of detection cues

The document is read **in two layers**: **WHAT** was said (explicit content →
decisions, tasks, numbers) and **HOW** it was said (paralinguistics → hedges,
implicit commitments, unresolved disagreements). This catalogue is about the
second layer: speech cues which signal that a phrase hides a risk, a task without
an owner or a fake consensus.

**Every flag is falsifiable.** A cue does not deliver a verdict — it carries a
**verbatim quote + timecode**, so the reader can jump to that spot in the
recording and **judge for themselves**. No "I decided this is a risk" without a
quote you can point at.

The tool works **in the language of the recording**. The table gives paired
English and Russian cues as worked examples; for any other language, detect the
equivalent cue in that language (the category and the target section do not
change). The catalogue sits in `references/` for progressive disclosure (it is
loaded only when the subagent classifies signals).

---

## Catalogue: cue → category → document section

| Category | EN cues | RU cues (example) | Where (section / schema field) |
|---|---|---|---|
| **Clustered hedges** | "maybe", "sort of", "I guess", "kind of", "not sure but" | «наверное», «вроде», «мне кажется», «не уверен, но» | RAID → `risks` (risk/assumption); `source_confidence: low` |
| **Implicit commitment** | "we should", "I'll try", "if we get time", "would be nice" | «надо бы», «попробую», «если успеем», «постараюсь» | action item **[INFERRED]** (`commitment_tier: inferred_implicit`) |
| **Ownerless** | passive voice, "someone should", "it needs to be done", topic-as-task ("so, analytics…") | «должно быть сделано», «кто-то должен» | `risks` (risk); `owner_speaker = UNASSIGNED` |
| **Vague deadline** | "soon", "in a bit", "at some point", "shortly" | «на днях», «скоро», «как-нибудь» | flag on the action item: `due = UNASSIGNED` + GAP flag |
| **Unresolved disagreement** | "yes, but…", "let's circle back", "we'll revisit", "I'm not convinced" | «да, но…», «вернёмся к этому», «ну не знаю» | **parking lot / asks** (sections 8, 11), `tensions.resolution: deferred` — **do NOT drop** |
| **Scope creep** | "small addition", "while we're at it", "quick win", "just one more thing" | «маленькая доработка», «раз уж взялись», «заодно бы ещё» | attention (section 6); `scope_creep_signals` |
| **False consensus / silence** | silence after a proposal, "ok I guess", "uh-huh" as the only answer, no objections voiced | «ну ок», «угу» as the only answer | **[INFERRED]**, needs confirmation — **silence ≠ agreement**; `agreement_signals.level: unresolved` |

---

## Language-specific layer

The cues of the recording's language are the primary detector, not a
translation of the English column. Every language has subtleties that a
translated list misses; the ones below show the kind of nuance to look for, with
paired examples:

- **Filler vs hedge.** In lively speech many hedge words are really fillers:
  English "like" / "kind of", Russian «как бы» / «типа» / «это самое». Count
  them as a hedge **only** when they cluster around a substantive claim ("so we
  kind of decided, I guess, that…"; «ну, мы как бы решили, наверное, что…») — a
  lone filler is not a flag.
- **Topic-as-task** — naming an area with no verb and no owner ("so,
  onboarding…", "about the deploy…"; «ну, онбординг…», «там по деплою…»). A
  strong signal of an ownerless risk: the subject is there, the commitment is not.
- **Impersonal modality** — "it needs to", "this has to" without a subject;
  Russian «надо», «нужно» without a subject. This is **not** a commitment of a
  specific person → action item `[INFERRED]` with `owner_speaker = UNASSIGNED`,
  not attributed to the speaker.
- **Polite back-channelling as the only response** to a proposal ("uh-huh",
  "sure, sure"; «угу», «ну ок», «да-да») — false consensus. In some speech
  cultures polite assent is especially easy to mistake for buy-in; mark it
  `[INFERRED]` and put it into a confirmation round.

Any language-specific flag is rendered the same way as the rest: **verbatim quote
+ speaker + timecode**, so it stays falsifiable.
