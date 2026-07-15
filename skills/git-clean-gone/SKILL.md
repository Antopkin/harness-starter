---
name: git-clean-gone
description: Delete local branches marked [gone] (upstream removed on remote) and their worktrees. The git-* named entry point for branch hygiene; pairs with git-worktree-status (survey → cleanup). Host-agnostic, pure git.
---

# git-clean-gone — prune [gone] branches + worktrees

The `git-*` named entry point for branch cleanup. It deletes local branches whose
upstream is gone (`[gone]`) and removes any worktree attached to them. Host-agnostic
— pure git, no GitHub/Forgejo specifics.

**This is a thin wrapper — do not re-implement the logic.** The actual cleanup lives
in the `commit-commands` plugin. Invoke it:

> Run the **`/clean_gone`** skill (`commit-commands:clean_gone`).

That command: lists branches (`git branch -v`), finds `[gone]` ones, removes their
worktrees (`git worktree remove --force` for `+`-prefixed branches), then
`git branch -D`. If nothing is `[gone]`, it reports no cleanup was needed.

Pairs with **`/git-worktree-status`** (read-only survey → this command mutates).

_End of skill._
