#!/usr/bin/env bash
# PreToolUse Read|Grep guard: refuse reads of Claude Code's credential store,
# the .claude.json file in your home directory (and its backups), and of
# environment files (.env*, with .env.example left readable), which AGENTS.md
# says never to read.
#
# Wiring: .claude/settings.json runs this as bash "$CLAUDE_PROJECT_DIR/hooks/read-guard.sh"
# for the Read and Grep tools. The Bash route (cat / grep / less / jq / head) is
# refused by the companion pattern at the end of hooks/bash-guard.sh.
#
# Why a hook and not a permissions.deny rule: a Read deny rule on that file makes
# Claude Code ask for interactive approval of every Bash command whose target
# directory it cannot resolve statically (the `cd <dir> && grep ...` shape that
# the built-in Explore agent composes on its own), which stalls unattended runs
# on a dialog nobody can answer. A hook is also the stronger form of the same
# protection: deny rules go inert when permissions are skipped, hooks still fire.
#
# Two details that are easy to get wrong:
#   * a Read deny rule covers Grep and Glob as well as the Read tool, so the hook
#     matches Read|Grep and reads .tool_input.file_path (Read) as well as
#     .tool_input.path and .tool_input.glob (Grep), each checked on its own, so
#     a Grep over a directory with a glob naming the file is caught too.
#     Guarding only the Read tool would protect less than the rule it replaces;
#   * the match is case-insensitive because macOS volumes are case-insensitive by
#     default, so .CLAUDE.JSON opens the very same file. Backups such as
#     .claude.json.backup hold the same secrets and are refused alike.
#
# The environment-file rule looks at the last segment of each path or glob: one
# that starts with .env is refused (.env, .env.local, .env*); .env.example and
# .env.sample are not.
#
# A Grep glob is also read the way the glob engine reads it: its braces are
# expanded ({a,b} gives a and b) and the last segment of each expansion is
# tried as a shell pattern, case-insensitively, against .env, .env.local,
# .claude.json and .claude.json.backup. Any match is refused, so {.env,x},
# [.]env and *.local are caught. The price: a glob of * or ** alone matches .env
# and is refused too; name the files you want (*.md, src/**/*.py) instead. A
# glob with more than 512 brace expansions is refused as too complex to check.
# This needs bash (the wiring runs the script with bash).
#
# What this deliberately does NOT try to be: proof against a caller that already
# has arbitrary code execution. `python3 -c`, a base64 pipe or a here-doc defeat
# any text-level filter. The threat modelled here is an agent reading the file
# by accident or by literal instruction, which is what actually happens.
#
# Without jq the guard cannot read its input, so it refuses every read until jq
# is installed rather than silently letting everything pass. A jq that is present
# but fails is treated the same way.
command -v jq >/dev/null 2>&1 || { echo "guard inactive: install jq (brew install jq / apt install jq)" >&2; exit 2; }

IN=$(cat)
P=$(printf '%s' "$IN" | jq -r '.tool_input | (.file_path, .path, .glob) | select(type == "string" and . != "")' 2>/dev/null) || { echo "guard: cannot parse hook input" >&2; exit 2; }
G=$(printf '%s' "$IN" | jq -r '.tool_input.glob | select(type == "string" and . != "")' 2>/dev/null) || { echo "guard: cannot parse hook input" >&2; exit 2; }
[ -z "$P" ] && exit 0

if printf '%s\n' "$P" | grep -qEi '(^|/)\.claude\.json([.]|$)'; then
  echo "BLOCKED: protected file: $P" >&2
  exit 2
fi
if printf '%s\n' "$P" | grep -Evi '(^|/)\.env\.(example|sample)$' | grep -qEi '(^|/)\.env[^/]*$'; then
  echo "BLOCKED: environment file (only .env.example and .env.sample may be read): $P" >&2
  exit 2
fi

# Brace expansion by hand (never eval): the innermost {...} group is replaced
# by each of its comma-separated alternatives in turn, until none is left.
EXP=(); N=0
BRACE='^(.*)[{]([^{}]*)[}](.*)$'
expand() {
  local s=$1 pre mid post rest alt
  N=$((N + 1)); [ "$N" -gt 512 ] && return 1
  if [[ $s =~ $BRACE ]]; then
    pre=${BASH_REMATCH[1]}; mid=${BASH_REMATCH[2]}; post=${BASH_REMATCH[3]}
    rest="$mid,"
    while [ -n "$rest" ]; do
      alt=${rest%%,*}; rest=${rest#*,}
      expand "$pre$alt$post" || return 1
    done
  else
    EXP+=("$s")
  fi
}
if [ -n "$G" ]; then
  expand "$G" || { echo "BLOCKED: Grep glob too complex to check: $G" >&2; exit 2; }
  shopt -s nocasematch
  for e in "${EXP[@]}"; do
    seg=${e##*/}
    [ -z "$seg" ] && continue
    for f in .env .env.local .claude.json .claude.json.backup; do
      # $seg unquoted on purpose: it is matched as a shell pattern.
      if [[ $f == $seg ]]; then
        echo "BLOCKED: Grep glob $G matches the protected file $f" >&2
        exit 2
      fi
    done
  done
fi
exit 0
