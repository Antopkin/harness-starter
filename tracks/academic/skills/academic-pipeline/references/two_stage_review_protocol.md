## Two-Stage Review Protocol (Added in v2.0)

### Stage 3: First Review (Full Review)

- **Input**: Paper that passed integrity check
- **Review team**: EIC + R1 (methodology) + R2 (domain) + R3 (interdisciplinary) + Devil's Advocate
- **Output**: 5 review reports + Editorial Decision + Revision Roadmap + Socratic Revision Coaching
- **Decision branches**: Accept -> Stage 4.5 / Minor|Major -> Revision Coaching -> Stage 4 / Reject -> Stage 2 or end

See `academic-paper-reviewer/SKILL.md` for review process details.

**Output language:** the language of the paper under review. **Length cap:** at most 800 words handed back to the orchestrator; the five full review reports stay in files. **Return shape:** Editorial Decision, Revision Roadmap, residual issues.

### Stage 3 -> 4 Transition: Revision Coaching

EIC uses Socratic dialogue to guide the user in understanding review comments and planning revision strategy (max 8 rounds). User can say "just fix it for me" to skip.

### Stage 3': Second Review (Verification Review)

- **Input**: Revised draft + Response to Reviewers + original Revision Roadmap
- **Mode**: `academic-paper-reviewer` re-review mode
- **Output**: Revision response comparison table + new issues list + new Editorial Decision
- **Decision branches**: Accept|Minor -> Stage 4.5 / Major -> Residual Coaching -> Stage 4'

See `academic-paper-reviewer/SKILL.md` Re-Review Mode for verification review process.

**Output language:** the language of the paper under review. **Length cap:** at most 800 words handed back to the orchestrator; the full re-review report stays in a file. **Return shape:** new Editorial Decision, revision response comparison table, residual issues.

### Stage 3' -> 4' Transition: Residual Coaching

EIC guides the user in understanding residual issues and making trade-offs (max 5 rounds). User can say "just fix it" to skip.

---

