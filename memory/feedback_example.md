---
name: feedback_example
description: Example feedback note; show a plan and wait for approval before editing files
metadata:
  type: feedback
---

Before creating or changing any file, show the user a one- or two-line plan and wait for an explicit "ok"; a question from the user is answered, not acted on.

**Why:** the user once asked "could we rename this module?" and the agent renamed it across the project at once, while the user only wanted to hear the options. The rollback cost more than the rename.

**How to apply:** for every task that writes files, state the plan first and stop until the user approves it. Read-only work (reading, searching, explaining) needs no approval. Once a plan is approved in plan mode, carry it out without asking again for each step.
