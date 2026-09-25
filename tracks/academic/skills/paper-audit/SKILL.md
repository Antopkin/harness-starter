---
name: paper-audit
description: Unified paper audit for Chinese and English papers. Use when reviewing paper quality, pre-submission checks, or doing adversarial reviews.
metadata:
  category: academic-writing
  tags: [audit, review, paper, pdf, latex, typst, chinese, english, scoring, checklist]
  version: "2.0"
  last_updated: "2026-03-11"
argument-hint: "[paper.tex|paper.typ|paper.pdf] [--mode MODE] [--pdf-mode MODE] [--style STYLE] [--venue VENUE] [--previous-report PATH] [--llm-json PATH]"
allowed-tools: Read, Write, Glob, Grep, Bash(uv *), Task
---

# Paper Audit Skill v2.0

Unified academic paper auditing across formats (LaTeX, Typst, PDF) and languages (English, Chinese). Runs automated checks, computes dimension scores, and optionally dispatches multi-perspective review agents.

---

## Capability Summary

- Run automated paper checks across `.tex`, `.typ`, and `.pdf` inputs.
- Produce self-check, peer-review, gate, polish, and re-audit outputs with explicit severity and priority labels.
- Combine script findings, venue-specific checklist items, and optional agent synthesis into one report flow.
- Reuse sibling writing-skill scripts for LaTeX and Typst inputs instead of re-implementing duplicate checks.

## Triggering

Use this skill when the user wants to:

- run a pre-submission readiness audit
- simulate a reviewer-style critique
- make a pass/fail submission gate decision
- compare a revised paper against a previous audit
- audit a PDF when the source format is unavailable

Trigger it even when the user only says “check my paper”, “review this submission”, “is this ready to submit?”, or “re-audit against the old report”.

## Do Not Use

- fixing the paper source as the first step when the project still fails to compile badly
- full literature research or survey drafting
- writing a paper from scratch
- template-specific LaTeX or Typst editing when the user wants direct source surgery instead of an audit report

## Critical Rules

- **NEVER** modify `\cite{}`, `\ref{}`, `\label{}`, math environments, or any content listed in `$SKILL_DIR/references/FORBIDDEN_TERMS.md`
- **NEVER** fabricate bibliography entries; only verify existing `.bib` or `.yml` files
- **NEVER** change domain terminology without explicit user confirmation
- **ALWAYS** distinguish `[Script]` (automated) findings from `[LLM]` (agent judgment) assessments in output
- All dimension scores from scripts are **indicators**, not definitive judgments

---

## Mode Selection Guide

| Mode | When to Use | Output | Speed |
|------|-------------|--------|-------|
| `self-check` | Pre-submission readiness check | Scores + issues + checklist | ~30s |
| `review` | Simulate multi-perspective peer review | Agent review reports + synthesis + revision roadmap | ~2min |
| `gate` | CI/CD quality gate, binary pass/fail | PASS/FAIL verdict + blocking issues | ~15s |
| `polish` | Expression refinement via agents | Precheck JSON + Critic/Mentor agent dispatch | ~1min+ |
| `re-audit` | Verify revisions against prior report | Verification checklist + new issues + score delta | ~1min |

### Mode Selection Logic

```
"Check my paper"                         -> self-check
"Review my paper" / "peer review"        -> review
"Is this ready to submit?"               -> gate
"Polish the writing"                     -> polish
"Did I fix the issues?" / "re-check"     -> re-audit
```

---

## Steps

### All Modes (Common)

1. Parse `$ARGUMENTS` for file path and mode. If missing, ask the user for the target `.tex`, `.typ`, or `.pdf` file.
2. Read `$SKILL_DIR/references/REVIEW_CRITERIA.md` for scoring framework.
3. Read `$SKILL_DIR/references/CHECKLIST.md` for universal + venue-specific checklist items.
4. Run the orchestrator: `uv run python -B "$SKILL_DIR/scripts/audit.py" $ARGUMENTS`.
5. Present the Markdown report directly to the user.

### Self-Check Mode

6. Review scores and highlight any Critical/P0 issues that block submission.
7. If `--scholar-eval` is present, read `$SKILL_DIR/references/SCHOLAR_EVAL_GUIDE.md`, formulate LLM assessments for Novelty, Significance, Ethics, and Reproducibility, and hand them to the orchestrator in the same run:
   - Write the four assessments to `/abs/path/llm_scores.json` in the shape given under the "LLM Evaluation JSON Format" section of `$SKILL_DIR/references/SCHOLAR_EVAL_GUIDE.md`: exactly the keys `novelty`, `significance`, `reproducibility_llm` and `ethics`, each an object `{"score": <float 1-10>, "evidence": "<string>"}`. The reproducibility key carries the `_llm` suffix; `reproducibility` without it is ignored.
   - Run the audit once, passing that file with an absolute path — the 8-dimension report is part of this single command's output:
     `uv run python -B "$SKILL_DIR/scripts/audit.py" <paper> --mode self-check --scholar-eval --llm-json /abs/path/llm_scores.json`
   - A missing or malformed `llm_scores.json` is not fatal: the run prints `[audit] ScholarEval: failed — …` and falls back to the ordinary 4-dimension report, so confirm the ScholarEval table is there before reading scores from it.
   - Only when the audit JSON already exists and you do not want to re-run the checks, merge into it instead with `uv run python -B "$SKILL_DIR/scripts/scholar_eval.py" --audit-json /abs/path/audit_result.json --llm-json /abs/path/llm_scores.json`.

### Review Mode (Multi-Perspective)

6. Read `$SKILL_DIR/references/SCHOLAR_EVAL_GUIDE.md` for LLM assessment dimensions.
7. Read `$SKILL_DIR/references/quality_rubrics.md` for scoring anchors and decision mapping.
8. **Phase 0** (automated): The script output provides automated findings and scores.
9. **Phase 1** (agents): For each agent in `$SKILL_DIR/agents/`:
   - Read the agent definition file for persona and protocol.
   - Dispatch a `Task` with: agent definition + paper content + Phase 0 results as context.
   - Agents: `methodology_reviewer_agent.md`, `domain_reviewer_agent.md`, `critical_reviewer_agent.md`.
10. **Phase 2** (synthesis): Read `$SKILL_DIR/agents/synthesis_agent.md` and dispatch a `Task` to consolidate all reviews.
    - Input: Phase 0 automated results + Phase 1 agent reviews.
    - Output: Consensus classification, merged scores, final review report, revision roadmap.
11. Read `$SKILL_DIR/templates/review_report_template.md` for output structure.
12. Present synthesized report following the template format.

**Output language:** the language of the user's request for every free-text field and for the report shown to the user, named explicitly in every Task prompt of this section rather than left to the agent to infer; quotations from the paper and any replacement text proposed for it stay in the paper's language; JSON keys, section headings, severity labels and the `[Script]`/`[LLM]` tags stay English in both cases so the templates and the script output line up. **Length cap:** the cap each agent definition file states for the free-text fields inside its JSON — 600 words for the methodology and domain reviewers, 800 words for the critical reviewer, whose counter-argument keeps its own 200-300 words — and at most 2000 words for the Phase 2 synthesis plus the roadmap table, a cap that has to cover the ~700 words of scaffolding the review report template itself carries. **Return shape:** each Phase 1 reviewer returns the JSON object defined under "Output Format" in its own agent definition file (`reviewer`, `scores`, and that file's remaining named keys); Phase 2 and the report presented to the user follow `$SKILL_DIR/templates/review_report_template.md`. This governs every dispatch in this section.

### Gate Mode

6. Report PASS or FAIL based on: zero Critical issues AND all checklist items pass.
7. List blocking issues (Critical only) and failed checklist items.

### Polish Mode

6. Read `.polish-state/precheck.json` generated by the script. It is written in the directory of the paper file — `<paper-dir>/.polish-state/precheck.json` — not next to the skill and not in the working directory.
7. If blockers detected, report them and ask user to resolve before polishing.
8. Read `$SKILL_DIR/references/POLISH_GUIDE.md` for style targets and critic protocol.
9. Spawn nested tasks for the Critic Agent and Mentor Agents as defined in the polish workflow.

**Output language:** the language of the user's request for issues, rationale and anything else the user reads, and the paper's language for the original spans and proposed rewrites that go into the paper, both named explicitly in each nested Task prompt; scores and field names stay English. **Length cap:** at most 800 words per Critic return, and at most 1500 words per Mentor return — a section reaches the Mentor at 1200 words or fewer (`POLISH_GUIDE.md` splits anything longer), and each proposed rewrite is quoted beside its original. **Return shape:** the Critic returns `logic_score`, `blocks_mentor` and `top_issues` as defined in `$SKILL_DIR/references/POLISH_GUIDE.md`, plus `expression_score`, which that guide does not define — its 1-5 range comes from `$SKILL_DIR/scripts/report_generator.py`; the Mentor returns, per issue, the original span, the proposed rewrite and one line of rationale, never a rewritten paragraph without its original. This governs both nested tasks in this section.

### Re-Audit Mode

6. Requires `--previous-report PATH` pointing to a prior audit report.
7. Script runs fresh checks and compares against previous findings.
8. Present verification checklist: each prior issue classified as `FULLY_ADDRESSED` / `PARTIALLY_ADDRESSED` / `NOT_ADDRESSED`.
9. Report any `NEW` issues introduced during revision.
10. Show score comparison (before vs after).

## Required Inputs

- A target `.tex`, `.typ`, or `.pdf` file.
- An audit mode, or enough intent to infer one from the mode-selection guide.
- Optional `--venue` context when the checklist should be venue-specific in `self-check`, `review`, `gate` or `re-audit`; `--journal` is a polish-mode-only label — it is recorded in `.polish-state/precheck.json` and shown as the venue line of the polish report, and it selects no checks.
- Optional `--previous-report PATH` for `re-audit`.

If the user omits the mode, infer it using the selection guide and state the assumption before running the audit.

## Output Contract

- Always return a report, not raw script output.
- Keep `[Script]` and `[LLM]` findings visibly separated.
- Include the selected mode, target file, and venue context near the top of the report.
- For blocking failures, list the exact blocking issue(s) and failed checklist items first.
- When a script or nested agent step fails, report the command, exit code, and what coverage was skipped.
- Preserve the source; this skill audits and synthesizes, it does not rewrite the paper by default.

---

## Venue-Specific Behavior

When `--venue` is specified, the audit adds venue-specific checks in `self-check`, `review`, `gate` and `re-audit` mode — those four are the modes that reach the checklist. Polish mode reads neither flag for checks: it dispatches to `run_polish_precheck` before the checklist runs, and that function takes no venue parameter, so `--venue --mode polish` silently produces zero venue checks. The two flags are not interchangeable: only `--venue` reaches the checklist and the venue configuration, while `--journal` travels through the polish branch alone (its own help text reads "Target journal/venue for polish mode"), where it does exactly two things — it is stored under the `journal` key of `.polish-state/precheck.json`, and it supplies the venue label printed near the top of the polish report. It selects no check in any mode. The six valid `--venue` keys:

| Venue | Key Rules |
|-------|-----------|
| `neurips` | 9-page limit, broader impact statement, paper checklist, double-blind |
| `iclr` | 10-page limit, reproducibility statement, double-blind |
| `icml` | 8-page limit, impact statement, 50MB supplementary limit |
| `ieee` | Abstract <=250 words, 3-5 keywords, >=300 DPI figures |
| `acm` | CCS concepts required, acmart class, rights management |
| `thesis-zh` | GB/T 7714-2015 bibliography, bilingual abstract, university template |

Without `--venue`, only universal checklist items apply.

---

## Output Protocol

### Issue Format
```
[Severity: Critical|Major|Minor] [Priority: P0|P1|P2]: message (Line N)
```

### Severity Definitions
| Severity | Impact | Score Deduction (4-dim) |
|----------|--------|----------------------|
| Critical | Blocks submission | -1.5 per issue |
| Major | Significant quality concern | -0.75 per issue |
| Minor | Style/formatting improvement | -0.25 per issue |

### Source Labeling
- `[Script]` — Automated check result (objective, reproducible)
- `[LLM]` — Agent/LLM judgment (subjective, evidence-based)

---

## Scoring Systems

### 4-Dimension Score (1.0-6.0, base 6.0 with deductions)
| Dimension | Weight | Primary Checks |
|-----------|--------|---------------|
| Quality | 30% | logic, bib, gbt7714 |
| Clarity | 30% | format, grammar, sentences, consistency, references, visual, figures |
| Significance | 20% | logic, checklist |
| Originality | 20% | deai, checklist |

### 8-Dimension ScholarEval (1.0-10.0, optional via `--scholar-eval`)
| Dimension | Weight | Source |
|-----------|--------|--------|
| Soundness | 20% | Script |
| Clarity | 15% | Script |
| Presentation | 10% | Script |
| Novelty | 15% | LLM |
| Significance | 15% | LLM |
| Reproducibility | 10% | Mixed |
| Ethics | 5% | LLM |
| Overall | 10% | Computed |

See `$SKILL_DIR/references/quality_rubrics.md` for score-level descriptors and decision mapping.

---

## Integration with Sibling Skills

Paper-audit reuses check scripts from sibling skills via format-based routing:

| Format | Script Source | Checks Available |
|--------|-------------|-----------------|
| `.tex` (English) | `latex-paper-en/scripts/` | format, grammar, logic, sentences, deai, bib, figures |
| `.tex` (Chinese) | `latex-paper-en/scripts/`; the `latex-thesis-zh` primary is not installed here | format, grammar, logic, sentences, deai, bib, figures; consistency and gbt7714 come from `latex-thesis-zh` and are skipped without it |
| `.typ` | no sibling source resolves; `typst-paper` is not installed here | format, grammar, logic, sentences and deai come from `typst-paper` and are skipped without it |
| `.pdf` | `paper-audit/scripts/` only | visual, pdf_parser (no format/bib/figures checks) |

Scripts that live in paper-audit itself: `audit.py`, `check_citations.py`, `check_references.py`, `visual_check.py`, `pdf_parser.py`, `detect_language.py`, `parsers.py`, `report_generator.py`, `scholar_eval.py`.

---

## Agent References

| Agent | Definition File | Role |
|-------|----------------|------|
| Methodology Reviewer | `$SKILL_DIR/agents/methodology_reviewer_agent.md` | Research design, statistical rigor, reproducibility |
| Domain Reviewer | `$SKILL_DIR/agents/domain_reviewer_agent.md` | Literature coverage, theoretical framework, contribution |
| Critical Reviewer | `$SKILL_DIR/agents/critical_reviewer_agent.md` | Core argument challenges, logical fallacies, overclaims |
| Synthesis Agent | `$SKILL_DIR/agents/synthesis_agent.md` | Consolidate reviews, consensus classification, revision roadmap |
| — (not an agent prompt) | `$SKILL_DIR/agents/openai.yaml` | Interface metadata: display name, short description, default prompt |

---

## Reference Files

| Reference | Purpose | Used By |
|-----------|---------|---------|
| `references/REVIEW_CRITERIA.md` | 4-dimension scoring framework | All modes |
| `references/CHECKLIST.md` | Universal + venue-specific checklists | self-check, gate |
| `references/SCHOLAR_EVAL_GUIDE.md` | 8-dimension ScholarEval scoring guide | review (with --scholar-eval) |
| `references/quality_rubrics.md` | Score-level descriptors and decision mapping | review, self-check |
| `references/AUDIT_GUIDE.md` | User guide for modes and report interpretation | Reference |
| `references/POLISH_GUIDE.md` | Style targets and critic/mentor protocol | polish |
| `references/FORBIDDEN_TERMS.md` | Protected content (citations, math, terminology) | All modes |
| `references/QUICK_REFERENCE.md` | Check support matrix and CLI quick reference | Reference |
| `references/editorial_decision_standards.md` | Consensus rules and decision matrix | review (synthesis) |

## Example Requests

- “Run a self-check on `paper.tex` and tell me what blocks submission.”
- “Review this paper like a harsh reviewer and give me a revision roadmap.”
- “Is `paper.pdf` ready to submit to IEEE, or does it fail the gate?”
- “Re-audit this revision against my previous report and tell me which issues are still open.”

## Templates

| Template | Purpose |
|----------|---------|
| `templates/audit_report_template.md` | Output structure for self-check/gate |
| `templates/review_report_template.md` | Output structure for multi-perspective review |
| `templates/revision_roadmap_template.md` | Prioritized revision action plan |

---

## Quality Standards

| Dimension | Requirement |
|-----------|-------------|
| Evidence-based | Every weakness must cite specific text, line, or section from the paper |
| Specificity | Avoid vague comments; provide exact locations and concrete suggestions |
| Balance | Report both strengths and weaknesses; never only criticize |
| Actionability | Each issue must include a specific improvement suggestion |
| Source transparency | Always label findings as [Script] or [LLM] |
| Format consistency | All reports follow the corresponding template structure |
| Constructive tone | Professional and helpful; avoid dismissive language |

---

## Examples

### Self-Check
```bash
uv run python -B "$SKILL_DIR/scripts/audit.py" paper.tex --mode self-check
uv run python -B "$SKILL_DIR/scripts/audit.py" paper.tex --mode self-check --venue neurips
```

### Review (Multi-Perspective)
```bash
uv run python -B "$SKILL_DIR/scripts/audit.py" paper.tex --mode review --scholar-eval
```
Then follow Steps 8-12 to dispatch review agents.

### Gate (CI/CD)
```bash
uv run python -B "$SKILL_DIR/scripts/audit.py" paper.tex --mode gate --venue ieee --format json
```

### Polish
```bash
uv run python -B "$SKILL_DIR/scripts/audit.py" paper.tex --mode polish
```

### Re-Audit
```bash
uv run python -B "$SKILL_DIR/scripts/audit.py" paper.tex --mode re-audit --previous-report report_v1.md
```

### PDF Input
```bash
uv run python -B "$SKILL_DIR/scripts/audit.py" paper.pdf --mode self-check --pdf-mode enhanced
```

See `$SKILL_DIR/examples/` for complete output examples.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No file path provided | Ask user for a valid `.tex`, `.typ`, or `.pdf` file |
| Script execution fails | Report the command, exit code, and stderr output |
| Missing sibling skill scripts | Only `latex-paper-en/scripts/` is installed here; `latex-thesis-zh` and `typst-paper` are absent, so the checks they own are skipped rather than failing |
| PDF checks limited | PDF mode skips format/bib/figures checks; only visual and content analysis available |
| `--venue` not recognized | Use one of: `neurips`, `iclr`, `icml`, `ieee`, `acm`, `thesis-zh` |
| ScholarEval LLM dimensions show N/A | Re-run the audit with your scores attached: `--scholar-eval --llm-json /abs/path/llm_scores.json` (see Self-Check step 7). Still N/A means the file was unreadable or the keys were wrong — the reproducibility key must read `reproducibility_llm` |
| Re-audit missing previous report | Provide `--previous-report PATH` pointing to the prior audit output |

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2026-03-11 | Full rewrite: venue filtering, multi-perspective review agents, re-audit mode, templates, examples, quality rubrics |
| 1.0 | 2026-03 | Initial version: 4 modes, script-based audit, 4-dim + 8-dim scoring |
