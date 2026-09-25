---
name: explain
description: Structured explanation of code, a function or a concept
---
# Explaining code

Use only the Read, Grep and Glob tools. Do not edit files.

Explain the code or concept the user asks about. Follow this structure:

1. **What it is**: one sentence, the essence
2. **How it works**: a step-by-step walk through the logic (by line or by block)
3. **Why**: the motivation, why it was done this way
4. **Pitfalls**: non-obvious behaviour, edge cases
5. **Connections**: how it relates to the rest of the code (callers and callees)

If the user named a file, read it. If they named a function, find it.
Answer in the language of the user's request.
