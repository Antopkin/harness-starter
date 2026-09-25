---
name: academic-paper-reviewer
description: "Multi-perspective review of a paper by an editor, three peer reviewers and a devil's advocate; full, re-review, quick, methodology and Socratic modes. Triggers: review paper, peer review, referee report, critique paper."
metadata:
  version: "1.4"
  last_updated: "2026-03-08"
---

# Academic Paper Reviewer v1.4 — Multi-Perspective Academic Paper Review Agent Team

Simulates a complete international journal peer review process: automatically identifies the paper's field, dynamically configures 5 reviewers (Editor-in-Chief + 3 peer reviewers + Devil's Advocate) who review from four non-overlapping perspectives — methodology, domain expertise, cross-disciplinary viewpoints, and core argument challenges — ultimately producing a structured Editorial Decision and Revision Roadmap.

Read `references/orchestration_workflow.md` when you are about to start a run and need the entry command, the Phase 0 -> 1 -> 2 -> 2.5 sequence, or what each agent reads and emits.

---

## Trigger Conditions

### Trigger Keywords

**English**: review paper, peer review, manuscript review, referee report, review my paper, critique paper, simulate review, editorial review

### Non-Trigger Scenarios

| Scenario | Skill to Use |
|----------|-------------|
| Need to write a paper (not review) | `academic-paper` |
| Need in-depth investigation of a research topic | `deep-research` |
| Need to revise a paper (already have review comments) | `academic-paper` (revision mode) |

### Quick Mode Selection Guide

| Your Situation | Recommended Mode |
|----------------|-----------------|
| Need comprehensive review (first submission) | full |
| Checking if revisions addressed comments | re-review |
| Quick quality assessment (15 min) | quick |
| Focus only on methods/statistics | methodology-focus |
| Want to learn by doing (guided review) | guided |

Not sure? Use `full` for pre-submission review, `re-review` for post-revision verification.

---

## Agent Team (7 Agents)

| # | Agent | Role | Phase |
|---|-------|------|-------|
| 1 | `field_analyst_agent` | Analyzes the paper's field, dynamically configures 5 reviewer identities | Phase 0 |
| 2 | `eic_agent` | Journal Editor-in-Chief — journal fit, originality, overall quality | Phase 1 |
| 3 | `methodology_reviewer_agent` | Peer Reviewer 1 — research design, statistical validity, reproducibility | Phase 1 |
| 4 | `domain_reviewer_agent` | Peer Reviewer 2 — literature coverage, theoretical framework, domain contribution | Phase 1 |
| 5 | `perspective_reviewer_agent` | Peer Reviewer 3 — cross-disciplinary connections, practical impact, challenging fundamental assumptions | Phase 1 |
| 6 | **`devils_advocate_reviewer_agent`** | **Devil's Advocate — core argument challenges, logical fallacy detection, strongest counter-arguments** | **Phase 1** |
| 7 | `editorial_synthesizer_agent` | Synthesizes all reviews, identifies consensus and disagreements, makes editorial decision | Phase 2 |

Read `references/file_map.md` when you need the exact path of an agent definition, a report template or a worked example.

---

## Operational Modes (5 Modes)

| Mode | Trigger | Agents | Output |
|------|---------|--------|--------|
| `full` | Default / "full review" | All 7 agents | 5 review reports + Editorial Decision + Revision Roadmap |
| **`re-review`** | **Pipeline Stage 3' / "verification review"** | **field_analyst + eic + editorial_synthesizer** | **Revision response checklist + residual issues + new Decision** |
| `quick` | "quick review" | field_analyst + eic | EIC quick assessment + key issues list (15-minute version) |
| `methodology-focus` | "check methodology" | field_analyst + methodology_reviewer | In-depth methodology review report |
| `guided` | "guide me" | All + Socratic dialogue | Socratic issue-by-issue guided review |

### Mode Selection Logic

```
"Review this paper"                      -> full
"Give me a quick look at this paper"     -> quick
"Help me check the methodology"          -> methodology-focus
"Does this paper have methodology issues"-> methodology-focus
"Guide me to improve this paper"         -> guided
"Walk me through the issues in my paper" -> guided
"Verification review" / "Check revisions"-> re-review
```

Read `references/mode_playbooks.md` when the selected mode is `re-review` or `guided`: those two replace the standard three-phase run, and the file carries the verification logic, the response-status vocabulary and the dialogue rules they depend on.

### Checkpoint Rules

1. **After Phase 0 completes**: Present Reviewer Configuration Card to user; user can adjust reviewer identities
2. **Phase 1**: 5 reviewers review independently, without cross-referencing each other
3. **Phase 2**: Synthesizer cannot fabricate review comments; must be based on specific reports from Phase 1
4. **Devil's Advocate special handling**: If the Devil's Advocate finds CRITICAL issues, the Editorial Decision cannot be Accept
5. **Phase 2.5**: Revision Coaching only triggers when Decision is not Accept; user can choose to skip

---

## Review Output Format

Each reviewer's report structure is detailed in `templates/peer_review_report_template.md`.

### Devil's Advocate Report Structure (Special Format)

The Devil's Advocate uses a dedicated format, not the standard reviewer template:
- **Strongest Counter-Argument** (200-300 words)
- **Issue List** (categorized as CRITICAL / MAJOR / MINOR, with dimension and location)
- **Ignored Alternative Explanations/Paths**
- **Missing Stakeholder Perspectives**
- **Observations (Non-Defects)**

---

## Editorial Decision Format

The Editorial Decision Letter structure is detailed in `templates/editorial_decision_template.md`.

Read `references/review_quality_standards.md` before a reviewer report or an editorial decision goes back to the author, to check perspective differentiation, specificity, balance and tone.

---

## Reference Files

| Reference | Purpose | Used By |
|-----------|---------|---------|
| `references/review_criteria_framework.md` | Structured review criteria framework (differentiated by paper type) | all reviewers |
| `references/top_journals_by_field.md` | Top journal lists for major academic fields (EIC role calibration) | field_analyst, eic |
| `references/editorial_decision_standards.md` | Accept/Minor/Major/Reject criteria and decision matrix | eic, editorial_synthesizer |
| `references/statistical_reporting_standards.md` | Statistical reporting standards + APA 7.0 format quick reference + red flag list | methodology_reviewer |
| `references/quality_rubrics.md` | Calibrated 0-100 scoring rubrics for 7 review dimensions with decision mapping | all reviewers |

---

## Output Language

Review reports and messages shown to the user follow the language of the user's request; text meant to go into the paper (suggested rewrites, revised passages) follows the paper's language. Academic terms remain in English. User can override (e.g., "review this Chinese paper in English").

---

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `academic-paper` | Upstream (provides paper) + Downstream (receives revision roadmap) |
| `deep-research` | Upstream (provides research foundation) |
| `academic-pipeline` | Orchestrated by (Stage 3 + Stage 3') |

Read `references/integration_pipeline.md` when this review is one stage of `academic-pipeline` and you need the hand-off contract with `academic-paper`, the integrity check or the finalisation step.

Read `references/version_history.md` when you need the changelog, the version metadata or the maintainer of this skill.

## Triggers

Use this skill on the phrasings that ask for a review: review paper, peer review, manuscript review, referee report, review my paper, critique paper, simulate review, editorial review. It simulates five independent reviewers with field-specific expertise — an editor in chief, three peer reviewers and a devil's advocate — and its modes cover a full review, a re-review that verifies the revision, a quick assessment, a methodology-focused pass and a Socratic guided one.
