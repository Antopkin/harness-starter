---
name: grill-with-docs
description: Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates documentation (CONTEXT.md, ADRs) inline as decisions crystallise. Use when user wants to stress-test a plan against their project's language and documented decisions.
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding, and build the project's domain model as we go: challenge its terms, invent edge-case scenarios, and write the glossary and the decisions down the moment they crystallise. Map the plan as a design tree, where every decision branches into the decisions that hang off it, and walk every branch. Answer in the language of my request.

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

## Where the domain docs live

Most repos have a single context:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts, and the map points to where each one lives, for example `src/ordering/CONTEXT.md` with its own `src/ordering/docs/adr/`, while the root `docs/adr/` holds system-wide decisions. When several contexts exist, infer which one the current topic belongs to; if that is unclear, make it a question in the next round.

Create files lazily, only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved. If no `docs/adr/` exists, create it when the first ADR is needed.

## During the session

### Challenge against the glossary

When I use a term that conflicts with the existing language in `CONTEXT.md`, call it out at once: "Your glossary defines 'cancellation' as X, but you seem to mean Y. Which is it?"

### Sharpen fuzzy language

When I use vague or overloaded terms, propose a precise canonical term: "You're saying 'account': do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships come up, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force me to be precise about the boundaries between concepts.

### Cross-reference with code

When I state how something works, check whether the code agrees, through the fact dispatch above. If you find a contradiction, surface it as a question: "Your code cancels entire Orders, but you just said partial cancellation is possible. Which is right?"

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Do not batch these up; capture them as they happen, in the format of [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` stays free of implementation details. It is not a spec, a scratch pad or a store for implementation decisions: it is a glossary and nothing else, holding only terms that mean something to domain experts.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse**: the cost of changing your mind later is meaningful.
2. **Surprising without context**: a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off**: there were genuine alternatives and you picked one for specific reasons.

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).

## When the session ends

The session is done when the frontier is empty, with every branch visited and nothing left silently assumed, and I confirm that we have reached a shared understanding. Do not act on the plan before I confirm.

> Companion skill: after running, consider `/improve-codebase-architecture`; it reads the `CONTEXT.md` and `docs/adr/` that this skill produces.

Adapted from mattpocock/skills@c55ee46 engineering/grill-with-docs (MIT).
Adapted from mattpocock/skills@c55ee46 engineering/domain-modeling (MIT).
Adapted from mattpocock/skills@c55ee46 productivity/grilling (MIT).
