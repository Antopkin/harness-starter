# Transcript Recipe

What to do with a finished meeting recording that the user dropped into the chat (voice recorder → transcription → text).

## Recognition

Signs of a transcript (any 2+):
- Lines from different people, names / roles at the start of lines
- Speech-to-text artefacts: "uhh", "hmm", broken-off phrases, repetitions, recognition typos
- Long unstructured text with conversational vocabulary
- Timestamps (`[00:12:34]`, `0:42:15`)

Do not confuse it with: a prepared brief / a client document / structured notes.

## Tolerance to recognition errors

- Guess the meaning from context (if "company" and "marketing" are nearby, "brand-ding" is probably "branding")
- When a transcription is uncertain, mark it `[?]` and offer an alternative: "...increased retention by 30% [?] (possibly: revenue)"
- Do not invent facts that were not there; if something is unclear, say explicitly "this part is illegible"

---

## Baseline (always): Structured Summary

A short digest at the start of the answer (5-10 lines) that answers:

- **Meeting goal** - why they met (if it can be inferred)
- **Attendees** (if identifiable) - names / roles
- **Key topics** - 3-5 discussed blocks
- **Main outcomes** - what they arrived at (even "arrived at nothing" is an outcome)
- **Tone / dynamics** - if it matters (conflict, agreement, brainstorming)

This is ALWAYS there. After it come the optional sections, depending on what the recording contains.

---

## Optional sections (only if the recording really contains that content)

Do not invent empty "Action Items: none". If there is no content for a section, simply leave it out.

### Issue Tree
If the discussion had an explicit problem that people tried to decompose or find the causes of, write it out as a root question plus the branches found. Run MECE over what was mentioned.

### Action Items
Who, what, by when. Format:
```
- [Ivan] prepare the cost analysis for Option B → by 5 May
- [product team] come back with the product spec → next meeting
```
Only if the transcript contained concrete promises / assignments.

### Decisions Log
What was decided (explicitly). Format: "**Decision:** [what], **rationale:** [why]". Do not confuse it with the options that were discussed.

### Open Questions
Questions that were raised but not closed. Useful to carry into the follow-up.

### Stakeholder Positions
If there were different positions on a key question, who stood for what:
```
- Ivan (CFO): for Option A, argument - cash flow in Q3
- Maria (CMO): for Option B, argument - brand consistency
- Undecided: Alexei, Olga
```
Only if the positions really diverged.

### Risks Raised
Who raised which risk. Useful for a recap to the client: it shows the risks were heard.

### Hypotheses to Test
Hypotheses that have to be checked in order to move on. Format: "hypothesis - how to check - who/when".

### Information Gaps
What is missing to make a decision. It often surfaces in the discussion ("we'd need data on X", "without Y we can't tell").

### Next Meeting Agenda
What to discuss next time - stated explicitly or following from the open questions / action items.

---

## Output style

- The Structured Summary first (always)
- Then the sections that apply, in decreasing order of importance to the user
- At the end, a short self-critique: "what in the recording I may have missed / misinterpreted"

Do not rewrite the whole transcript. Do not quote long passages verbatim. The goal is to give the user a fast, actionable overview that saves them 30-60 minutes of reading.

---

## Anti-patterns

- Including empty sections for form's sake ("Decisions Log: no decisions were made")
- Quoting long dialogues verbatim instead of synthesising
- Ignoring uncertain transcriptions and presenting them as facts
- Turning a working meeting into a formal protocol with fields such as "Chair", "Secretary" - the style should match the character of the meeting
