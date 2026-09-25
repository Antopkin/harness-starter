# Mode Playbooks — Re-Review and Guided

The two modes whose procedure differs from the standard three-phase run. Moved verbatim from `SKILL.md`. Modes `full`, `quick` and `methodology-focus` follow the standard workflow and need no playbook.

## Re-Review Mode (Added in v1.1 — Verification Review)

Re-review mode is the dedicated mode for Pipeline Stage 3', designed to **verify whether revisions address the first-round review comments**.

### How It Works

```
Input:
1. Original Revision Roadmap (Stage 3 output)
2. Revised manuscript
3. Response to Reviewers (optional)

Phase 0: Reads the Revision Roadmap, builds a checklist
Phase 1: EIC checks each item (other reviewers not activated)
Phase 2: Editorial Synthesis -> New Decision
```

**Output language:** the language of the user's request; quoted passages and any wording proposed for the manuscript stay in the manuscript's language. **Length cap:** at most 900 words. **Return shape:** the Verification Review Report defined below under Re-Review Output Format — Decision, Revision Response Checklist (Priority 1/2/3), New Issues, Decision Rationale, Residual Issues.

### Verification Logic

```
For each item in the Revision Roadmap:

Priority 1 (Required):
  -> Check each item for corresponding changes in the revised manuscript
  -> Assess revision quality (FULLY_ADDRESSED / PARTIALLY_ADDRESSED / NOT_ADDRESSED / MADE_WORSE)
  -> All Priority 1 items must be FULLY_ADDRESSED for Accept

Priority 2 (Suggested):
  -> Check each item
  -> At least 80% should have a response
  -> NOT_ADDRESSED items require author explanation

Priority 3 (Nice to Fix):
  -> Check but does not affect Decision
```

### New Issue Detection

```
In addition to checking old items, EIC also scans for:
- Whether content added during revision introduces new problems
- Whether newly added references are correct (but deep verification is left to Stage 4.5 integrity check)
- Whether revisions cause inconsistencies
```

### Socratic Guidance After Re-Review

```
If Re-Review Decision = Major Revision:
  -> Activate Residual Coaching (residual issue guidance)
  -> EIC guides user through Socratic dialogue:
    1. Gap analysis — "How many issues did the first round of revisions resolve? Why are the remaining ones hard to address?"
    2. Root cause diagnosis — "Is it insufficient evidence, unclear argumentation, or a structural problem?"
    3. Trade-off decisions — "Which ones can be marked as research limitations?"
    4. Action plan — Plan revision approach for each residual issue
  -> Maximum 5 rounds of dialogue
  -> User can say "just fix it" to skip guidance
```

### Re-Review Output Format

```markdown
# Verification Review Report

## Decision
[Accept / Minor Revision / Major Revision]

## Revision Response Checklist

### Priority 1 — Required Revisions

| # | Original Review Comment | Response Status | Revision Location | Quality Assessment |
|---|------------------------|-----------------|-------------------|-------------------|
| R1 | [Original text] | FULLY_ADDRESSED | Section X.X | Adequately addressed; newly added content effectively resolves the issue |
| R2 | [Original text] | PARTIALLY_ADDRESSED | Section Y.Y | Partially addressed, but still missing [specific gap] |

### Priority 2 — Suggested Revisions

| # | Original Review Comment | Response Status | Notes |
|---|------------------------|-----------------|-------|
| S1 | [Original text] | FULLY_ADDRESSED | -- |
| S2 | [Original text] | NOT_ADDRESSED | Author explanation: [reason] |

### Priority 3 — Nice to Fix

| # | Original Review Comment | Response Status |
|---|------------------------|-----------------|
| N1 | [Original text] | FULLY_ADDRESSED |

## New Issues (Discovered During Revision)

| # | Type | Location | Description |
|---|------|----------|-------------|
| NEW-1 | [Type] | Section X.X | [Description] |

## Decision Rationale
[Rationale based on the checklist]

## Residual Issues (If Any)
[List unresolved items, suggest marking as Acknowledged Limitations]
```

## Guided Mode (Socratic Guided Review)

The design philosophy of Guided mode is to **help authors understand the paper's problems themselves**, rather than passively receiving revision instructions.

### How It Works

```
Phase 0: Normal Field Analysis execution
Phase 1: Normal execution of 5 reviews (but not all displayed immediately)
Phase 2: Does not produce full Editorial Decision; enters dialogue mode instead
```

**Output language:** the language of the user's request; quoted passages and any wording proposed for the paper stay in the paper's language. **Length cap:** at most 400 words per dialogue turn. **Return shape:** one dialogue turn (affirmation, the issue raised, the question back to the author) and, once the dialogue ends, a structured Revision Roadmap as in `templates/editorial_decision_template.md`.

### Dialogue Flow

1. **EIC opens**: First points out 1-2 core strengths of the paper (building confidence), then raises the most critical structural issue
2. **Wait for author response**: Author thinks, responds, or asks questions
3. **Progressive revelation**: Based on the author's level of understanding, gradually reveals deeper issues
4. **Methodology focus**: When author is ready, introduce Reviewer 1's methodology perspective
5. **Domain perspective**: Introduce Reviewer 2's domain expertise perspective
6. **Cross-disciplinary challenge**: Introduce Reviewer 3's unique perspective
7. **Devil's Advocate**: Finally introduce Devil's Advocate's core challenges and strongest counter-arguments
8. **Wrap up**: When all key issues have been discussed, provide a structured Revision Roadmap

### Dialogue Rules

- Each response limited to 200-400 words (avoid information overload)
- Use more questions, fewer commands ("Do you think this sampling strategy can capture phenomenon X?" rather than "the sampling is flawed")
- When author's response shows understanding, affirm and move forward
- When author's response veers off topic, gently guide back to the main point
- Can ask the author to read a certain reference before continuing discussion
