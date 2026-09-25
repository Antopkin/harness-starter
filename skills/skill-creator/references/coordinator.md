# Coordinator Role

What the coordinator does, which agent files exist, and the checklist it is held to. Referenced from the Architecture and Coordinator Responsibilities sections of `SKILL.md`.

## Architecture

The **coordinator** (this skill):

1. Asks the user what they want to do and which skill to work on
2. Determines workspace location (ask if not obvious)
3. Creates workspace and tasks for tracking progress
4. Delegates work to subagents when available, otherwise executes inline
5. Tracks the **best version** (not necessarily the latest)
6. Reports results with evidence and metrics

### Agent Types

| Agent | Role | Reference |
|-------|------|-----------|
| **Executor** | Run skill on a task, produce transcript + outputs + metrics | `agents/executor.md` |
| **Grader** | Evaluate expectations against transcript and outputs | `agents/grader.md` |
| **Comparator** | Blind A/B comparison between two outputs | `agents/comparator.md` |
| **Analyzer** | Post-hoc analysis of comparison results | `agents/analyzer.md` |

## Coordinator Responsibilities

The coordinator must:

1. **Delegate to subagents when available; otherwise execute inline** - In Improve, Eval, and Benchmark modes, use subagents for executor/grader work when possible. Without subagents, read the agent reference files and follow the procedures directly.
2. **Create mode exception** - Run examples in main loop so user sees the transcript (interactive feedback matters more than consistency)
3. **Use independent grading when possible** - Spawn separate grader/comparator agents for unbiased evaluation. Without subagents, grade inline but acknowledge the limitation.
4. **Track progress with tasks** - Create tasks, update stages, mark complete
5. **Track best version** - The best performer, not the latest iteration
6. **Run multiple times for variance** - 3 runs per configuration when subagents are available; 1 run otherwise
7. **Parallelize independent work** - When subagents are available, spawn independent work in parallel
8. **Report results clearly** - Display pass/fail with evidence and metrics
9. **Review user_notes** - Check executor's user_notes.md for issues that passed expectations might miss
10. **Capture execution metrics** - In Benchmark mode, record tokens/time/tool_calls from each execution
11. **Use most capable model for analysis** - Benchmark analyzer should use the smartest available model

Every executor, grader, comparator and analyzer dispatch carries this contract. **Output language:** English, except an executor, which follows the language of the eval prompt. **Length cap:** at most 400 words in the agent's returned text, or less where a mode's own section sets a tighter cap. **Return shape:** the paths the agent wrote, plus the fields its `agents/*.md` file names for that role — transcript, outputs and metrics for an executor, `grading.json` for a grader, winner and reasoning for a comparator, suggestions for an analyzer.
