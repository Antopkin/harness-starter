---
name: write-from-digests
description: >
  Writes a coherent authored memo from finished digest files, a "mini-memo with an
  evidence base" (600-900 words, conclusion first), in which every load-bearing
  claim is tied by an anchor such as [S1.3] to a row of a specific digest's
  evidence table, and verbatim quotes are copied from the digests, never recalled
  from memory. After writing comes a separate backward verification pass: text →
  anchor → pool row → digest at the locator, with a deterministic grep -F of every
  quote in the source digest. A quote that is not found verbatim means the claim is
  weakened or deleted, never "repaired from memory". Output in the language of the
  user's request, as Markdown or Word. Portable, no Python scripts.
  Triggers: "write a memo from these digests", "mini-memo with an evidence base",
  "combine the digests into a memo", "write-from-digests". NOT: digesting one paper
  from scratch (digest); NOT: finding literature or a review without an authored
  conclusion (lit-search).
---

# write-from-digests: an evidence-based memo from digests

The skill takes N finished `digest.md` files and writes **one coherent authored
memo** from them: the conclusion first, then the argument, where every load-bearing
claim is tied to a row of an evidence table, and an appendix holds the whole evidence
base and the references. The memo's reader is not technical: the agent **produces**
the text, while the user sets the task, steers and judges. What sets the skill apart
from free writing is that **no load-bearing claim hangs without an anchor to a
specific verbatim quote**, and after writing a separate backward pass re-checks that
binding.

Place in the chain: `digest` digests each paper on its own (anchor table +
reference) → **`write-from-digests` (this skill) combines several such digests into a
memo with a conclusion**. A combined literature review without an authored
recommendation is `lit-search`, a different skill.

The input is always `digest.md` (no prose or JSON input is needed: the evidence pool
is already inside each digest). The target output shape is in
`references/OUTPUT-TEMPLATE.md` (it is the canon; do not duplicate it). A fully
worked example on two real digests is in `references/EXAMPLE-zapiska.md`. The
detailed checklist for the backward pass is in `references/verification-pass.md`.

## What is reused and what is our own

The skill is **thin** and takes from writing practice only the load-bearing parts,
without academic trappings:

- **CER** (Claim–Evidence–Reasoning) is the frame of every claim: the claim →
  evidence from the pool → reasoning on why the evidence supports the claim.
- **The TEEL paragraph** (Topic → Evidence → Explanation → Link) is the shape of a
  load-bearing paragraph; Evidence is a verbatim quote copied from the pool.
- **Authorial voice and hedging**: careful "apparently", "in the available fragment"
  wherever the evidence is weaker than the claim.
- **The orphan check and the "no quote in the source → STOP" rule** come from the
  discipline of quote checking: a claim without an evidence row does not reach the
  text.

What is **deliberately absent**: an eight-phase IMRaD, word targets per section,
disciplinary registers, a bilingual abstract, review scoring, counter-argument
rounds, a LaTeX/DOCX formatter. This is not a paper but a short memo.

Our own, found neither in `digest` nor in the writing skills:

- **The `[S<n>.<row>]` anchor scheme.** `<n>` is the source number (S1, S2, …),
  `<row>` the row number in that source's evidence table. Numbering is **per source,
  starting at 1**, in the order the rows appear in the digest. The agent adds an id
  column to the table as the **first** column (`#` = `S<n>.<row>`); an anchor in the
  text points to exactly that id. Deterministic and checkable.
- **An end-to-end backward verification pass**, run as a separate stage AFTER writing
  (not along the way): text → anchor → pool row → digest at the locator → the
  original source where possible.
- **A single verification log for the memo**: a ✓/⚠ summary at the level of the whole
  memo.

## Anchor scheme: how to number

1. Give each digest a source number: S1, S2, … in the order the user gave, otherwise
   in the order of the input files.
2. Within a source, number the rows of its "Claims anchored to the source" table from
   top to bottom, starting at 1. A ⚠ row (not confirmed in the digest itself) is
   **not usable as evidence**: only ✓ rows go into the pool.
3. A row's id is `S<n>.<row>`. Example: `S1.5` is the fifth row of the first
   source's table; `S2.7` the seventh row of the second. The memo's evidence pool is
   the union of the ✓ rows of all sources with their ids.

An anchor in the text is `[S<n>.<row>]`, exactly that id. Several sources behind one
claim means several anchors in a row: `[S1.4][S2.8]`.

## Workflow

Order matters: checking comes **after** writing, as a separate pass, or it
degenerates into checking "from memory".

1. **Input and validation.** Read the N digests. Make sure each has an anchor table
   with every ⚠ resolved (that is what `digest` guarantees). Do not take ⚠ rows into
   the pool.
2. **Anchor numbering.** Assign S1…SN and number each source's ✓ rows → you get an
   evidence pool with ids `S<n>.<row>` (see above).
3. **Narrative before writing**: if the `writing-guru` skill is available, use it to
   choose a narrative strategy for the memo (conclusion first, non-technical
   audience). Without it, lead with the conclusion in the first paragraph yourself.
4. **Outline.** State the thesis-recommendation and **at least 3 load-bearing
   claims**. Tie each claim to **at least 1 evidence id** from the pool (CER: the
   claim ← the row that holds it up). A claim with no usable row in the pool **is not
   taken** into the outline: it goes into a caveat or into "Gaps", but never into the
   body as a fact.
5. **TEEL paragraphs.** Write each load-bearing paragraph as TEEL. Evidence is **a
   verbatim quote copied (copy-paste) from the pool row**, not reconstructed from
   memory. Give the quote **as a separate sentence** from your interpretation; if the
   memo's language differs from the quote's, add a translation next to it marked
   "tr.". End the claim with the anchor `[S<n>.<row>]` of the quote's source row.
6. **Backward verification pass** (a separate stage, after the text is written). For
   every anchor and every quote, walk the chain text → anchor → pool row → digest at
   the locator. The detailed checklist is `references/verification-pass.md`.
7. **Verification log.** Build the summary: how many anchors, how many quotes checked
   verbatim, how many ⚠. A memo with unresolved ⚠ is not handed over as finished.
8. **Polish.** For a Russian memo, a final pass through `ru-text` **after** the fact
   check; for other languages, a separate language proofread. Polishing **does not
   touch quotes or anchors**: you edit the authored text around them, and a verbatim
   quote stays verbatim.

## Rule: no quote in the pool → hedge or delete

If during the check a verbatim quote **is not found** in the pool (and, one level
deeper, in the digest at the locator), you have exactly two moves:

- **hedge**: weaken the claim to what the evidence actually supports ("apparently",
  "in the available fragment the authors claim") and drop the anchor to what was not
  found; or
- **delete**: remove the claim.

What you **must not** do: "repair the quote from memory", bend the text to fit the
quote, invent a locator. This is the same discipline as in `digest`: a gap is a
finding, not an invitation to make things up. You fix **the claim**; you never bend
the quote.

## G1–G2: the memo's gates

- **G1: anchor coverage.** Every load-bearing claim has an anchor `[S<n>.<row>]` to a
  table row. Zero load-bearing claims without an anchor. Checked by reading: walk the
  paragraphs; every factual statement must carry at least one anchor.
- **G2: verbatim quotes, deterministically.** Every pool row is a verbatim quote plus
  a locator that was re-opened (✓ in the digest itself). On top of the agent's ✓ comes
  **a reproducible gate anyone can rerun**: for every quote in the memo

  ```
  grep -F "exact quote without the surrounding quotation marks" path/to/source-digest.md
  ```

  Found (exit code 0) → the quote is verbatim. Not found → the "no quote → hedge/
  delete" rule. `grep -F` takes the string as a fixed substring (not a regex), so this
  is an honest deterministic check of verbatimness, not a rewrite. Normalisation
  tolerance as in `digest`: differences only in whitespace or line breaks are fine;
  swapped words are not.

The memo is ready when both gates pass: zero claims without an anchor (G1) and every
quote gives `grep -F` = found with zero ⚠ (G2).

## Artifact structure

The canon is `references/OUTPUT-TEMPLATE.md`. In short, the memo consists of:

1. **Thesis (recommendation)**: 3–5 sentences, the conclusion/recommendation first.
2. **Argument**: at least 3 load-bearing claims, each a TEEL paragraph with an anchor
   and a verbatim quote as a separate sentence.
3. **Appendix A, the evidence base**: for each source, its evidence table in `digest`
   format **with the `#` id column first** + its "Reference-list entry" (APA 7, plus
   GOST R 7.0.100-2018 where the digest has it) + `.bib`. All of it is taken from the
   digest itself, not rebuilt.
4. **Appendix B, into action**: a placeholder section for "before/after" screenshots
   of a filled-in form; it is filled by the `fill-form` skill, and here it only holds
   the place.

## Several sources and one conclusion

The memo **mixes sources on purpose**: it brings them into one conclusion but does
not confuse them; each quote shows its source (`S1`/`S2`) and its row. Do not
attribute a fact to the wrong paper: the `[S<n>.<row>]` anchor is exactly the
protection against swapped authorship. Each source carries its own evidence table and
its own reference in Appendix A, as a separate block.

## Output language

Write the memo and explanations in the language of the user's request. Keep quotes in
the original language and, if the memo's language differs, give a translation next to
them marked "tr.". Names, titles and DOIs stay as in the original.
