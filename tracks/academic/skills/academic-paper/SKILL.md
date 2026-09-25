---
name: academic-paper
description: "Not raw research or literature search (deep-research). A paper-writing team for article, review, case study and policy brief; APA to Vancouver citations; bilingual abstracts; LaTeX, Word, PDF. Triggers: write or revise paper, paper outline, write abstract, check citations, revision roadmap."
metadata:
  version: "2.4"
  last_updated: "2026-03-08"
---

# Academic Paper — Academic Paper Writing Agent Team

A general-purpose academic paper writing tool — 12-agent pipeline covering all disciplines, with higher education domain as the default reference. This file routes: mode table, checkpoints, quality bar and hand-off contracts stay here, the rest loads on demand.

Read `references/intake_and_triggers.md` when you need the one-line invocation or the eight-step flow.

## Trigger Conditions

Read `references/intake_and_triggers.md` when matching an English or 繁體中文 request to the keyword list.
Read `references/intake_and_triggers.md` when the user wants guiding and you must choose `plan` or `full`.
Read `references/intake_and_triggers.md` when someone asks how this differs from `deep-research`.

When intent is ambiguous between `plan` and `full`, prefer `plan`.

### Does NOT Trigger

| Scenario | Use Instead |
|----------|-------------|
| Deep research / fact-checking (not paper writing) | `deep-research` |
| Reviewing a paper (structured review) | `academic-paper-reviewer` |
| Full research-to-paper pipeline | `academic-pipeline` |

---

## Operational Modes (9 Modes)

See `references/mode_selection_guide.md` for details.

| Mode | Trigger | Agents | Output |
|------|---------|--------|--------|
| `full` | "Write a paper" | All 9 (+ 11 if quantitative) | Complete paper draft (with figures if applicable) |
| `outline-only` | "Paper outline" | 1->2->3 | Detailed outline + evidence map |
| `revision` | "Revise paper" | 8->5->6 | Revised draft with tracked changes (uses `templates/revision_tracking_template.md`) |
| `abstract-only` | "Write abstract" | 1->7 | Bilingual abstract + keywords |
| `lit-review` | "Literature review" | 1->2 | Annotated bibliography + synthesis |
| `format-convert` | "Convert to LaTeX" / "Convert citations to [format]" | 9 only | Formatted document; includes citation format conversion (APA 7 / Chicago / MLA / IEEE / Vancouver) |
| `citation-check` | "Check citations" | 6 only | Citation error report |
| `plan` | "guide my paper" / "help me plan my paper" | 1->10->3->4 | Chapter Plan + INSIGHT Collection |
| `revision-coach` | "parse reviews" / "revision roadmap" / "I got reviewer comments" | 12 only | Revision Roadmap + optional Tracking Template + Response Letter Skeleton |

Read `references/mode_selection_guide.md` when the user describes a situation instead of naming a mode.
Read `references/mode_selection_guide.md` when a request's phrasing sits between two modes.

---

## Pipeline and Phases

Read `references/orchestration_workflow.md` when you need the roster of which agent owns which phase.
Read `references/orchestration_workflow.md` when executing a phase and needing its steps and artefact.
Read `references/intake_and_triggers.md` when you are running the Phase 0 configuration interview.
Read `references/plan_mode_walkthrough.md` when you are in `plan` mode and need a chapter's questions.
Read `references/failure_paths.md` when a run stalls — wrong structure, rejection, plan mode not converging.

### Checkpoint Rules

1. **Phase 0 -> 1**: User must confirm Paper Configuration Record
2. **Phase 2 -> 3**: User must approve outline (can request restructuring)
3. **Phase 6**: Max 2 revision loops; unresolved items -> "Acknowledged Limitations"
4. **Peer Review** Critical-severity issues block progression to Phase 7
5. User can skip Phase 1 (literature) if providing own sources

---

## Output Formats

### Text Formats
LaTeX (.tex + .bib), DOCX (via Pandoc), PDF (via LaTeX or Pandoc), Markdown.

### Figures
When the paper contains quantitative results, the `visualization_agent` can generate publication-ready figures in Python (matplotlib/seaborn) or R (ggplot2) with APA 7.0 formatting and colorblind-safe palettes. Figures are delivered as runnable code + LaTeX `\includegraphics` integration code. See `references/statistical_visualization_standards.md` for chart type decision trees and code templates.

### Citation Formats
APA 7.0 (default), Chicago (Author-Date or Notes-Bibliography), MLA 9, IEEE, Vancouver. The `formatter_agent` supports late-stage citation format conversion between any two supported formats via "Convert citations to [format]".

---

## Handoff Protocol: deep-research -> academic-paper

`intake_agent` automatically detects deep-research materials (RQ Brief / Bibliography / Synthesis / INSIGHT Collection) and skips redundant steps. See `deep-research/SKILL.md` Handoff Protocol for the complete handoff material format.

## Full Academic Pipeline

See `academic-pipeline/SKILL.md` for the complete workflow.

---

## Quality Standards

### Writing Quality
1. **Every claim must have a citation** or be supported by the paper's own data
2. **Zero citation orphans** — in-text citations <-> reference list must perfectly match
3. **Consistent register** — academic tone appropriate for the discipline
4. **Logical flow** — clear transitions between paragraphs and sections
5. **Word count compliance** — within +/-10% of target

### Bilingual Abstract Quality
6. **Independent writing** — zh-TW and EN abstracts are independently composed, NOT mechanical translations
7. **Structural alignment** — both abstracts cover the same key points in the same order
8. **Keywords** — 5-7 per language, reflecting the paper's core concepts
9. **Word count** — EN: 150-300 words; zh-TW: 300-500 characters

### Citation Quality
10. **Format compliance** — 100% adherence to selected citation style
11. **DOI inclusion** — every source with a DOI must include it
12. **Currency** — flag sources older than 10 years (unless seminal works)
13. **Self-citation ratio** — flag if >15%

### Peer Review
14. **Five dimensions** — Originality (20%), Methodological Rigor (25%), Evidence Sufficiency (25%), Argument Coherence (15%), Writing Quality (15%)
15. **Actionable feedback** — every criticism must include a specific suggestion
16. **Max 2 revision rounds** — unresolved items become Acknowledged Limitations

### Mandatory Inclusions
17. **AI disclosure statement** — every paper must include a statement on AI tool usage
18. **Limitations section** — explicitly discuss study limitations
19. **Ethics statement** — when applicable (human subjects, sensitive data)

---

## Output Language

Follows the user's language. Academic terminology is kept in English. Bilingual abstracts are always provided regardless of the main text language.

## Assets

Read `references/skill_asset_map.md` when you need to locate anything this skill
ships: an agent's definition file path, the reference file for a style or glossary
question, a template for a paper type or statement, a worked IMRaD, review or
Chinese paper example, how the paper feeds a website, slides or the reviewer
skill, or the release log for versions 1.0 to 2.4.

## Triggers

Use this skill on write or revise paper, paper outline, write abstract, check citations, parse reviews and revision roadmap. Its twelve agents cover the IMRaD structure, a literature review, a theoretical paper, a case study, a policy brief and a conference paper; citations follow APA 7, Chicago, MLA, Vancouver or the numbered engineering style (`IEEE`); abstracts can be bilingual; and the output goes to LaTeX, Word (`.docx`), PDF or Markdown. Raw research and literature search belong to deep-research.
