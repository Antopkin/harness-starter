---
name: git-finalize
description: Dual-host finalize — commit, push, create/reuse PR, one CI check, stop before merge (GitHub via gh + Forgejo via tea/curl).
---

# git-finalize — dual-host finalize, stop before merge

**Output language:** the language of the user's request. Every quoted guard label
below is printed exactly as written, never translated, reworded or dropped, and a
hint quoted verbatim from `../shared/git-host.md` keeps the wording that file gives it.

Commit → push → PR → **one** CI check → **stop before merge** (print the merge
command, never run it). Works on both backends; the host-agnostic spine is here,
the host-specific leaves come from the foundation.

**Merge policy:** ask the user before merging a pull request. This skill never
merges; it stops before the merge and prints the merge command for the user to run
or approve.

**Foundation (read & run verbatim, do not duplicate):**
[../shared/git-host.md](../shared/git-host.md) is the single source of truth for
host detection (§2–§3) and CI-status parsing (§4). Run the detection block from
§2–§3 to get `backend/host/owner/repo/remote`; use `gh_ci_state` /
`forgejo_ci_state` from §4 for CI. Never re-implement or paraphrase that logic —
if you restate it, finalize and worktree-status diverge.

**Commit discipline (do not duplicate):**
[contexts/git-workflow.md](contexts/git-workflow.md) — conventional
commits ≤72 subject, add files **by name**, no push to
main, never `--no-verify`. For staging+committing, invoke the **`/commit`** skill
(from the `commit-commands` Claude Code plugin) rather than re-describing it; where
it is not available, commit by hand under the same rules.

---

## Flow

1. **Resolve host.** Run the detection block from `../shared/git-host.md §2–§3`. Parse
   `backend/host/owner/repo/remote` (+ `requires_proxy_auth`) from stdout, `reason`
   from stderr. If `backend=unknown` (including `reason=unreachable`) → **STOP**,
   print the `reason` line, do nothing else.

2. **Uncommitted changes.** If `git status --porcelain` is non-empty → invoke the
   **`/commit`** skill. Do not reimplement staging/commit logic here.

3. **Branch if on main.** `b=$(git rev-parse --abbrev-ref HEAD)`. If `b` is `main`
   or `master` → refuse to push; create a feature branch first
   (`git switch -c feature/<slug>`), then continue on it.

4. **Push.** `git push -u "$remote" HEAD` — `remote` from the foundation output.

5. **PR reuse or create.** Work in this order: look for an existing PR, write the
   body only when a PR must be created, then create it.
   - **Reuse check first.**
     - **gh:** `gh pr view --json number,url -q .` on the branch; if a PR exists,
       reuse its number and skip the body and the create step.
     - **forgejo:** run the setup gate from `../shared/git-host.md §7` first. If `tea`
       is missing **or** there is no login for `host` → **STOP** and print the exact
       hint from §7 (no traceback). Else look via `tea pulls list --repo <owner>/<repo>`
       (match `--head <branch>`); if a PR exists, reuse it and skip the body and the
       create step.
   - **Body, only when creating.** Write the body with the Write tool to
     `$TMPDIR/pr-body-<branch>.md` (a `/` in the branch name becomes `-`). It has
     three sections, in this order. `## What changed` holds the smallest visual
     summary of the change (pseudocode, a call tree, a diff sketch or Mermaid), drawn
     in your own words rather than pasted from the diff. `## Evidence` holds
     before/after pairs, the test output and the test plan. `## Merge risk` says
     whether the change is reversible, how wide its blast radius is and what to watch
     after merge. The template and the guide to choosing the visual live in
     `references/pr-body.md`. The title stays within 70 characters.
   - **Create.**
     - **gh:** `gh pr create --title "<t>" --body-file "$TMPDIR/pr-body-<branch>.md"`.
     - **forgejo:**
       `tea pulls create --login <name> --repo <owner>/<repo> --head <branch> --base main --title <t> --description "$(cat "$TMPDIR/pr-body-<branch>.md")"`.
   - **gh account.** On every gh run, reused or created, surface the active account:
     `gh auth status` — print which account is active (dispatch does **not** choose
     between several gh accounts by design; just show it so the user notices).

6. **One CI check.** Use the §4 snippet for the backend:
   - **gh:** `gh_ci_state <prnum>`.
   - **forgejo:** `forgejo_ci_state <host> <owner> <repo> <headSHA>`. The `headSHA`
     **must** come from the PR head via the API / `tea pulls` (e.g. the PR's `head.sha`),
     **not** local `git rev-parse HEAD` (fallback only — local HEAD may differ after a
     remote rebase). Export `FORGEJO_TOKEN` (+ `FORGEJO_PROXY_AUTH` when
     `requires_proxy_auth=yes`) before the call; §7 prints the hint if either is empty.
   - Result is **exactly one** of: `success | pending | failure | error | no-checks |
     unreachable`. Never collapse `no-checks`/`unreachable` into `success`.

7. **STOP before merge.** Print: branch, PR URL/number, CI state. Build the
   ready-to-merge command from the `../shared/git-host.md §5` merge-strategy table
   (right flag per backend — e.g. gh `--squash`, tea `--style squash`). Then:
   - **state=success** → print the merge command as a **ready-to-run** command.
   - **pending / error / failure / no-checks / unreachable** → print that same command
     under the explicit label **"after CI is green:"** (so it can't be copy-pasted into
     a merge over incomplete CI), PLUS a watch command:
     - gh: `gh pr checks <n> --watch`
     - forgejo: poll the combined-status endpoint
       (`GET /api/v1/repos/<owner>/<repo>/commits/<headSHA>/status`) or open the Actions
       URL `https://<host>/<owner>/<repo>/actions`
     - and, in Claude Code only, a `/loop` hint for long waits (e.g.
       `/loop 2m <re-check>`).
   - **no-checks** specifically → add the warning: **"CI is not configured — do not
     mistake this for green"**.
   - **NEVER** actually run the merge. Ask the user; the merge is theirs to run or
     approve.

**Output language:** the language of the user's request. **Length cap:** at most 150 words. **Return shape:**
`branch`, `pr` (number or `none`), `pr_url`, `ci` (one of `success|pending|failure|
error|no-checks|unreachable`), `merged=no`, the merge command, and the watch command
whenever `ci` is not `success`; this governs every step in this section.

**Return shape — two more required fields, never dropped to fit the cap:**
`gh_account`, the active `gh` account from step 5, printed on every gh run so the
user notices which identity opened or reused the PR; and `stop_reason`, printed
whenever the run stops early — the verbatim `reason` line from step 1
(`backend=unknown`, including `reason=unreachable`) or the verbatim §7 hint from
the step-5 forgejo gate, quoted whole even when §7 emits more than one distinct
message. An early stop prints `stop_reason`, `merged=no`, and `branch` when the
stop comes at step 5 (the push already ran); the remaining fields are omitted
because they do not exist yet. The stop case gets its own cap,
**at most 60 words**: roughly 20 for those fields plus up to 40 for the quoted
hint text, which is never trimmed to fit. That is tighter than the cap above, not
a raise — every other run keeps the **at most 150 words** stated there, and
`gh_account` is a few words and fits inside it.

---

## If push/rebase hits a conflict

Host-agnostic submode.

- List conflicted files: `git diff --name-only --diff-filter=U`.
- Resolve by the **meaning of both sides** (not "take theirs/ours" blindly).
  `git add <file>` **by name** (never `git add -A` / `git add .`), then
  `git rebase --continue` (or `git merge --continue`).
- **Gate — must pass before declaring resolved:** run tests + lint
  (`pytest` / `npm test`, `ruff`). Red → loop back to resolving; do not proceed.
- **No test harness:** if `pytest` exits **5** ("no tests collected") or there is no
  `package.json` → do **not** treat as success. State explicitly: **"there are no tests
  — the resolution was not verified automatically"**.
- **Forbidden:** `push --force` / `-f`, `--no-verify`, and any other hook-bypass flag.

**Output language:** the language of the user's request. **Length cap:** at most 120 words. **Return shape:** the
conflicted-file list, what each side meant, `gate_result` (`tests+lint:
pass|fail|absent`) and the next command — no hunk-by-hunk narration; this governs the
whole submode.

---

## Negative list

- Do **not** re-implement detection or CI-parse — reference the foundation only.
- Do **not** collapse `no-checks`/`unreachable`/empty statuses into `success`.
- Do **not** print the ready-to-merge command as ready unless CI = `success`.
- Do **not** use `git remote get-url` without `--all`; do **not** `git add -A` / `git add .`.
- Do **not** merge, force-push, or bypass hooks. Stop before merge — always.

---

Adapted from mattpocock/skills@c55ee46 in-progress/pr (MIT). That skill supplies the
shape of the PR body; upstream in turn credits its "shape of the change" section to
Dex Horthy's show-me skill from humanlayer/humanlayer.
