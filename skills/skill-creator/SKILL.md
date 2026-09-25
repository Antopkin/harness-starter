---
name: skill-creator
description: Create new skills, improve existing skills, and measure skill performance. Use when users want to create a skill from scratch, update or optimize an existing skill, run evals to test a skill, or benchmark skill performance with variance analysis.
---

# Skill Creator

A skill for creating new skills and iteratively improving them.

At a high level, the process of creating a skill goes like this:

- Decide what you want the skill to do and roughly how it should do it
- Write a draft of the skill
- Create a few test prompts and run claude-with-access-to-the-skill on them
- Evaluate the results
  - which can be through automated evals, but also it's totally fine and good for them to be evaluated by the human by hand and that's often the only way
- Rewrite the skill based on feedback from the evaluation
- Repeat until you're satisfied
- Expand the test set and try again at larger scale

Your job when using this skill is to figure out where the user is in this process and then jump in and help them progress through these stages. So for instance, maybe they're like "I want to make a skill for X". You can help narrow down what they mean, write a draft, write the test cases, figure out how they want to evaluate, run all the prompts, and repeat.

On the other hand, maybe they already have a draft of the skill. In this case you can go straight to the eval/iterate part of the loop.

Of course, you should always be flexible and if the user is like "I don't need to run a bunch of evaluations, just vibe with me", you can do that instead.

This file keeps the tables you pick a path from and the rules that hold on every path; the procedures live in `references/` and are read when the situation named in each pointer applies.

## Building Blocks

| Building Block | Input | Output | Agent |
|-----------|-------|--------|-------|
| **Eval Run** | skill + eval prompt + files | transcript, outputs, metrics | `agents/executor.md` |
| **Grade Expectations** | outputs + expectations | pass/fail per expectation | `agents/grader.md` |
| **Blind Compare** | output A, output B, eval prompt | winner + reasoning | `agents/comparator.md` |
| **Post-hoc Analysis** | winner + skills + transcripts | improvement suggestions | `agents/analyzer.md` |

Read `references/building-blocks.md` when you need a block's exact inputs, outputs and captured metrics before wiring it into a mode.

---

## Environment Capabilities

Check whether you can spawn subagents — independent agents that execute tasks
in parallel. If you can, you'll delegate work to executor, grader, comparator,
and analyzer agents. If not, you'll do all work inline, sequentially.

---

## Mode Workflows

Building blocks combine into higher-level workflows for each mode:

| Mode | Purpose | Workflow |
|------|---------|----------|
| **Eval** | Test skill performance | Executor → Grader → Results |
| **Improve** | Iteratively optimize skill | Executor → Grader → Comparator → Analyzer → Apply |
| **Create** | Interactive skill development | Interview → Research → Draft → Run → Refine |
| **Benchmark** | Standardized performance measurement (requires subagents) | 3x runs per configuration → Aggregate → Analyze |

See `references/mode-diagrams.md` for detailed visual workflow diagrams.

---

## Task Tracking

Read `references/task-tracking.md` when a run spans several stages and you need the stage names.

---

## Architecture

Read `references/coordinator.md` for the coordinator's own steps and the table mapping Executor/Grader/Comparator/Analyzer to their `agents/*.md` files, and whenever a mode is running and you need the checklist the coordinator is held to: delegation, independent grading, best-version tracking, 3-run variance, metrics capture.

## Communicating with the user

Read `references/communicating-with-the-user.md` before you use words like "assertion", "JSON" or "benchmark" with a user whose technical level you can't yet read.

---

## Creating a skill

Read `references/creating-a-skill.md` when the user wants a new skill: intent capture, the interview, `scripts/init_skill.py`, frontmatter, the skill-writing guide, test cases and `evals/evals.json`, and packaging with `scripts/package_skill.py` (only when the `present_files` tool is available). Read `references/writing-for-agents.md` when you write the description or the body: context pointers, the information hierarchy, completion criteria, leading words, pruning, and the choice between a model-invoked and a user-invoked skill. The lack-of-surprise rule and the rule that every "when to use" instruction belongs in the `description` hold on every path; both are in `references/creating-a-skill.md`.

## Improving a skill

Read `references/improving-a-skill.md` when the user asks to improve an existing skill: the three opening questions (which skill, how much time, what goal), setup, the execute → grade → blind compare → analyze → re-version loop, stopping criteria, the final report, and the reduced-rigor path without subagents. Read `references/writing-for-agents.md` when a change rewrites the description or the body, so the fix sharpens a pointer, a completion criterion or a leading word instead of adding lines.

---

## Eval Mode

Run individual evals to test skill performance and grade expectations.

**IMPORTANT**: Before running evals, read the full documentation:
```
Read references/eval-mode.md      # Complete Eval workflow
Read references/schemas.md        # JSON output structures
```

Use Eval mode when:
- Testing a specific eval case
- Comparing with/without skill on a single task
- Quick validation during development

The workflow: Setup → Check Dependencies → Prepare → Execute → Grade → Display Results

Without subagents, execute and grade sequentially in the main loop. Read the agent reference files (`agents/executor.md`, `agents/grader.md`) and follow the procedures directly.

---

## Benchmark Mode

Run standardized performance measurement with variance analysis.

**Requires subagents.** Benchmark mode relies on parallel execution of many runs to produce statistically meaningful results. Without subagents, use Eval mode for individual eval testing instead.

**IMPORTANT**: Before running benchmarks, read the full documentation:
```
Read references/benchmark-mode.md # Complete Benchmark workflow
Read references/schemas.md        # JSON output structures
```

Use Benchmark mode when:
- "How does my skill perform?" - Understanding overall performance
- "Compare Sonnet vs Haiku" - Cross-model comparison
- "Has performance regressed?" - Tracking changes over time
- "Does the skill add value?" - Validating skill impact

Key differences from Eval:
- Runs **all evals** (not just one)
- Runs each **3 times per configuration** for variance
- Always includes **no-skill baseline**
- Uses **most capable model** for analysis

---

## Workspace Structure

Read `references/workspace-structure.md` when you create a workspace, or go looking for a generated file and need the Eval, Improve or Benchmark tree.

---

## Delegating Work

There are two patterns for delegating work to building blocks:

**With subagents**: Spawn an independent agent with the reference file instructions. Include the reference file path in the prompt so the subagent knows its role. When tasks are independent (like 3 runs of the same version), spawn all subagents in the same turn for parallelism.

**Without subagents**: Read the agent reference file (e.g., `agents/executor.md`) and follow the procedure directly in your main loop. Execute each step sequentially — the procedures are designed to work both as subagent instructions and as inline procedures.

State this contract in every spawn prompt. **Agent type:** the executor runs as `general-purpose`, a named exception, because it must load the skill under test and write its outputs; the grader and the comparator run as `reviewer`; the analyzer runs as `reviewer` or `reader`. **Output language:** English, except an executor, which follows the language of the eval prompt. **Length cap:** at most 400 words in the returned text. **Return shape:** the paths written plus the fields the agent's `agents/*.md` file names, per `references/schemas.md`.

Modified for this kit from anthropics/skills (Apache-2.0).
