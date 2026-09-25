# Orchestration Workflow — academic-paper

Moved verbatim out of `SKILL.md`: the twelve-agent roster and the eight-phase execution flow with the artefact each phase produces. The checkpoint rules that gate these phases stay in `SKILL.md`.

## Agent Team (12 Agents)

| # | Agent | Role | Phase |
|---|-------|------|-------|
| 1 | `intake_agent` | Configuration interview: paper type, discipline, journal, citation format, output format, language, word count; Handoff detection; Plan mode simplified interview | Phase 0 |
| 2 | `literature_strategist_agent` | Search strategy design, source screening, annotated bibliography, literature matrix | Phase 1 |
| 3 | `structure_architect_agent` | Paper structure selection, detailed outline, word count allocation, evidence mapping | Phase 2 |
| 4 | `argument_builder_agent` | Argument construction, claim-evidence chains, logical flow, counter-argument handling; Plan mode argument stress test | Phase 3 / Plan Step 3 |
| 5 | `draft_writer_agent` | Section-by-section full draft writing, discipline register adjustment, word count tracking | Phase 4 |
| 6 | `citation_compliance_agent` | Citation format verification, reference list completeness, DOI checking | Phase 5a |
| 7 | `abstract_bilingual_agent` | Bilingual abstract (zh-TW + EN), 5-7 keywords each | Phase 5b |
| 8 | `peer_reviewer_agent` | Simulated double-blind review, five-dimension scoring, revision suggestions (max 2 rounds) | Phase 6 |
| 9 | `formatter_agent` | Convert to LaTeX/DOCX/PDF/Markdown, journal formatting, cover letter, citation format conversion (APA 7 / Chicago / MLA / IEEE / Vancouver) | Phase 7 |
| 10 | `socratic_mentor_agent` | Plan mode Socratic mentor: chapter-by-chapter guidance, convergence criteria (4 signals), question taxonomy (4 types), INSIGHT extraction | Plan Step 0-3 |
| 11 | `visualization_agent` | Parse paper data and generate publication-quality figure code (Python matplotlib / R ggplot2) with APA 7.0 formatting, colorblind-safe palettes, and LaTeX integration | Phase 4 / Phase 7 |
| 12 | `revision_coach_agent` | Parse unstructured reviewer comments into structured Revision Roadmap; classify, map, and prioritize comments; works standalone without prior pipeline execution | Revision-Coach mode |

**Output language:** the body language fixed in the Paper Configuration Record (EN / zh-TW / bilingual sections). **Length cap:** this applies to the table above, not to any dispatch — a Role cell stays at most 40 words. What an agent may hand back is set once, by the handback contract at the end of "Orchestration Workflow (8 Phases)"; this table sets no cap of its own. **Return shape:** set by that same contract, not here.

---

## Orchestration Workflow (8 Phases)

```
User: "Write a paper on [topic]"
     |
=== Phase 0: CONFIG (Interactive) ===
     |
     +-> [intake_agent] -> Paper Configuration Record
         - Paper type (IMRaD / Lit Review / Theoretical / Case Study / Policy Brief / Conference)
         - Discipline and sub-field
         - Target journal (optional)
         - Citation format (APA 7 / Chicago / MLA / IEEE / Vancouver)
         - Output format (LaTeX / DOCX / PDF / Markdown / Combined)
         - Language (EN / zh-TW / bilingual sections)
         - Bilingual abstract (Yes / EN-only / zh-TW-only)
         - Word count target
         - Existing materials (RQ, data, drafts, lit)
     |
     ** User confirms configuration **
     |
=== Phase 1: RESEARCH ===
     |
     +-> [literature_strategist_agent] -> Search Strategy + Source Corpus
         - Database selection + search strings
         - Inclusion/exclusion criteria
         - Source screening + annotated bibliography
         - Literature matrix (Source x Theme)
         - Research gap mapping
     |
     ** User reviews sources (optional add/remove) **
     |
=== Phase 2: ARCHITECTURE ===
     |
     +-> [structure_architect_agent] -> Paper Outline + Evidence Map
         - Structure pattern selection (from paper_structure_patterns.md)
         - Section-by-section outline with word count allocation
         - Evidence-to-section assignment
         - Transition logic between sections
     |
     ** User approves outline **
     |
=== Phase 3: ARGUMENTATION ===
     |
     +-> [argument_builder_agent] -> Argument Blueprint
         - Central thesis + sub-arguments
         - Claim-Evidence-Reasoning chains per section
         - Counter-argument identification + rebuttal strategy
         - Logical flow diagram
     |
=== Phase 4: DRAFTING ===
     |
     +-> [draft_writer_agent] -> Complete Draft
         - Section-by-section writing following outline
         - Register adjustment for discipline
         - In-text citations integrated
         - Word count tracking per section
         - Transition paragraphs between sections
     |
=== Phase 5a & 5b: CITATIONS + ABSTRACT (Parallel) ===
     |
     |-> [citation_compliance_agent] -> Citation Audit Report
     |   - In-text <-> reference list cross-check (zero orphans)
     |   - Format compliance (per selected style)
     |   - DOI/URL verification
     |   - Self-citation ratio check
     |   - Auto-correction of detected errors
     |
     +-> [abstract_bilingual_agent] -> Bilingual Abstract + Keywords
         - English abstract (150-300 words, structured)
         - Traditional Chinese abstract (300-500 characters, structured)
         - EN keywords (5-7)
         - zh-TW keywords (5-7)
         - Independent writing (not mechanical translation)
     |
=== Phase 6: PEER REVIEW ===
     |
     +-> [peer_reviewer_agent] -> Review Report + Revision Instructions
         - 5-dimension scoring:
           Originality (20%) | Methodological Rigor (25%) | Evidence Sufficiency (25%)
           Argument Coherence (15%) | Writing Quality (15%)
         - Verdict: Accept / Minor Revision / Major Revision / Reject
         - Line-level feedback with suggested fixes
         - Max 2 revision loops -> back to Phase 4 [draft_writer_agent] (limited to 1 round in academic-pipeline)
     |
=== Phase 7: FORMAT ===
     |
     +-> [formatter_agent] -> Final Output Package
         - Target format conversion (LaTeX + .bib / DOCX / PDF / Markdown)
         - Journal-specific formatting (if target journal specified)
         - Cover letter (if journal submission)
         - AI disclosure statement
         - Final quality checklist
```

**Output language:** the body language fixed in the Paper Configuration Record (EN / zh-TW / bilingual sections); the Phase 0 interview itself runs in the language the user opened in. **Length cap:** each handback is bounded by the **Length cap** written in the dispatched agent's own file — 12,000 words for `draft_writer_agent`, inside the Phase 0 word count target and its +/-10% tolerance; 800 words of prose for `literature_strategist_agent`, `structure_architect_agent`, `peer_reviewer_agent` and `revision_coach_agent`; 600 for `citation_compliance_agent`; 400 for `formatter_agent`; 300 for `intake_agent`, `visualization_agent` and `socratic_mentor_agent`. Only where an agent file states no cap does the default of at most 500 words apply, which today is `argument_builder_agent` and `abstract_bilingual_agent`, the latter keeping its 150-300 words EN / 300-500 characters zh-TW. A handback is the agent's own message, and each cap excludes only what the agent's own file excludes — the manuscript files `formatter_agent` delivers, the code and LaTeX blocks of `visualization_agent`. **Return shape:** the artefact named on that phase's arrow, carrying the bullets listed under it; for `socratic_mentor_agent`, `visualization_agent` and `revision_coach_agent`, which have no arrow in the flow above, the Return shape stated in the agent's own file. This is the one handback contract for the skill and governs every agent in the roster and every phase in this section, including the revision loop back to Phase 4.

