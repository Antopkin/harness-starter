---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Map the plan as a design tree, where every decision branches into the decisions that hang off it, and walk every branch. Answer in the language of my request.

## Work in rounds

Work the tree in rounds rather than one question at a time. The frontier is every decision whose prerequisites are settled: the questions you can ask now without guessing at answers you have not heard yet. Ask the whole frontier in one numbered round, Q1, Q2 and onwards, and give your recommended answer for each question. Then wait for my answers before the next round.

When the tool has a structured-question UI, use it. In Claude Code that is AskUserQuestion: put the explanation, the context each question needs and your reasoning in the message before the call, then ask at most 4 questions per call, with your recommended answer as the first option. A round with more than four questions goes out in consecutive calls, keeping its Q-numbers. Without such a UI, write the round as plain text:

```
**Q1. <question title>**: <question body, possibly several paragraphs, including the choices>

Recommended: <your recommended answer>

---

**Q2. <question title>**: <question body>

Recommended: <your recommended answer>
```

A question that depends on an unanswered one waits for the next round, even when both are on your mind now. Each round of answers reshapes the tree: settled decisions push the frontier outward and unblock the questions that hung on them, so recompute the frontier before you ask again.

## Facts are yours, decisions are mine

Facts that the code or documents can answer are never asked of me. When a frontier question needs such a fact, dispatch a background subagent to find it:

- agent type: `reader`
- Output language: English
- Length cap: 300 words
- Return shape: `{question_id, fact, source}`, where question_id is the Q-number the fact serves and source is the file path and line, or the document, it came from.

Do not block on the dispatch. A running lookup is an unsettled prerequisite, so only the questions downstream of it wait for its report; ask the rest of the frontier now. The decisions are mine: put each one to me and wait.

## When the session ends

The session is done when the frontier is empty, with every branch visited and nothing left silently assumed, and I confirm that we have reached a shared understanding. Do not act on the plan before I confirm.

Adapted from mattpocock/skills@c55ee46 productivity/grilling (MIT).
Adapted from mattpocock/skills@c55ee46 productivity/grill-me (MIT).
