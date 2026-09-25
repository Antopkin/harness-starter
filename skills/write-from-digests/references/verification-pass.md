# Backward verification pass: a checklist

This pass runs **after the memo is written**, as a separate stage. Checking "while
writing" does not count: it degenerates into checking from memory. Here we go the
other way, from the finished text back to the source, and catch exactly what writing
lets slip: an anchor to a row that does not exist, a quote "improved" along the way, a
number attributed to the wrong paper.

The tool is portable: the agent re-reads the same files itself, plus a deterministic
`grep -F`. No external scripts and no Python inside the skill's logic.

## The chain for checking one quote

For **every** verbatim quote in the memo, walk the whole chain without cutting
corners:

1. **Text → anchor.** Does the quote carry an anchor `[S<n>.<row>]`? No anchor means a
   G1 violation: add the anchor or remove the claim from the body.
2. **Anchor → pool row.** Open the evidence table of source `S<n>` and find row
   `row`. Does it exist? Is it marked ✓ (not ⚠)? Does the quote in the text match the
   quote in that row?
3. **Pool row → digest at the locator.** Take the locator from the row (PDF `p. N`;
   docx `§section, para. N`; md/txt `line N`) and **re-open that place in the digest
   itself** with the same recipe `digest` uses: re-read the page/section/line range.
   Is the quote there?
4. **grep -F (gate G2).** Run the deterministic verbatim check:

   ```
   grep -F "exact quote without the surrounding quotation marks" path/to/source-digest.md
   ```

   Exit code 0 (the line was found) → the quote is verbatim. `grep -F` treats the
   pattern as a fixed substring, so the match is honest, not rewritten.
5. **Digest → original source (where possible).** If the paper's source file is still
   available, re-open the locator in it as well. That is the top rung of trust; if the
   source is unavailable, stop at the digest, but note in the log that the check did
   not go past the digest.

## What to do on a mismatch

Normalisation tolerance as in `digest`: differences only in whitespace, line breaks,
hyphenation and ligatures are fine. Swapped words, paraphrase or "improved" wording
are **not** fine.

If a quote is not found verbatim (step 4 returned non-zero or the text differs):

- **hedge**: weaken the claim to what the evidence actually supports, and drop the
  anchor to what was not found; **or**
- **delete**: remove the claim.

**Never:** repair a quote from memory, bend the text to fit the quote, invent a
locator. You fix **the claim**; you never bend the quote. Each such case is a line in
the verification log (what was weakened or deleted, and why).

## A look back

While a locator is open, also check the reverse direction: is there a significant
statement nearby in the source that contradicts the memo's thesis or matters for the
conclusion but did not make it into the memo? If so, either take it into account in
the argument or name it honestly in "The limits of this conclusion".

## Anchor coverage (gate G1)

In a separate walk through the argument's paragraphs, make sure **every**
load-bearing claim (a factual statement, not a connective) carries at least one
anchor `[S<n>.<row>]`. Zero claims without an anchor. A statement with no row behind
it in the pool is not a fact: move it into a caveat or into "The limits of this
conclusion".

## Building the verification log

When the pass is done, put a summary into the memo's Appendix A:

- **Anchors in the text:** how many in total, and how many distinct pool rows they
  point to.
- **Verbatim quotes checked:** how many out of how many; every `grep -F` = found.
- **⚠ flags:** how many; if not zero, list what was weakened or deleted.
- **Method:** which locators were actually re-opened and how; that `grep -F` was run
  on every quote. This is the only protection against false-green ✓.

A memo with unresolved ⚠ is not handed over as finished: either ✓, or the claim is
weakened or deleted.
