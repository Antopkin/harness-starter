#!/bin/sh
# PreToolUse Bash guard: honesty tripwire for `[skip ci]` commits.
#
# Wiring: .claude/settings.json runs this as bash "$CLAUDE_PROJECT_DIR/hooks/skip-ci-guard.sh"
# next to hooks/bash-guard.sh.
#
# Blocks a `git commit ... [skip ci]` unless every file it would commit is
# documentation: *.md, *.txt, anything under docs/, and LICENSE*. Rationale: on
# most CI services (GitHub Actions, GitLab, Forgejo) [skip ci] in a commit that
# also touches code lets code reach main without CI. A docs-only [skip ci] is
# legitimate and must pass. The allowlist names what is safe to skip rather than
# listing code extensions, so a staged .sh, .go or Dockerfile counts as code
# without anyone having to remember it.
#
# Markers recognised, in any letter case: [skip ci], [ci skip], [no ci],
# [skip actions], [actions skip] (a space, - or _ may stand between the words),
# ***NO_CI*** and a "skip-checks: true" trailer. A push with the push option
# ci.skip (git push -o ci.skip, --push-option=ci.skip) is refused outright: it
# skips CI for every commit it pushes, and this guard cannot tell which files
# those commits touch, so there is no docs-only case to let through.
#
# Which files count: the staged set (git diff --cached). When the same command
# stages files itself (git add, git commit -a / -am / --all), the index is not
# final yet, so every change against HEAD (git diff --name-only HEAD) counts too.
# git commit --amend rewrites HEAD, so the files HEAD already touches
# (git show --name-only --format= HEAD) count as well.
# Which repository: an explicit `git -C <path>`, else the target of a
# `cd <dir>` in the command, else the current directory.
#
# Without jq the guard cannot read its input, so it refuses every command until
# jq is installed rather than silently letting everything pass; a jq that is
# present but fails is treated the same way. Past that point this is a tripwire
# only: when git cannot list the files it warns on stderr and lets the commit
# through, so it is not the sole protection.
command -v jq >/dev/null 2>&1 || { echo "guard inactive: install jq (brew install jq / apt install jq)" >&2; exit 2; }

CMD=$(jq -r '.tool_input.command' 2>/dev/null) || { echo "guard: cannot parse hook input" >&2; exit 2; }
[ "$CMD" = "null" ] && exit 0
[ -z "$CMD" ] && exit 0

# A push option that skips CI is refused whatever the files.
if printf '%s\n' "$CMD" | grep -qE "git\\b[^|;&]*\\bpush\\b[^|;&]*(^|[[:space:]])(-[A-Za-z]*o[[:space:]]*|--pu[a-z-]*(=|[[:space:]]+))[\"']?ci\\.skip"; then
  echo "BLOCKED: git push with the ci.skip push option skips CI for every pushed commit, and this guard cannot see which files they touch. Push without it; mark a docs-only commit with [skip ci] instead." >&2
  exit 2
fi

# Engage only on git commit + skip-ci intent.
printf '%s\n' "$CMD" | grep -qE 'git\b[^|;&]*\bcommit\b' || exit 0
MARK='\[(skip[ _-]?ci|ci[ _-]?skip|no[ _-]?ci|skip[ _-]?actions|actions[ _-]?skip)\]|\*\*\*no_ci\*\*\*|skip-checks:[[:space:]]*true'
printf '%s\n' "$CMD" | grep -qiE "$MARK" || exit 0

# Resolve the repo dir: an explicit `git -C <path>`, else a `cd <dir>`, else the cwd.
DIR=$(printf '%s\n' "$CMD" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+([^[:space:];&|]+).*/\1/p' | head -n 1)
if [ -z "$DIR" ]; then
  DIR=$(printf '%s\n' "$CMD" | sed -nE 's/(^|.*[;&|([:space:]])cd[[:space:]]+([^[:space:];&|)]+).*/\2/p' | head -n 1)
fi
DIR=$(printf '%s' "$DIR" | tr -d "\"'")
case "$DIR" in
  "~") DIR="$HOME" ;;
  "~/"*) DIR="$HOME/${DIR#"~/"}" ;;
esac
[ -z "$DIR" ] && DIR="."

warn() { echo "skip-ci-guard: could not list the files of this commit in $DIR ($1); [skip ci] not checked" >&2; exit 0; }

FILES=$(git -C "$DIR" diff --cached --name-only 2>/dev/null) || warn "git diff --cached failed"
if printf '%s\n' "$CMD" | grep -qE 'git\b[^|;&]*\badd\b|git\b[^|;&]*\bcommit\b[^|;&]*[[:space:]](-[A-Za-z]*a[A-Za-z]*|--all)([[:space:]]|$)'; then
  MORE=$(git -C "$DIR" diff --name-only HEAD 2>/dev/null) || warn "git diff HEAD failed"
  FILES=$(printf '%s\n%s\n' "$FILES" "$MORE")
fi
if printf '%s\n' "$CMD" | grep -qE 'git\b[^|;&]*\bcommit\b[^|;&]*[[:space:]]--am[a-z]*([[:space:]]|$)'; then
  MORE=$(git -C "$DIR" show --name-only --format= HEAD 2>/dev/null) || warn "git show HEAD failed"
  FILES=$(printf '%s\n%s\n' "$FILES" "$MORE")
fi
FILES=$(printf '%s\n' "$FILES" | grep -v '^$' | sort -u)
[ -z "$FILES" ] && exit 0

DOCS='\.(md|txt)$|^docs/|(^|/)LICENSE[^/]*$'
CODE=$(printf '%s\n' "$FILES" | grep -vE "$DOCS")
if [ -n "$CODE" ]; then
  echo "BLOCKED: [skip ci] on a commit with non-documentation files (dishonest skip). Files:" >&2
  printf '%s\n' "$CODE" >&2
  exit 2
fi
exit 0
