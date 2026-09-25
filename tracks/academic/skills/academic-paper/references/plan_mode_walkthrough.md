# Plan Mode Walkthrough — academic-paper

Moved verbatim out of `SKILL.md`: the four Socratic steps of `plan` mode, with the probing questions asked for every chapter and the exit condition of each step.

## Plan Mode: CHAPTER-BY-CHAPTER GUIDED PLANNING

Core principle: From the perspective of a senior doctoral advisor and disciplinary methodology expert, guide users to think through every part of their paper chapter by chapter. Instead of writing directly, use Socratic dialogue to help users clarify what they want to write.

```
User: "guide my paper" / "help me plan my paper"
     |
=== Step 0: RESEARCH READINESS CHECK ===
     |
     +-> [socratic_mentor_agent] -> Confirm what materials the user already has
         - "What research materials do you currently have? (literature, data, analysis results)"
         - "Is your research question finalized? Can you state it in one sentence?"
         -> If research foundation is lacking, recommend running deep-research (socratic mode) first
     |
=== Step 1: THESIS CRYSTALLIZATION ===
     |
     +-> [socratic_mentor_agent] -> Probe the core thesis
         - "What is your paper arguing?"
         - "How would someone who disagrees with you respond?"
         - "After reading your paper, what should the reader think differently about?"
         Extract [INSIGHT: thesis_statement]
     |
=== Step 2: CHAPTER-BY-CHAPTER NEGOTIATION ===
     |
     For each chapter (Introduction -> Literature -> Method -> Results -> Discussion -> Conclusion):
     |
     +-> [socratic_mentor_agent] -> Probe the purpose and content of each chapter
     |
     |   Introduction:
     |   - "What sense of urgency should the reader feel by the end of this chapter?"
     |   - "After reading the Introduction, what should the reader expect to see next?"
     |   - "What is your research gap? State it in one sentence."
     |
     |   Literature Review:
     |   - "How many stories are you telling? What is the relationship between them?"
     |   - "What conclusion should your literature review ultimately lead to?"
     |   - "Is there an important work you disagree with? Why?"
     |
     |   Methodology:
     |   - "If someone challenges your method, how would you respond?"
     |   - "Is there a simpler method that could also answer your question? Why didn't you choose it?"
     |   - "What is the biggest limitation of your method? How do you handle it?"
     |
     |   Results:
     |   - "What is your most important finding? State it in one sentence."
     |   - "Were there any unexpected results? How do you explain them?"
     |   - "Is there any evidence in your data that does not support your hypothesis?"
     |
     |   Discussion:
     |   - "How do your results dialogue with existing literature?"
     |   - "What is the one thing you most want the reader to remember?"
     |   - "What recommendations does your research have for practice/policy?"
     |
     |   Conclusion:
     |   - "If you could only leave one paragraph, what would you say?"
     |   - "What future research directions does your study open up?"
     |
     At least 2 rounds of dialogue per chapter
     After each chapter concludes, [socratic_mentor_agent] extracts a Chapter Summary
     |
     +-> [structure_architect_agent] -> Produce complete outline based on all Chapter Summaries
     |
=== Step 3: ARGUMENT STRESS TEST ===
     |
     +-> [socratic_mentor_agent + argument_builder_agent]
         -> Probe evidence and logic for each sub-argument
         -> "Where is the weakest point in this argument?"
         -> "If you reverse your argument, does it still hold?"
         -> Final output: Chapter Plan (with core argument, supporting evidence, expected word count per chapter)
     |
Output: Chapter Plan + INSIGHT Collection
-> User can then use full mode to produce the complete paper
-> Or use academic-paper-reviewer to review the Chapter Plan
```

**Output language:** the language the user is writing in, until Phase 0 fixes the paper's body language in the Paper Configuration Record. **Length cap:** at most 300 words per Chapter Summary and at most 800 words for the final Chapter Plan; this governs every Socratic step in this section. **Return shape:** Chapter Plan (core argument, supporting evidence, expected word count per chapter) plus the INSIGHT Collection, with [INSIGHT: thesis_statement] from Step 1 as its first entry.

---
