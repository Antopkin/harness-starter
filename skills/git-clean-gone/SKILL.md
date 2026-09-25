---
name: git-clean-gone
description: Delete local branches marked [gone] (upstream removed on remote) and their worktrees, after the user confirms. The git-* named entry point for branch hygiene; pairs with git-worktree-status (survey → cleanup). Host-agnostic, pure git.
---

# git-clean-gone — prune [gone] branches + worktrees

The `git-*` named entry point for branch cleanup. It deletes local branches whose
upstream is gone (`[gone]`) and removes any worktree attached to them. Host-agnostic
— pure git, no GitHub/Forgejo specifics. Nothing is deleted before the user confirms
the list, and nothing is forced without asking.

## Flow

1. **Refresh remote state.** `git fetch --prune`, so branches whose upstream was
   deleted on the remote are marked `[gone]`.

2. **List the `[gone]` branches.** Run `git branch -vv` and keep the lines whose
   upstream segment ends in `: gone]` (for example `[origin/feat-x: gone]`). The
   branch name is the first field after the leading marker: `*` marks the current
   branch, `+` a branch checked out in another worktree. If none are `[gone]`, say
   no cleanup is needed and stop.

3. **Map branches to worktrees.** `git worktree list --porcelain`: each block pairs a
   `worktree <path>` line with a `branch refs/heads/<name>` line. Note the worktree
   path for every `[gone]` branch that has one.

4. **Show and confirm.** Print each `[gone]` branch with its worktree path (or `—`)
   and ask the user to confirm the list; they may drop items. Delete nothing before
   that answer.

5. **Remove worktrees, never forced.** For each confirmed branch with a worktree,
   run `git worktree remove "<path>"` without `--force`. If git refuses because the
   worktree has uncommitted or untracked changes, **stop on that branch**: report the
   path and `git -C "<path>" status --short`, keep the branch, and move on to the
   next one. A branch checked out in the main worktree (`*`) cannot be removed from
   there; report it and let the user switch branches first.

6. **Delete the branch.** `git branch -d <name>`. If git refuses because the branch
   is not fully merged (common after a squash merge on the host), show that message
   and ask the user before running `git branch -D <name>`; without a yes, keep the
   branch.

In Claude Code with the `commit-commands` plugin installed, its `/clean_gone`
command is an optional shortcut, but it force-removes worktrees; the flow above is
the default and needs nothing beyond git.

Pairs with **`/git-worktree-status`** (read-only survey → this command mutates).

**Output language:** the language of the user's request. **Length cap:** at most 120 words. **Return shape:** three lists — branches deleted (noting any removed with `-D` after the user agreed), worktrees removed, and items kept with the reason (dirty worktree, checked out in the main worktree, `-D` declined, dropped by the user) — or the single line that no branch is `[gone]`.
