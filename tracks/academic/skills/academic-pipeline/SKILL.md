---
name: academic-pipeline
description: "Orchestrates the whole academic pipeline: deep-research, then academic-paper, an integrity check, two-stage review, revision and finalisation. Triggers: academic pipeline, research to paper, end-to-end paper."
metadata:
  version: "2.6"
  last_updated: "2026-03-08"
  depends_on: "deep-research, academic-paper, academic-paper-reviewer"
---

# Academic Pipeline v2.6 — Full Academic Research Workflow Orchestrator

A lightweight orchestrator that manages the complete academic pipeline from research exploration to final manuscript. It does not perform substantive work — it only detects stages, recommends modes, dispatches skills, manages transitions, and tracks state.

Everything not on this page loads on demand from `references/`.

---

## Trigger Conditions

### Trigger Keywords

**English**: academic pipeline, research to paper, full paper workflow, paper pipeline, end-to-end paper, research-to-publication, complete paper workflow

### Non-Trigger Scenarios

| Scenario | Skill to Use |
|----------|-------------|
| Only need to search materials or do a literature review | `deep-research` |
| Only need to write a paper (no research phase needed) | `academic-paper` |
| Only need to review a paper | `academic-paper-reviewer` |
| Only need to check citation format | `academic-paper` (citation-check mode) |
| Only need to convert paper format | `academic-paper` (format-convert mode) |

### Trigger Exclusions

- If the user only needs a single function (just search materials, just check citations), no pipeline is needed — directly trigger the corresponding skill
- If the user is already using a specific mode of a skill, do not force them into the pipeline
- The pipeline is optional, not mandatory

---

## Pipeline Stages (10 Stages)

| Stage | Name | Skill / Agent Called | Available Modes | Deliverables |
|-------|------|---------------------|----------------|-------------|
| 1 | RESEARCH | `deep-research` | socratic, full, quick | RQ Brief, Methodology, Bibliography, Synthesis |
| 2 | WRITE | `academic-paper` | plan, full | Paper Draft |
| **2.5** | **INTEGRITY** | **`integrity_verification_agent`** | **pre-review** | **Integrity verification report + corrected paper** |
| 3 | REVIEW | `academic-paper-reviewer` | full (incl. Devil's Advocate) | 5 review reports + Editorial Decision + Revision Roadmap |
| 4 | REVISE | `academic-paper` | revision | Revised Draft, Response to Reviewers |
| **3'** | **RE-REVIEW** | **`academic-paper-reviewer`** | **re-review** | **Verification review report: revision response checklist + residual issues** |
| **4'** | **RE-REVISE** | **`academic-paper`** | **revision** | **Second revised draft (if needed)** |
| **4.5** | **FINAL INTEGRITY** | **`integrity_verification_agent`** | **final-check** | **Final verification report (must achieve 100% pass to proceed)** |
| 5 | FINALIZE | `academic-paper` | format-convert | Final Paper (default MD + DOCX; ask about LaTeX; confirm correctness; PDF) |
| **6** | **PROCESS SUMMARY** | **orchestrator** | **auto** | **Paper creation process record MD + LaTeX to PDF (bilingual)** |

---

## Load on Demand

- Read `references/pipeline_state_machine.md` when a stage ends and the next is chosen.
- Read `references/pipeline_state_machine.md` when another revision round is proposed.
- Read `references/orchestrator_workflow.md` when intake, dispatch or a hand-off runs.
- Read `references/orchestrator_workflow.md` when an agent's role must be checked.
- Read `references/checkpoint_protocol.md` when a FULL checkpoint is rendered.
- Read `references/checkpoint_protocol.md` when the user auto-continues twice.
- Read `references/checkpoint_protocol.md` when the user wants a checkpoint skipped.
- Read `references/integrity_review_protocol.md` when Stage 2.5 or Stage 4.5 begins.
- Read `references/two_stage_review_protocol.md` when Stage 3 or Stage 3' begins.
- Read `references/external_review_protocol.md` when real journal comments arrive.
- Read `references/pipeline_reporting.md` when the user asks for pipeline status.
- Read `references/pipeline_reporting.md` when the run ends and must be audited.
- Read `references/process_summary_protocol.md` when Stage 6 writes the process record.
- Read `references/pipeline_quality_and_recovery.md` when dispatch is checked for quality.
- Read `references/pipeline_quality_and_recovery.md` when a stage errors or a skill fails.
- Read `references/pipeline_entry_and_dispatch.md` when the entry stage must be detected.
- Read `references/pipeline_entry_and_dispatch.md` when a stage's skill and mode are set.
- Read `references/pipeline_entry_and_dispatch.md` when the user asks who owns a stage.
- Read `references/pipeline_asset_map.md` when the handoff schemas are needed.
- Read `references/pipeline_asset_map.md` when the dashboard template is needed.
- Read `references/pipeline_asset_map.md` when a worked run log would help.
- Read `references/pipeline_version_history.md` when the v2.0 guarantees are asked for.
- Read `references/pipeline_version_history.md` when dependent skill versions matter.
- Read `references/pipeline_version_history.md` when the user asks what changed.
- Read `references/mode_advisor.md` when intent must be mapped to a mode.
- Read `references/plagiarism_detection_protocol.md` when Phase D originality runs.
- Read `references/claim_verification_protocol.md` when Phase E claim checks run.
- Read `references/team_collaboration_protocol.md` when several people share the paper.

---

## Adaptive Checkpoint System

**Core rule: After each stage completion, the system must proactively prompt the user and wait for confirmation. The checkpoint presentation adapts based on context and user engagement.**

### Checkpoint Types

| Type | When Used | Content |
|------|-----------|---------|
| FULL | First checkpoint; after integrity boundaries; before finalization | Full deliverables list + decision dashboard + all options |
| SLIM | After 2+ consecutive "continue" responses on non-critical stages | One-line status + auto-continue in 5 seconds |
| MANDATORY | Integrity FAIL; Review decision; Stage 5 | Cannot be skipped; requires explicit user input |

---

## Mid-Entry Protocol

Users can enter from any stage. The orchestrator will:

1. **Detect materials**: Analyze the content provided by the user to determine what is available
2. **Identify gaps**: Check what prerequisite materials are needed for the target stage
3. **Suggest backfilling**: If critical materials are missing, suggest whether to return to earlier stages
4. **Direct entry**: If materials are sufficient, directly start the specified stage

**Important: mid-entry cannot skip Stage 2.5**
- If the user brings a paper and enters directly, go through Stage 2.5 (INTEGRITY) first before Stage 3 (REVIEW)
- Only exception: User can provide a previous integrity verification report and content has not been modified

---

## Agent File References

| Agent | Definition File |
|-------|----------------|
| pipeline_orchestrator_agent | `agents/pipeline_orchestrator_agent.md` |
| state_tracker_agent | `agents/state_tracker_agent.md` |
| integrity_verification_agent | `agents/integrity_verification_agent.md` |

---

## Output Language

Follows user language. Academic terminology retained in English.

---

## Triggers

Use this skill for the whole road from a research question to a finished paper, on phrasings such as academic pipeline, research to paper, full paper workflow, paper pipeline, end-to-end paper, research-to-publication and complete paper workflow. It coordinates deep-research, academic-paper and academic-paper-reviewer across ten stages, with an integrity check before and after revision, two stages of peer review, and quality gates that a later run can reproduce.
