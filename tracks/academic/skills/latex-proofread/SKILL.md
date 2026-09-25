---
name: latex-proofread
description: "Two-phase proofreading of LaTeX papers. Phase 1 audits the infrastructure (preamble, macros, cross-references, citations, figures). Phase 2 reviews the content (grammar, scientific clarity, narrative, notation). Based on LimHyungTae/awesome-claudecode-paper-proofreading."
metadata:
  version: "1.0"
  last_updated: "2026-03-14"
  source: "https://github.com/LimHyungTae/awesome-claudecode-paper-proofreading"
---

# LaTeX Paper Proofreading — Two-Phase Audit

A strict two-phase proofread of LaTeX papers aimed at venues such as ICRA, RSS, NeurIPS, T-RO and CVPR.

## Quick start

```
/latex-proofread main.tex
/latex-proofread main.tex --phase 1     # infrastructure only
/latex-proofread main.tex --phase 2     # content only
```

## Triggers

Use this skill when the user wants to:
- check a LaTeX paper before submission
- find errors in the preamble, macros or citations
- proofread the text for grammar, clarity and notation
- check the workspace for hidden errors (TODOs, placeholders)

Keywords: proofread, proofreading, check the paper, latex proofread, check paper, review tex

## Do NOT trigger

| Scenario | Use instead |
|---|---|
| Fix compilation errors from the .log | `/latex-fix` |
| Write a paper | `/academic-paper` |
| Review a paper (academic peer review) | `/academic-paper-reviewer` |
| Quality audit (scoring) | `/paper-audit` |

---

## Workflow

### Preparation (before both phases)

1. Read the root `.tex` file
2. Find every `\input{...}` and `\include{...}` recursively
3. Read all included files (`sections/*.tex`, `shortcuts.tex`, `preamble.tex`, and so on)
4. Read every `.bib` file named in `\bibliography{...}`
5. Do all of this silently, before producing any output

### Phase 1 — LaTeX workspace infrastructure audit

> **Do NOT modify files during Phase 1. Only detect and report.**

#### Checks (C1-C9)

| # | Check | Description |
|---|---|---|
| C1 | Preamble | Duplicate, conflicting, unused or missing packages. cleveref, hyperref, caption, math packages |
| C2 | Package order | hyperref → cleveref, amsmath → mathtools, xcolor → tikz, caption → subcaption |
| C3 | Macros | \methodname without \xspace, duplicates, name clashes, \etalcite, subscript consistency |
| C4 | Cross-references | Mixed \Cref/\cref/\ref, hand-written "Fig.", multiple references |
| C5 | Label naming | Prefixes fig:/tab:/eq:/sec:/alg:, duplicates, unused and broken labels |
| C6 | Citations and bibliography | \cite without a .bib entry, duplicate keys, BibTeX quality, ~\cite{} |
| C7 | Figures and tables | Missing files, placeholders, absolute paths, \label position |
| C8 | Hidden errors | TODO/XXX/FIXME, inconsistent names, boilerplate content, \vspace hacks |
| C9 | Academic writing | Units (\,), thousands separators, et al., \ie/\eg, state-of-the-art, acronyms |

#### Phase 1 output format

```
**`file.tex`**
[N]  L.XX   Problem description | Suggestion

CRITICAL
  [N]  File — short description
MAJOR
  [N]  File — short description
MINOR / STYLE
  [N]  File — short description

Infrastructure Suggestions:
- ...
```

**Output language:** the language of the user's request, with academic terminology kept in English. **Length cap:** at most 600 words. **Return shape:** the "Phase 1 output format" block above — the per-file list, the CRITICAL / MAJOR / MINOR / STYLE groups and the Infrastructure Suggestions; the rule applies to every check C1-C9.

### Phase 2 — Content review

> **Do NOT rewrite the text. Only detect and report.**

Persona: a strict reviewer at the level of ICRA, RSS, NeurIPS, T-RO or CVPR.

#### Categories (A-I)

| # | Category | Description |
|---|---|---|
| A | Language and grammar | Subject-verb agreement, tense consistency, passive voice, Oxford comma |
| B | Language quality | Typos (CRITICAL), nominalisation, filler expressions, citation-as-noun |
| C | Scientific clarity | Overclaiming, causal gaps, unsupported limitations, undefined symbols |
| D | Structure and flow | Introduction, Related Work, Methodology, Experiments — a full check |
| E | Figures, tables, captions | Self-contained captions, bold/underline convention, reference order |
| F | LaTeX formatting | Thin spaces, thousands separators, consistent references, \ie/\eg macros |
| G | Abstract and Conclusion | WHY→PROBLEM→HOW→RESULTS, no citations in the abstract, a single paragraph |
| H | Notation consistency | Symbol overload, boldface vectors, coordinate frame notation |
| I | Hyphenation | Compound adjectives, the -ly adverb rule, context-dependent checks |

#### Phase 2 output format

```
Paper quality: GOOD / NEEDS REVISION / MAJOR REVISION

| Type     | Count |
|----------|-------|
| CRITICAL |       |
| MAJOR    |       |
| MINOR    |       |
| STYLE    |       |

[Full list by file]
[Grouping by severity]
[Caption Review]
[LaTeX Formatting Patterns]
[Optional Polishing Suggestions]
```

**Output language:** the language of the user's request, with academic terminology kept in English. **Length cap:** at most 800 words. **Return shape:** the "Phase 2 output format" block above — the Paper quality verdict, the count table, the full list by file, the grouping by severity, Caption Review, LaTeX Formatting Patterns and Optional Polishing Suggestions; the rule applies to every category A-I.

---

## Fix phase — after both phases

Once every problem has been reported, wait for the user's decision:

- `fix safe` — only unambiguous typos and grammar errors
- `fix all critical` — only CRITICAL items
- `fix all` — every suggested fix
- `fix [numbers]` — specific problems (for example `fix 1, 3, 5`)
- `discard [numbers]` — skip specific problems

**Do NOT modify files until the user confirms.**

### Fix rules

- **No em dashes** (`—`) — replace them with a comma, semicolon or colon, or restructure the sentence
- Do not add constructions that read as AI-generated

---

## Severity Levels

| Level | Meaning |
|---------|---------|
| CRITICAL | Fix before submission |
| MAJOR | A significant clarity or correctness problem |
| MINOR | Grammar or wording |
| STYLE | An optional improvement |

---

## Output language

Follow the language of the user's request. Academic terminology stays in English.
