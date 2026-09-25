# Task Tracking

How eval runs and comparisons are tracked as tasks. Referenced from the Task Tracking section of `SKILL.md`.

### Task Lifecycle

Each eval run becomes a task with stage progression:

```
pending → planning → implementing → reviewing → verifying → completed
          (prep)     (executor)     (grader)    (validate)
```

The stages are the coordinator's own bookkeeping. Nothing outside this skill reads them, so the state that matters is the files each stage leaves in the workspace.

### Creating Tasks

When running evals, one task is one run: an eval id, a run number and a configuration, such as "Eval 0, run 1 (with_skill)". Its record is the run directory — `<workspace>/eval-<id>/` in Eval mode, `workspace/v<N>/runs/run-<R>/` in Improve mode. Creating the task means creating that directory and staging the eval prompt and input files into `inputs/`.

### Updating Stages

Progress through the stages as the work completes, and read the stage off the workspace:

- **planning** — prepare files, stage inputs into the run directory.
- **implementing** — spawn the executor subagent; it writes `transcript.md`, `outputs/`, `metrics.json` and `user_notes.md`.
- **reviewing** — spawn the grader subagent; it writes `grading.json`.
- **verifying** — confirm the expected outputs exist and `timing.json` carries both start and end.
- **completed** — append the run to `history.json` and report pass rate and metrics.

### Comparison Tasks

For blind comparisons (after all runs complete), one task covers one pair of versions, such as "Compare skill-v1 vs skill-v2":

- **planning** — gather both versions' outputs and record the A/B assignment in `assignment.json`.
- **implementing** — spawn the blind comparators.
- **reviewing** — tally votes, handle ties.
- **verifying** — if tied, run more comparisons or decide on efficiency.
- **completed** — declare the winner and update `history.json`.
