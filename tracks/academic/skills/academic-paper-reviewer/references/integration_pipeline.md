# Integration — Position in the Academic Pipeline

Where this skill sits between `academic-paper`, the integrity check and `academic-pipeline`, and what each hand-off carries. Moved verbatim from `SKILL.md`.

## Integration

### Upstream/Downstream Relationships

```
deep-research --> academic-paper --> [integrity check] --> academic-paper-reviewer --> academic-paper (revision) --> academic-paper-reviewer (re-review) --> [final integrity] --> finalize
   (research)       (writing)         (integrity audit)      (review)                    (revision)                    (verification review)                (final verification)   (finalization)
```

### Specific Integration Methods

| Integration Direction | Description |
|----------------------|-------------|
| **Upstream: academic-paper -> reviewer** | Receives the complete paper output from `academic-paper` full mode, directly enters Phase 0 |
| **Upstream: integrity check -> reviewer** | In the Pipeline, the paper must pass integrity check before entering reviewer |
| **Downstream: reviewer -> academic-paper** | The Revision Roadmap format can be directly used as reviewer feedback input for `academic-paper` revision mode |
| **Downstream: reviewer (re-review) -> integrity** | After re-review completes, proceeds to final integrity verification |

**Output language:** the language of the user's request for the hand-off summary and the roadmap the user reads; quoted passages and any wording proposed for the paper stay in the paper's language. **Length cap:** at most 600 words for the hand-off summary. **Return shape:** the Revision Roadmap block of `templates/editorial_decision_template.md` — Priority 1/2/3 items, each a checkable task with an estimated total effort per priority — which is what `academic-paper` revision mode consumes.

### Pipeline Usage Example

```
User: I want to write a paper about AI in higher education quality assurance, from research to submission

Step 1: deep-research -> Research report
Step 2: academic-paper -> Paper first draft
Step 3: integrity check -> 100% verification of references/data
Step 4: academic-paper-reviewer (full) -> 5 review reports + Revision Roadmap
Step 5: academic-paper (revision) -> Revised manuscript
Step 6: academic-paper-reviewer (re-review) -> Verification review
Step 7: (if needed) academic-paper (revision) -> Second revised manuscript
Step 8: integrity check (final) -> Final 100% verification
Step 9: academic-paper (format-convert) -> Final paper
```
