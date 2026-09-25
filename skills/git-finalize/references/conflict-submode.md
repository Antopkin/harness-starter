# If push/rebase hits a conflict

Host-agnostic submode of `git-finalize`.

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
