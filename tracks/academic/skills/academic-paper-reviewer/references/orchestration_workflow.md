# Orchestration Workflow — Entry Command and the Three Phases

How a review run starts and how the seven agents are sequenced. Moved verbatim from `SKILL.md`; the checkpoint rules that govern these phases stay in `SKILL.md`.

## Quick Start

**Simplest command:**
```
Review this paper: [paste paper or provide file]
```

```
Review this paper: [paste paper or provide file]
```

**Output:**
1. Automatically identifies the paper's field and methodology type
2. Dynamically configures the specific identities and expertise of 4 reviewers
3. 5 independent review reports (each from a different perspective)
4. 1 Editorial Decision Letter + Revision Roadmap

## Orchestration Workflow (3 Phases)

```
User: "Review this paper"
     |
=== Phase 0: FIELD ANALYSIS & PERSONA CONFIGURATION ===
     |
     +-> [field_analyst_agent] -> Reviewer Configuration Card (x4)
         - Reads the complete paper
         - Identifies: primary discipline, secondary discipline, research paradigm, methodology type, target journal tier, paper maturity
         - Dynamically generates specific identities for 4 reviewers:
           * EIC: Which journal's editor, area of expertise, review preferences
           * Reviewer 1 (Methodology): Methodological expertise, what they particularly focus on
           * Reviewer 2 (Domain): Domain expertise, research interests
           * Reviewer 3 (Perspective): Cross-disciplinary angle, what unique perspective they bring
         - The Devil's Advocate is fixed, not configured: it challenges core arguments and
           detects logical gaps from a standing brief, so it gets no configuration card.
           Phase 1 therefore runs five reviewers — these four plus the Devil's Advocate.
     |
     ** Presents Reviewer Configuration to user for confirmation (adjustable) **
     |
=== Phase 1: PARALLEL MULTI-PERSPECTIVE REVIEW ===
     |
     |-> [eic_agent] -------> EIC Review Report
     |   - Journal fit, originality, significance, relevance to readership
     |   - Does not go deep into methodology (that's Reviewer 1's job)
     |   - Sets the review tone
     |
     |-> [methodology_reviewer_agent] -> Methodology Review Report
     |   - Research design rigor, sampling strategy, data collection
     |   - Analysis method selection, statistical validity, effect sizes
     |   - Reproducibility, data transparency
     |
     |-> [domain_reviewer_agent] -------> Domain Review Report
     |   - Literature review completeness, theoretical framework appropriateness
     |   - Academic argument accuracy, incremental contribution to the field
     |   - Missing key references
     |
     |-> [perspective_reviewer_agent] --> Perspective Review Report
     |   - Cross-disciplinary connections and borrowing opportunities
     |   - Practical applications and policy implications
     |   - Broader social or ethical implications
     |
     +-> [devils_advocate_reviewer_agent] --> Devil's Advocate Report
         - Core argument challenges (strongest counter-arguments)
         - Cherry-picking detection
         - Confirmation bias detection
         - Logic chain validation
         - Overgeneralization detection
         - Alternative paths analysis
         - Stakeholder blind spots
         - "So what?" test
     |
=== Phase 2: EDITORIAL SYNTHESIS & DECISION ===
     |
     +-> [editorial_synthesizer_agent] -> Editorial Decision Package
         - Consolidates 5 reports (including Devil's Advocate challenges)
         - Identifies consensus (4 agree) vs. disagreement (divergent opinions); the
           Devil's Advocate is not one of the four and is counted separately
         - Arbitration and argumentation for disputed issues
         - Devil's Advocate CRITICAL issues are specially flagged in the Editorial Decision
         - Editorial Decision Letter
         - Revision Roadmap (prioritized, can be directly input to academic-paper revision mode)
     |
=== Phase 2.5: REVISION COACHING (Socratic Revision Guidance) ===
     |
     ** Only triggered when Decision = Minor/Major Revision **
     |
     +-> [eic_agent] guides the user through Socratic dialogue:
         1. Overall positioning — "After reading the review comments, what surprised you the most?"
         2. Core issue focus — Guides user to understand consensus issues
         3. Revision strategy — "If you could only change three things, which three would you choose?"
         4. Counter-argument response — Guides user to think about how to respond to Devil's Advocate challenges
         5. Implementation planning — Helps prioritize revisions
     |
     +-> After dialogue ends, produces:
         - User's self-formulated revision strategy
         - Reprioritized Revision Roadmap
     |
     ** User can say "just fix it" to skip guidance **
```

**Output language:** the language of the paper under review, unless the user asks for another. **Length cap:** at most 1500 words per phase deliverable. **Return shape:** this contract governs every phase in this section — Phase 0 returns the Field Analysis Report of `agents/field_analyst_agent.md`, Phase 1 the five review reports shaped by `templates/peer_review_report_template.md` (the Devil's Advocate uses its own format instead), Phase 2 the Editorial Decision Package of `templates/editorial_decision_template.md`, and Phase 2.5 the reprioritized Revision Roadmap block of that same template.
