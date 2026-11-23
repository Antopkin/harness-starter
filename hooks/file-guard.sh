#!/bin/sh
# PreToolUse Edit|Write|MultiEdit|NotebookEdit guard: block writes to protected
# and secret files.
#
# Wiring: .claude/settings.json runs this as bash "$CLAUDE_PROJECT_DIR/hooks/file-guard.sh"
# for the Edit, Write, MultiEdit and NotebookEdit tools. Exit 2 blocks the call and shows stderr to the
# agent; exit 0 lets it through.
#
# History: an earlier inline version used a PCRE lookahead `(?!example)`, which
# is invalid in `grep -E`. grep then exited 2 on every call, the `if` was never
# true, and NOTHING was blocked. This standalone script removes the
# JSON-escaping and quoting surface entirely, and hooks/hooks-selftest.sh runs
# it through the exact command wired in the settings so that class of bug shows.
#
# Without jq the guard cannot read its input, so it refuses every edit until jq
# is installed rather than silently letting everything pass. A jq that is present
# but fails is treated the same way.
command -v jq >/dev/null 2>&1 || { echo "guard inactive: install jq (brew install jq / apt install jq)" >&2; exit 2; }

# The path is .tool_input.file_path (Edit, Write, MultiEdit), falling back to
# .tool_input.notebook_path (NotebookEdit).
P=$(jq -r '.tool_input | [.file_path?, .notebook_path?] | map(select(type == "string" and . != "")) | .[0] // empty' 2>/dev/null) || { echo "guard: cannot parse hook input" >&2; exit 2; }
[ -z "$P" ] && exit 0
[ "$P" = "null" ] && exit 0

grep_match() {
  case $1 in
    0) return 0 ;;
    1) return 1 ;;
    *) echo "guard: grep failed while checking the file path" >&2; exit 2 ;;
  esac
}

matches() {
  printf '%s\n' "$1" | grep -qEi "$2"
  grep_match "$?"
}

# Every match below is case-insensitive: macOS volumes are case-insensitive by
# default, so .ENV and .Git/config open the very same files.
# The sample exception applies only to the basename. Protected ancestors
# are checked for every path, including paths ending in a sample.
non_samples=$(printf '%s\n' "$P" | grep -Evi '(^|/)\.env\.(example|sample)$')
if grep_match "$?" && matches "$non_samples" '(^|/)\.env[^/]*$'; then
  echo "BLOCKED: protected file: $P" >&2
  exit 2
fi

# Block: .env* directories, anything under .git/, a
# worktree's .git file itself, and anything under a secrets/ directory.
BLOCK='(^|/)\.env[^/]*/|(^|/)\.git/|(^|/)\.git$|(^|/)secrets/'
if matches "$P" "$BLOCK"; then
  echo "BLOCKED: protected file: $P" >&2
  exit 2
fi

# Credential files. The rule is NARROW on purpose and looks at the file name
# only: it must end in a secret-ish extension AND name a credential or secret,
# or carry token as a word of its own (token.json, api_token.json,
# gh-tokens.json). So a note such as memory/reference_token_rotation.md, a
# tokenizer.json and a design-token tokens.json stay editable.
NAME=${P##*/}
if matches "$NAME" '\.(txt|json|env|pem|key)$' \
   && matches "$NAME" 'credential|secret|(^|[_.-])token[_.-]|[_.-]tokens[_.-]'; then
  echo "BLOCKED: protected file: $P" >&2
  exit 2
fi
exit 0
