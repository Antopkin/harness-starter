# Git Workflow

Read this when you are about to commit, branch, open or merge a pull request, or work in a worktree.

## Commit protocol

When a task is finished, offer to commit it; after the commit, offer `/git-finalize`, which commits, pushes, opens or reuses the pull request and checks CI on either host. Work that starts from an issue gets its own branch and a pull request.

Ask the user before merging a pull request. The session may commit, push and open the pull request on its own, but the merge itself waits for a yes, even when CI is green. Three things always need the user's explicit decision, whatever else they have delegated: finalizing an architecture decision record, client-facing numbers in a deliverable, and a flip of persistent configuration or of a feature flag. If you want routine merges to happen without that question, turn on the opt-in described below; nothing in this starter does it by default.

## Two hosts: GitHub and Forgejo

GitHub is the default host. A self-hosted Forgejo works too: wherever its address is needed, put your own in place of the `<your-forgejo-host>` placeholder. The host follows from the remote and is never chosen by hand. Detection and CI-status parsing live in `../skills/shared/git-host.md`, the single source of truth; do not copy that logic into a skill. `/git-finalize` works on both hosts, with `gh` for GitHub and `tea` plus the web endpoints for Forgejo. The skill stops before the merge and prints the merge command instead of running it, which is exactly where the question to the user belongs. On both hosts the object is a pull request; Forgejo does not say "merge request". `/git-worktree-status` gives a read-only survey of branches and worktrees with a CI column, and `/git-clean-gone` removes the branches whose upstream is gone.

## Commit messages

Follow Conventional Commits: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`, `perf:`. Keep the subject at or under 72 characters and in the imperative mood, so "add the retry" rather than "added the retry". The body explains why the change exists, since the diff already shows what changed. Do not hand-write a co-author or session trailer when your tool appends its own: a trailer typed by hand goes stale the moment the model behind it changes.

## Before the commit lands

Do not commit files the repository ignores, such as environment files; for environment files the file guard stops writes anyway. If a pre-commit hook fails, repair the cause and make a new commit instead of amending, because an amend can swallow work that someone staged earlier. Stage files by name; sweeping the whole tree in with `git add -A` or `git add .` risks committing a secret.

## Safety

Never rewrite git configuration, `git config user.*` included. A force push, a hard reset and a recursive delete happen only on an explicit request from the user; the Bash guard blocks them by default, it also catches the alternative spellings of the same flags, so do not go looking for one. Do not pass `--no-verify`: when a hook fails, fix what it is complaining about.

## Pull request shape

Give the title at most 70 descriptive characters. The body has three sections, in this order:

- **What changed** — the smallest visual summary of the change;
- **Evidence** — the before/after pairs, the test output and the test plan written as a markdown checklist;
- **Merge risk** — whether the change is reversible, its blast radius and what to watch after merge.

The `git-finalize` skill carries the template and passes the body from a file (`gh pr create --body-file` on GitHub, `tea pulls create --description` on Forgejo). Never push straight to the default branch: every change goes through a pull request. A force push to the default branch needs its own separate confirmation.

The shape follows the `in-progress/pr` skill from mattpocock/skills (MIT), which in turn credits humanlayer's `show-me`.

## Opt-in: merge on green CI without asking

This section applies only if you choose it. You can let the session merge an ordinary feature branch by itself once CI is green, and let a plan pre-approve that merge, but only on a repository where the default branch has branch protection with required status checks: the host must refuse a merge whose required checks have not passed, so that "green" is enforced by the host and not merely reported by the session. Without branch protection and required checks, keep asking the user before every merge.

To turn it on, say so in your own `AGENTS.md` (for example "on this repository, merge on green CI is allowed without asking") and name the repositories it covers. The three decisions listed under Commit protocol still go to the user. Do not build approval-token gates around routine merges, pushes or deploys once you have opted in; they are slow, and they fight the finalize skill they rely on. The opt-in covers routine merges only. It leaves the injection rules, the permission deny rules and the guard hooks exactly as they are, and everything in the next section still applies.

## Correctness safeguards that no merge policy suspends

Merging and cleanup are separate steps, never one chained command. Merge, confirm through the host interface that the pull request reports itself as merged, and only then delete the branch and remove the worktree. Deleting the head branch of a pull request that is still open closes that request, and the recovery is tedious: re-push the branch from the commit object, reopen it through the interface, then merge again.

If the base branch moved while you worked, bring the pull request up to date before merging. A host whose protection rule requires branches to be current refuses to merge a stale branch and reports that the required checks are not satisfied. Update from the base, wait for a fresh green run, then merge. On Forgejo the merge endpoint of the web interface is more reliable than the `tea pr merge` subcommand. Finalize one pull request at a time: the first of a batch merges cleanly, and every later one has to be brought current first, because the earlier merge advanced the base.

The hooks keep working underneath all of this. Secret and protected files stay untouched, and a commit that asks to skip CI while code sits in the index is blocked. A session that both ingests untrusted content and can merge or deploy runs in the default or plan permission mode and never with skipped permissions; the reasoning is in `workflow-orchestration.md` next to this file.

## Worktree policy

When a second agent session may be working in the same repository at the same time, give each session its own worktree before the first edit. Two sessions in one working tree trample each other's uncommitted changes and the git index. Create it with `git worktree add` or with your tool's own worktree command, name it `wt-<kebab-slug>`, and let the branch start from `HEAD`.

Do the work and the finalization inside the worktree. Clean up only when both conditions hold at once: the working tree is clean and the merge is confirmed. Then remove the worktree and delete the branch. A dirty worktree means stop and report to the user; never force it. A worktree carries tracked files only, so ignored artifacts such as environment files are missing there — run anything that needs them from the main tree, or copy over what you need.
