# Skill Asset Map — academic-paper

Moved verbatim out of `SKILL.md`: which file holds each agent definition, reference, template and example, how this skill combines with the neighbouring ones, and what changed in every release.

The full preamble line of `SKILL.md` before it was shortened to a router:

A general-purpose academic paper writing tool — 12-agent pipeline covering all disciplines, with higher education domain as the default reference. v2.4 hardens LaTeX output formatting: mandatory `apa7` document class for APA 7.0, text justification override for `man` mode, table column width formula with `\tabcolsep` deduction, bilingual abstract centering, standardized font stack (Times New Roman + Source Han Serif TC VF + Courier New), and PDF compilation via xelatex.

## Agent File References

| Agent | Definition File |
|-------|----------------|
| intake_agent | `agents/intake_agent.md` |
| literature_strategist_agent | `agents/literature_strategist_agent.md` |
| structure_architect_agent | `agents/structure_architect_agent.md` |
| argument_builder_agent | `agents/argument_builder_agent.md` |
| draft_writer_agent | `agents/draft_writer_agent.md` |
| citation_compliance_agent | `agents/citation_compliance_agent.md` |
| abstract_bilingual_agent | `agents/abstract_bilingual_agent.md` |
| peer_reviewer_agent | `agents/peer_reviewer_agent.md` |
| formatter_agent | `agents/formatter_agent.md` |
| socratic_mentor_agent | `agents/socratic_mentor_agent.md` |
| visualization_agent | `agents/visualization_agent.md` |
| revision_coach_agent | `agents/revision_coach_agent.md` |

---

## Reference Files

| Reference | Purpose | Used By |
|-----------|---------|---------|
| `references/apa7_extended_guide.md` | APA 7th extended guide (extends deep-research version) | citation_compliance, draft_writer, formatter |
| `references/apa7_chinese_citation_guide.md` | APA 7.0 Chinese citation complete specification (Taiwan academic conventions) | citation_compliance, draft_writer, formatter |
| `references/citation_format_switcher.md` | Multi-citation format switching rules (including Chinese formats) | citation_compliance, formatter |
| `references/paper_structure_patterns.md` | 6 paper structure patterns | structure_architect, intake |
| `references/academic_writing_style.md` | Academic writing style guide | draft_writer, peer_reviewer |
| `references/hei_domain_glossary.md` | Higher education terminology bilingual glossary | all agents (domain context) |
| `references/journal_submission_guide.md` | Journal submission guide | formatter, intake |
| `references/abstract_writing_guide.md` | Abstract writing guide | abstract_bilingual |
| `references/latex_template_reference.md` | LaTeX template reference | formatter |
| `references/failure_paths.md` | Failure path map (12 scenarios + handling strategies) | all agents |
| `references/mode_selection_guide.md` | 8 mode selection guide + transition paths | intake |
| `references/credit_authorship_guide.md` | CRediT 14 roles + ICMJE + AI policy + contribution matrix | intake, formatter, draft_writer |
| `references/funding_statement_guide.md` | Taiwan/international funding formats + statement templates | intake, formatter, draft_writer |
| `references/statistical_visualization_standards.md` | APA 7.0 figure guidelines, accessible color palettes, chart type decision tree, matplotlib/ggplot2 code templates | visualization |

Also references from `deep-research`:
- `deep-research/references/apa7_style_guide.md` — base APA 7 reference (this skill extends, not duplicates)

---

## Templates

| Template | Purpose |
|----------|---------|
| `templates/imrad_template.md` | IMRaD structure template |
| `templates/literature_review_template.md` | Literature review template |
| `templates/case_study_template.md` | Case study template |
| `templates/theoretical_paper_template.md` | Theoretical paper template |
| `templates/policy_brief_template.md` | Policy brief template |
| `templates/conference_paper_template.md` | Conference paper template |
| `templates/latex_article_template.tex` | LaTeX starter template |
| `templates/bilingual_abstract_template.md` | Bilingual abstract template |
| `templates/credit_statement_template.md` | Author x Role contribution matrix + CRediT statement output |
| `templates/funding_statement_template.md` | Funding source registration + statement output |
| `templates/revision_tracking_template.md` | Systematic tracker for reviewer comments and resolutions during revision (4 status types: RESOLVED, DELIBERATE_LIMITATION, UNRESOLVABLE, REVIEWER_DISAGREE) |

---

## Examples

| Example | Demonstrates |
|---------|-------------|
| `examples/imrad_hei_example.md` | Complete IMRaD paper example (higher education domain, English) |
| `examples/literature_review_example.md` | Literature review paper example |
| `examples/plan_mode_guided_writing.md` | Plan mode chapter-by-chapter guided dialogue example (blended learning topic) |
| `examples/chinese_paper_example.md` | Complete Chinese academic paper example (IMRaD, Chinese APA 7.0 citations) |
| `examples/revision_mode_example.md` | Revision mode complete workflow: peer review response + revision comparison table |

---

## Integration with Other Skills

```
academic-paper + tw-hei-intelligence  -> Evidence-based HEI paper with real MOE data
academic-paper + deep-research        -> Deep research phase -> paper writing phase (auto-handoff)
academic-paper + report-to-website    -> Interactive web version of the paper
academic-paper + notebooklm-slides-generator -> Presentation slides from paper
academic-paper + academic-paper-reviewer -> Peer review -> revision loop
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.4 | 2026-03-08 | LaTeX output formatting hardening: mandatory `apa7` document class for APA 7.0 output; text justification fix (`ragged2e` + `etoolbox` to override apa7 man mode `\raggedright`); table column width formula (`(\linewidth - N\tabcolsep) * \real{proportion}` — prevents overflow); bilingual abstract centering (`\begin{center}\textbf{...}\end{center}`); font stack standardized (Times New Roman + Source Han Serif TC VF + Courier New); `xurl` for URL line breaking; `fancyvrb` Verbatim with `fontsize` for wide content; PDF must compile from LaTeX via xelatex (no HTML-to-PDF) |
| 2.3 | 2026-03-08 | NEW visualization_agent (11th: publication-quality figures with matplotlib/ggplot2, APA 7.0, colorblind-safe); NEW revision_coach_agent (12th: standalone reviewer comment parser → Revision Roadmap); Socratic convergence criteria (4 signals: thesis clarity, chapter coherence, evidence mapping, limitation honesty) + question taxonomy (clarifying, probing, structuring, challenging); revision tracking template (4 status types); citation format conversion in formatter_agent (APA 7 ↔ Chicago ↔ MLA ↔ IEEE ↔ Vancouver); Quick Mode Selection Guide; 9th mode: revision-coach |
| 2.2 | 2025-03-05 | 4-level argument strength scoring with quantified thresholds; plagiarism & retraction screening protocol; F11 Desk-Reject Recovery + F12 Conference-to-Journal Conversion failure paths; Plan -> Full mode conversion protocol; cross-skill reference to `../../shared/handoff_schemas.md` |
| 2.1 | 2026-03 | Added CRediT authorship guide, funding statement guide, 2 new templates (credit_statement_template, funding_statement_template); enhanced intake_agent with co-author + funding questions (Step 9-10); enhanced formatter_agent with CRediT + funding quality checks |
| 2.0 | 2026-02 | NEW plan mode (Socratic guided chapter-by-chapter planning), deep-research handoff protocol, Chinese APA 7.0 citation guide, failure path handling, mode selection guide |
| 1.0 | 2026-01 | Initial release: 9-agent pipeline, 6 paper types, 5 citation formats, bilingual abstracts, multi-format output |
