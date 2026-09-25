---
name: deep-research
description: "Not for writing the paper itself (academic-paper). A research team in seven modes, from a brief to a systematic review with meta-analysis, that verifies sources, synthesises across them and reports in APA 7. Triggers: research, literature review, systematic review, fact-check."
metadata:
  version: "2.3"
  last_updated: "2026-03-08"
---

# Deep Research — Universal Academic Research Agent Team

Universal deep research tool — a domain-agnostic 13-agent team for rigorous academic research on any topic. v2.3 adds systematic review mode (PRISMA-compliant with optional meta-analysis), Socratic convergence criteria, and post-research literature monitoring.

This file is the router. Each pointer below names the file to read and when.

---

## Trigger Conditions

### Trigger Keywords

**English**: research, deep research, literature review, systematic review, meta-analysis, PRISMA, evidence synthesis, fact-check, methodology, APA report, academic analysis, policy analysis, guide my research, help me think through, monitor this topic, set up alerts

**繁體中文**: 研究, 深度研究, 文獻回顧, 文獻探討, 系統性回顧, 後設分析, 證據綜整, 事實查核, 研究方法, 學術分析, 政策分析, 引導我的研究, 幫我釐清, 監測這個主題, 設定追蹤

### Socratic Mode Activation

Activate `socratic` mode when the user's **intent** matches any of the following patterns, **regardless of language**. Detect meaning, not exact keywords.

**Intent signals** (any one is sufficient):
1. User has no clear research question and wants guided thinking
2. User asks to be "led", "guided", or "mentored" through research
3. User expresses uncertainty about what to research or where to start
4. User wants to brainstorm, explore, or clarify a research direction
5. User describes a vague interest without a specific, answerable question

**Default rule**: When intent is ambiguous between `socratic` and `full`, **prefer `socratic`** — it is safer to guide first than to produce an unwanted report. The user can always switch to `full` later.

**Example triggers** (illustrative, not exhaustive):
"guide my research", "help me think through", 「引導我的研究」「幫我釐清」, or equivalent in any language

### Does NOT Trigger

| Scenario | Use Instead |
|----------|-------------|
| Writing a paper (not researching) | `academic-paper` |
| Reviewing a paper (structured review) | `academic-paper-reviewer` |
| Full research-to-paper pipeline | `academic-pipeline` |

### Quick Mode Selection Guide

| Your Situation 你的狀況 | Recommended Mode |
|----------------|-----------------|
| Vague idea, need guidance / 有模糊想法，需要引導 | `socratic` |
| Clear RQ, need comprehensive research / 有明確 RQ，需要完整研究 | `full` |
| Need a quick brief (30 min) / 需要快速摘要 | `quick` |
| Have a paper to evaluate before citing / 有論文需要評估 | `review` |
| Need literature review for a topic / 需要文獻回顧 | `lit-review` |
| Need to verify specific claims / 需要查核特定事實 | `fact-check` |
| Need systematic review / meta-analysis / 系統性回顧或後設分析 | `systematic-review` |

Not sure? Start with `socratic` — it will help you figure out what you need.
不確定？先用 `socratic` 模式——它會幫你釐清你需要什麼。

---

## Operational Modes

| Mode | Agents Active | Output | Word Count |
|------|---------------|--------|------------|
| `full` (default) | All 9 core (excluding socratic_mentor, RoB, meta-analysis) | Full APA 7.0 report | 3,000-8,000 |
| `quick` | RQ + Biblio + Verification + Report | Research brief | 500-1,500 |
| `review` | Editor + Devil's Advocate + Ethics | Reviewer report on provided text | N/A |
| `lit-review` | Biblio + Verification + Synthesis | Annotated bibliography + synthesis | 1,500-4,000 |
| `fact-check` | Source Verification only | Verification report | 300-800 |
| `socratic` | Socratic Mentor + RQ + Devil's Advocate | Research Plan Summary (INSIGHT collection) | N/A (iterative) |
| `systematic-review` | RQ + Architect + Biblio + Verification + RoB + Meta-Analysis + Synthesis + Report + Editor + Ethics + DA | Full PRISMA 2020 report + forest plot data + GRADE table | 5,000-15,000 |

Read `references/pipeline_workflow.md` when the mode is still ambiguous after the two tables above.

---

## Pipeline Rules

Read `references/pipeline_workflow.md` before running `full`, `quick`, `lit-review` or `review` end to end.
Read `references/pipeline_workflow.md` when you must decide which of the 13 agents a phase needs.
Read `references/pipeline_workflow.md` when the user asks how to invoke this skill or what a run produces.
Read `references/socratic_mode.md` when mode is `socratic`: 5 layers, round limits, INSIGHT capture.
Read `references/systematic_review_mode.md` when mode is `systematic-review`: PRISMA, RoB, GRADE gates.
Read `references/failure_paths.md` when a phase stalls: RQ will not converge, under 5 sources, CRITICAL.
Read `references/literature_monitoring_strategies.md` when the user says "monitor this topic" or "set alerts".
Read `references/mcp_routing.md` before any literature search, DOI check or URL extraction.

### Checkpoint Rules

1. **Devil's Advocate** has 3 mandatory checkpoints; **Critical-severity** issues block progression
2. Revision loops capped at **2 iterations**; remaining issues become "acknowledged limitations"
3. **Ethics Review** can halt delivery for Critical ethics concerns
4. User confirmation required after Phase 1 before proceeding

---

## Quality Standards

1. **Every claim must have a citation** — no unsupported assertions
2. **Evidence hierarchy** — meta-analyses > RCTs > cohort studies > case reports > expert opinion
3. **Contradiction disclosure** — if sources disagree, report both sides with evidence quality comparison
4. **Limitation transparency** — every report must have an explicit limitations section
5. **AI disclosure** — all reports include a statement that AI-assisted research tools were used
6. **Reproducibility** — search strategies, inclusion criteria, and analytical methods must be documented for replication
7. **Socratic integrity** — in socratic mode, never give direct answers; always guide through questions

Read `references/source_quality_hierarchy.md` for the cross-agent definitions of peer-reviewed, source tier, currency and minimum source counts.

---

## Handoff Protocol: deep-research → academic-paper

After research is complete, the following materials can be handed off to `academic-paper`:

1. **Research Question Brief** (from research_question_agent)
2. **Methodology Blueprint** (from research_architect_agent)
3. **Annotated Bibliography** (from bibliography_agent)
4. **Synthesis Report** (from synthesis_agent)
5. **[If socratic mode] INSIGHT Collection and Research Plan Summary**

**Trigger**: User says "now help me write a paper" or "write a paper based on this"

`academic-paper`'s `intake_agent` will automatically detect available materials and skip redundant steps:
- Has RQ Brief -> skip topic scoping
- Has Bibliography -> skip literature search
- Has Synthesis -> accelerate findings / discussion writing

See `examples/handoff_to_paper.md` for a detailed handoff example.

---

## Full Academic Pipeline

See `academic-pipeline/SKILL.md` for the complete workflow.

---

## Output Language

Follows the user's language. Academic terminology kept in English. Socratic mode uses natural conversational style.

---

## Skill Assets

Read `references/skill_assets_map.md` when you need to locate anything this skill
ships: an agent definition path, the reference index and which agent each file
serves, an output template for a brief, matrix or PRISMA report, a worked example
of a mode, how to chain this skill with another, the version history, or the
long-form trigger paragraph for dispatch.
