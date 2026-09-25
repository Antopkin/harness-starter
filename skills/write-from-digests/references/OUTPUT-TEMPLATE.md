# Target output shape: a memo with an evidence base

This is a **template**, not an example. Placeholders in angle brackets (`<thesis>`,
`<quote>`, `<locator>`) show the **shape** and must be replaced with real content
from the digests. Do not fill the template with invented text: that directly
contradicts the skill's anti-hallucination rules. A fully worked example on two real
digests sits next to this file, in `EXAMPLE-zapiska.md`.

Mandatory parts: the thesis-recommendation first; at least 3 load-bearing claims,
each with an anchor `[S<n>.<row>]` and a verbatim quote as a separate sentence;
Appendix A with evidence tables (the `#` id column first) and references (APA 7, GOST
where the digest has it, and .bib) for each source; a verification log with no
unresolved ⚠. Without them the memo is not finished.

This file is **the canon**. Materials that refer to the memo's shape point here
rather than rewriting it.

---

```
# Memo: <short name of the question/decision>

**Sources:** S1 — <Authors, year, short title>; S2 — <…>; … (one per digest)
**Input:** N digest.md files  ·  **Output:** <language of the request> · <Markdown | Word>
**Date:** <YYYY-MM-DD>

## 1. Recommendation (thesis)

<3–5 sentences: the conclusion/recommendation first. What is proposed and under which
condition; the key caveat. No anchors: this summarises the argument below.>

## 2. Argument

**<Load-bearing claim 1, one sentence heading the paragraph.>** <Topic: the claim
unfolded.> <Evidence, a verbatim quote as a separate sentence:> “<exact quote from the
pool>” (tr.: “<translation, only if the memo's language differs>”) [S<n>.<row>].
<Explanation: why the quote holds up the claim.> <Link: the bridge to the next one.>

**<Load-bearing claim 2.>** <Topic.> “<exact quote>” (tr.: “<translation>”)
[S<n>.<row>]. <Explanation.> <Link.>

**<Load-bearing claim 3.>** <Topic.> “<exact quote>” (tr.: “<translation>”)
[S<n>.<row>][S<m>.<row>]. <Explanation.> <Link.>

<If needed, "The limits of this conclusion": what the sources lack / what remains to be
checked. An honest caveat, not a new fact.>

---

## Appendix A. Evidence base

For each source, its evidence table from the digest with the `#` id column first,
then the ready-made references. Everything is taken from the digest itself, not
rebuilt.

### Source S1 — <Authors, year, short title>

| # | Claim | Locator | Verbatim quote | Section | Checked |
|---|---|---|---|---|---|
| S1.1 | <claim> | <locator> | “<quote>” | <section> | ✓ |
| S1.2 | … | … | “…” | … | ✓ |

**Reference-list entry (S1).**
APA 7: <APA line>
GOST R 7.0.100-2018: <GOST line, where the digest has it>

**Citation S1 (.bib).**
```bibtex
@<type>{<citekey>,
  ...
}
```

### Source S2 — <Authors, year, short title>

| # | Claim | Locator | Verbatim quote | Section | Checked |
|---|---|---|---|---|---|
| S2.1 | <claim> | <locator> | “<quote>” | <section> | ✓ |
| S2.2 | … | … | “…” | … | ✓ |

**Reference-list entry (S2).**
APA 7: <APA line>
GOST R 7.0.100-2018: <GOST line, where the digest has it>

**Citation S2 (.bib).**
```bibtex
@<type>{<citekey>,
  ...
}
```

### Verification log (backward pass)

- **Anchors in the text:** <N> (pointing to <K> distinct pool rows).
- **Verbatim quotes checked:** <M> of <M>; every `grep -F` in the source digest = found.
- **⚠ flags:** <0>. <If not 0, which claims were weakened/deleted under the
  "no quote → hedge/delete" rule.>
- **Method:** for each quote, `grep -F "<quote>" <source digest>` = found;
  locators re-opened (page/section/line). The check is portable: re-reading the same
  file and a deterministic `grep -F`, with no Python inside the skill's logic.

---

## Appendix B. Into action (fill-form placeholder)

The place for "before/after" screenshots of a filled-in form. It is filled by the
`fill-form` skill; here there is only the section for it.

- [ ] Screenshot: the form before it is filled in.
- [ ] Screenshot: the form after it is filled in.
- [ ] A short caption: which decision from the memo went into the form.
```

---

## How to read an anchor and the "Checked" column

- **`[S<n>.<row>]`** is the address of the evidence: source `n`, row `row` of its
  evidence table. Several anchors in a row mean several sources behind one claim.
- **✓** in the `#` table means the row was carried over from the digest, where the
  self-check already confirmed it, and was re-opened during the memo's backward pass.
  A ⚠ row is not taken into the pool.
- The check is **portable**: re-reading the same file by the agent plus a
  deterministic `grep -F` of the quote in the source digest. No external scripts and
  no Python.
