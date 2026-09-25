---
name: git-worktree-status
description: Read-only worktree/branch inventory with a CI status column; complements /git-clean-gone. Per worktree shows path, branch, ahead/behind or [gone], dirty?, and CI. Use to survey worktree/branch state and spot [gone] branches before cleanup. Never mutates, deletes, pushes, or checks out.
---

# git-worktree-status — read-only worktree inventory + CI

A **strictly read-only** survey of every worktree and branch. It runs the same
inventory commands as `/git-clean-gone`, then adds **one** new column — CI —
sourced verbatim from the foundation. It does **not** delete, prune, or check out
anything; deletion is `/git-clean-gone`'s job. This skill only reports.

Column headers, state values and the closing line are printed exactly as written
below; any other prose follows the language of the user's request.

## Inventory (pure git, read-only)

Run these two read-only commands:

```bash
git worktree list --porcelain   # worktree paths + the branch checked out in each
git branch -vv                  # ahead/behind, [gone] markers, '+' = has worktree
```

Parse them as follows:
- `git worktree list --porcelain` prints one block per worktree: a `worktree <path>`
  line, a `HEAD <sha>` line, then `branch refs/heads/<name>` (or `detached`). Strip
  `refs/heads/` to get the branch name.
- In `git branch -vv`, the leading `*` marks the current branch and `+` a branch
  checked out in another worktree; the next field is the branch name, then the SHA,
  then the optional upstream segment in square brackets.
- `[gone]` → the upstream segment ends in `: gone]` (for example
  `[origin/feat-x: gone]`): the upstream was deleted on the remote.
- ahead/behind → the `ahead N` and `behind M` parts of the same segment (for example
  `[origin/feat-x: ahead 2, behind 1]`); no counts means in sync, no segment means
  no upstream.

Then, per worktree path, check the working tree (read-only, no flags that write):

```bash
git -C "<worktree-path>" status --porcelain   # non-empty → dirty
```

## CI column (foundation, by reference — do not re-implement)

Read [../shared/git-host.md](../shared/git-host.md) in full. For each
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
N [gone] branches — /git-clean-gone to delete them
```

If `N = 0`, say there are no `[gone]` branches. **Never** delete, prune, or check
out — surveying is all this skill does.

**Output language:** the language of the user's request, with the labels above kept as written. **Length cap:** at most 150 words outside the table rows. **Return shape:** the five-column table (path, branch, ahead/behind or `[gone]`, dirty?, CI) plus the single closing `[gone]`-count line, and nothing else — no command transcript, no per-worktree commentary; this governs every phase of the skill.

_End of skill._
