---
name: git-worktree-status
description: Read-only worktree/branch inventory with a CI status column; complements /git-clean-gone. Per worktree shows path, branch, ahead/behind or [gone], dirty?, and CI. Use to survey worktree/branch state and spot [gone] branches before cleanup. Never mutates, deletes, pushes, or checks out.
---

# git-worktree-status — read-only worktree inventory + CI

A **strictly read-only** survey of every worktree and branch. It mirrors the
inventory commands `/git-clean-gone` already runs, then adds **one** new column — CI —
sourced verbatim from the foundation. It does **not** delete, prune, or check out
anything; deletion is `/git-clean-gone`'s job. This skill only reports.

## Inventory (mirror /clean_gone — do not reinvent)

Run the same read-only commands `/clean_gone` uses
(`~/.claude/plugins/cache/claude-code-plugins/commit-commands/1.0.0/commands/clean_gone.md`):

```bash
git worktree list --porcelain   # worktree paths + the branch checked out in each
git branch -vv                  # ahead/behind, [gone] markers, '+' = has worktree
```

Parse exactly as clean_gone does:
- `[gone]` marker → upstream deleted on remote (the `grep '\[gone\]'` signal).
- ahead/behind → the `[ahead N, behind M]` segment from `git branch -vv`.

Then, per worktree path, check the working tree (read-only, no flags that write):

```bash
git -C "<worktree-path>" status --porcelain   # non-empty → dirty
```

## CI column (foundation, by reference — do not re-implement)

Read `~/.claude/skills/shared/git-host.md` in full. For each
branch/worktree:

1. Run the **§2–§3 detection block** for that branch (it is idempotent and pure —
   designed to be called per-branch in a loop) to get `backend`.
2. If `backend=unknown` → CI column = **`n/a`**, still print the row (the §1
   consumer table: `git-worktree-status` **degrades**, never STOPs).
3. Otherwise run the **§4 CI-parse snippet** for **one** check — `gh_ci_state`
   (GitHub) or `forgejo_ci_state` (Forgejo). For Forgejo pass the PR **head SHA**
   per §4. **One check only — no `--watch`, no polling.**

Use the §4 state vocabulary verbatim: `success | pending | failure | error |
no-checks | unreachable`. Do **not** collapse `no-checks` or `unreachable` into
`success`, and do not paraphrase the mapping — the foundation is the single source
of truth.

## Output table

One row per worktree:

| path | branch | ahead/behind or `[gone]` | dirty? | CI |
|------|--------|--------------------------|--------|----|

- **path** — from `git worktree list --porcelain`.
- **branch** — branch checked out in that worktree.
- **ahead/behind or `[gone]`** — from `git branch -vv` (`[gone]` wins when present).
- **dirty?** — `yes` if `git status --porcelain` non-empty, else `no`.
- **CI** — §4 state, or `n/a` when `backend=unknown`.

## Pointer to /git-clean-gone (no deletion here)

Count branches carrying `[gone]` and finish with:

```
N веток [gone] — /git-clean-gone для удаления
```

If `N = 0`, say there are no `[gone]` branches. **Never** delete, prune, or check
out — surveying is all this skill does.

_End of skill._
