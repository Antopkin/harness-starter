# Deliverable Formats

Three draft formats. Chosen from the user's request; if it is not specified, ask in one line.

---

## 1. Pyramid Executive Summary

**When:** a short format for 1 screen / 1 page (250-500 words). The default for the words "executive summary", "short conclusion", "summary", "the gist".

### Structure

```
[SCQA opening — 2-3 paragraphs of unlabeled prose]

Situation:    One fact about the current state that the audience agrees with
Complication: What has changed / why the status quo is not viable
Question:     [not spoken aloud, but it must arise in the reader's head]
Answer:       The direct answer = governing thought (the last sentence of the opening)

[The governing thought is repeated as a heading / explicit thesis]

[3 supporting pillars, MECE — a paragraph or a short subsection for each]
  Pillar 1: [action/fact] - [evidence: data, source]
  Pillar 2: [action/fact] - [evidence]
  Pillar 3: [action/fact] - [evidence]

[So-What conclusion: what this means for the decision / next steps]
```

### Rules

- **Answer first**: the governing thought goes in the first or second paragraph, not at the end
- **3, not 5**: 3 pillars are remembered, 5 are not; if you end up with 5+, restructure into 2 levels (3 super-pillars × sub-pillars)
- **MECE pillars**: each pillar answers its own aspect of "why the answer is right"; if two pillars overlap, merge them
- **Evidence per pillar**: each pillar is backed by data, not by general words
- **So-What**: the final paragraph answers "what to do with this" / "what this changes"
- **Length**: 250-500 words; if it comes out longer, cut, do not keep
- **No bullet points** in the main text (only if the evidence really is a list); connected paragraphs read better for executives

### Example skeleton (fill in)

```markdown
[Situation: "Company C has reached $50M ARR and keeps growing, but margin has shrunk from 28% to 19% in two years."]

[Complication: "The current cost structure is tied to fixed supplier contracts signed at peak growth; these contracts expire in 6-12 months."]

[Answer/governing thought: "Renegotiating three key contracts and moving them to a usage-based model will restore margin to 26-28% while keeping operations stable."]

## Why this will work

**The contracts account for 70% of the variable savings.** The contracts with X, Y, Z are 18% of COGS; moving them to usage-based is expected to cut them by 25-35% on the industry benchmark [SOURCE].

**The operational risks are manageable.** Alternative suppliers are ready; volume forecasting for usage pricing is accurate to ±15% over the last 4 quarters.

**The window is open only until Q3.** Contracts Y and Z expire in July-September; negotiations should start 90 days before renewal.

**What next:** name the negotiating team, build a BATNA for each of the three contracts, and hold the first meeting with X by 1 June.
```

---

## 2. Full Report on an Issue Tree branch

**When:** "full report", "in detail", "expand this branch", "detailed on [branch X]".

### Structure

```
1. Executive summary (a short pyramid - see the format above, 200-300 words)

2. Context and problem statement
   - Where this branch sits in the overall tree (root question + the branch's place)
   - What is in scope, what is out of scope

3. Analysis
   - The branch's sub-questions → an answer to each
   - Evidence per claim ([SOURCE] / [INFERENCE] / [ASSUMPTION])
   - Quantitative estimates where applicable

4. Findings + implications
   - 3-5 key findings
   - Each one through the So-What test (Finding → So What → Therefore)

5. Recommendations
   - The main recommendation (one sentence)
   - Supporting actions
   - Premortem: what could go wrong in 6 months

6. Risks & sensitivity
   - What we assume; what if the assumptions are wrong
   - Key downside scenarios

7. Next steps
   - Concrete immediate actions (what, who, by when)
```

### Rules

- 80%+ prose, not bullet points (bullets only in Next Steps and in the evidence list)
- Every section starts with a topic sentence answering "what this section gives you"
- Source citations inline `[SOURCE: ...]` or as footnotes `[1][2]` with an appendix
- Length: ~1500-3500 words per branch; if less, do not make a full report, make a pyramid

---

## 3. Slide Outline (McKinsey deck style)

**When:** "slides", "presentation", "outline for a deck", "slide sketch".

### Structure

```
Slide 1: [Action title - assertion, not topic]
  Body: Evidence/visual that proves the title

Slide 2: [Action title]
  Body: ...

...

Slide N: [Action title]
  Body: ...
```

### Rules

- **Action titles, not topic titles.** An action title is an assertion ("Moving to usage-based pricing restores margin to 26% within 12 months"). A topic title is a category ("Pricing analysis"). Topic titles are forbidden.
- **Body proves the title.** The slide content (chart, table, bullets, quote) must prove the title. If it does not, change one of the two.
- **Vertical logic** (within one slide): title and body agree; the body introduces no new assertions that the title does not reflect.
- **Horizontal logic** (across slides): the action titles, read in a row 1→N, add up to a coherent narrative. This is the **Read-Through Test**.

### Read-Through Test (mandatory self-check)

After generating the outline, write out only the titles 1→N in a row. Read them aloud or to yourself:

- Do they add up to a convincing narrative? (Situation → Complication → Question → Answer → 3 reasons → next steps)
- If the audience reads only these, will it get the main message?
- Is there a logical gap between slide N and N+1?

If even one answer is "no", rewrite the titles. The slide bodies need no changes (as long as they prove the titles).

### Typical deck structure (10-15 slides)

```
1. Title + key thought (governing thought)
2. Context / situation (1-2 slides)
3. Complication / why act now
4. Question / decision needed
5. Answer / recommendation (one sentence)
6-10. Pillars (3 main + supporting)
11. Risks / sensitivity
12. Implementation roadmap
13. Next steps / decision needed (what we ask of the audience)
```

---

## General rules for all formats

- **Specificity Filter**: every statement must be falsifiable. "The market is growing" → "The market is growing 12% YoY [SOURCE]".
- **Source / Inference / Assumption marking**: for non-trivial claims.
- **Premortem before recommendations** (built into the text or as a separate micro-section): "if this fails in 6 months, the most likely cause is: ...".
- **Self-critique in the same answer**: after generating, 2-4 lines on "where this draft is weakest; what a critic will challenge".
