---
name: git-finalize
description: Dual-host finalize — commit, push, create/reuse PR, one CI check, stop before merge (GitHub via gh + Forgejo via tea/curl). Supersedes commit-push-pr.
---

# git-finalize — dual-host finalize, stop before merge

Commit → push → PR → **one** CI check → **STOP before merge** (print the merge
command, never run it). Works on both backends; the host-agnostic spine is here,
the host-specific leaves come from the foundation.

**Foundation (read & run verbatim, do not duplicate):**
`~/.claude/skills/shared/git-host.md` is the single source of truth for
host detection (§2–§3) and CI-status parsing (§4). Run the detection block from
§2–§3 to get `backend/host/owner/repo/remote`; use `gh_ci_state` /
`forgejo_ci_state` from §4 for CI. Never re-implement or paraphrase that logic —
if you restate it, finalize and worktree-status diverge.

**Commit discipline (do not duplicate):**
`~/.claude/contexts/git-workflow.md` — conventional commits ≤72 subject,
`Co-Authored-By` trailer, add files **by name**, no push to main, never
`--no-verify`. For staging+committing, invoke the **`/commit`** skill rather than
re-describing it.

---

## Flow

1. **Resolve host.** Run the detection block from `shared/git-host.md §2–§3`. Parse
   `backend/host/owner/repo/remote` (+ `requires_proxy_auth`) from stdout, `reason`
   from stderr. If `backend=unknown` (including `reason=unreachable`) → **STOP**,
   print the `reason` line, do nothing else.

2. **Uncommitted changes.** If `git status --porcelain` is non-empty → invoke the
   **`/commit`** skill. Do not reimplement staging/commit logic here.

3. **Branch if on main.** `b=$(git rev-parse --abbrev-ref HEAD)`. If `b` is `main`
   or `master` → refuse to push; create a feature branch first
   (`git switch -c feature/<slug>`), then continue on it.

4. **Push.** `git push -u "$remote" HEAD` — `remote` from the foundation output.

5. **PR create or reuse.**
   - **gh:** reuse first — `gh pr view --json number,url -q .` on the branch; if a
     PR exists, reuse its number. Else `gh pr create --fill`. Then surface the active
     account: `gh auth status` — print which account is active (dispatch does **not**
     distinguish Antopkin vs gianhu403-hash by design; just show it so the user
     notices).
   - **forgejo:** run the setup gate from `shared/git-host.md §7` first. If `tea` is
     missing **or** there is no login for `host` → **STOP** and print the exact hint
     from §7 (no traceback). Else reuse via `tea pulls list --repo <owner>/<repo>`
     (match `--head <branch>`); if none,
     `tea pulls create --login <name> --repo <owner>/<repo> --head <branch> --base main --title <t>`.

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
   ready-to-merge command from the `shared/git-host.md §5` merge-strategy table
   (right flag per backend — e.g. gh `--squash`, tea `--style squash`). Then:
   - **state=success** → print the merge command as a **ready-to-run** command.
   - **pending / error / failure / no-checks / unreachable** → print that same command
     under the explicit label **"после зелёного CI:"** (so it can't be copy-pasted into
     a merge over incomplete CI), PLUS a watch command:
     - gh: `gh pr checks <n> --watch`
     - forgejo: poll the combined-status endpoint
       (`GET /api/v1/repos/<owner>/<repo>/commits/<headSHA>/status`) or open the Actions
       URL `https://<host>/<owner>/<repo>/actions`
     - and a `/loop` hint for long waits (e.g. `/loop 2m <re-check>`).
   - **no-checks** specifically → add the warning: **"CI не настроен — не путать с
     зелёным"**.
   - **NEVER** actually run the merge.

---

## Если push/rebase упёрся в конфликт

Host-agnostic submode.

- List conflicted files: `git diff --name-only --diff-filter=U`.
- Resolve by the **meaning of both sides** (not "take theirs/ours" blindly).
  `git add <file>` **by name** (never `git add -A` / `git add .`), then
  `git rebase --continue` (or `git merge --continue`).
- **Gate — must pass before declaring resolved:** run tests + lint
  (`pytest` / `npm test`, `ruff`). Red → loop back to resolving; do not proceed.
- **No test harness:** if `pytest` exits **5** ("no tests collected") or there is no
  `package.json` → do **not** treat as success. State explicitly: **"тестов нет, резолв
  не верифицирован автоматически"**.
- **Forbidden:** `push --force` / `-f`, `--no-verify`, and any other hook-bypass flag.

---

## Negative list

- Do **not** re-implement detection or CI-parse — reference the foundation only.
- Do **not** collapse `no-checks`/`unreachable`/empty statuses into `success`.
- Do **not** print the ready-to-merge command as ready unless CI = `success`.
- Do **not** use `git remote get-url` without `--all`; do **not** `git add -A` / `git add .`.
- Do **not** merge, force-push, or bypass hooks. Stop before merge — always.

_End of skill._
