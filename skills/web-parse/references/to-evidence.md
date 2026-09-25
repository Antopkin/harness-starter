# Layer 2 adapter: projecting a capture into a digest table for the memo

An **optional** step. The native capture `capture.md` (layer 1) is self-sufficient.
This adapter runs **only when the capture goes into a memo**: then the chosen items are
projected into the digest's 5-column evidence table, and the result drops into the
`write-from-digests` pool as a source `[S<n>]` with no separate converter.

The table shape, the role of the locator, anti-hallucination and the self-check
protocol are shared with digest: see [the digest skill](../../digest/SKILL.md) and
[its output template](../../digest/references/OUTPUT-TEMPLATE.md). This file covers
only the projection rule "capture item → table row".

## What gets projected

Not the whole capture, but **only the items you rely on in the memo** (the ones you
quote or paraphrase). The rest stay in `capture.md` as context. Every chosen item →
one row. One item = one atomic claim; if a post makes two different statements, that
is two rows for one locator.

## The projection rule (column → source)

| Digest column | Filled from the capture with |
|---|---|
| **Claim** | the anonymised gist of the item in your own words (a paraphrase, without names or nicknames): what will go into the memo |
| **Locator** | `url + post#` from the capture (the item's permalink + its sequence number) |
| **Verbatim quote** | the verbatim text from the `<untrusted>` block, marked **"paraphrase in the memo"**: an evidence trail that is not carried into the memo itself |
| **Section** | the item type from the capture (`post` / `comment` / `thread node` / `wall post`) |
| **Verified** | `✓` after reopening the locator, otherwise `⚠ not confirmed` |

An example row:

```
| Users complain about slow builds after the update | forum.example.org/t/42#c3 · Item 3 | "after the update the build takes three times longer…" (paraphrase in the memo) | comment | ✓ |
```

## Self-check: reopen the locator and confirm

A separate pass, independent of the capture (checking "from memory" does not count),
mirroring the digest self-check, but with the same browser reading tool as during
the capture:

1. **Reopen the locator**: `open <item url>` in the logged-in tab, expand the branch
   or scroll to the item if needed, `snapshot -i` + `get text` (see
   `platform-notes.md`).
2. **Find the verbatim quote** in the reopened text. Normalisation tolerance:
   whitespace, line breaks and emoji variants are fine; rephrasing or word
   substitution is not.
3. **Set "Verified":** found verbatim → `✓`; not found, the text was edited or deleted
   by its author, or the item vanished → `⚠ not confirmed`, and all certainty is
   removed from the claim. Captures of social content are especially volatile (a post
   may have been deleted or edited); record that honestly, do not force a fit.
4. Below the table, a **self-check log**: N rows, N ✓, N ⚠, which locators were
   actually reopened and how.

**Do not hand over a table with unresolved `⚠` as finished**: either `✓`, or the claim
moves to the gaps. This protects against false-green marks (the same discipline as in
digest).

## Privacy outweighs evidentiality

digest pulls the verbatim quote **into the text** of the digest; here it does not.
Anonymisation (personal-data law, AoIR) is stronger: the verbatim text of a post lives
**only** in the "Verbatim quote" column as a trail, marked "paraphrase in the memo",
and **only inside the working file**. The memo itself gets the "Claim" column (a
paraphrase without names), not the quote. The framework is in
[ethics-checklist.md](ethics-checklist.md).

## Anti-hallucination (inherited from digest)

- No locator, no row. An item without a usable permalink does not get a fictitious
  anchor.
- No statement in the text → "not stated", not a guess. Do not add what the post does
  not say.
- The author's voice and your own conclusion are different rows; mark your own
  explicitly.
