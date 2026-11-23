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
# tried as a case-insensitive shell pattern against dotenv and credential-store
# names. Broad JSON globs are allowed at project roots. At sensitive roots,
# tests also use the protected names at that location, including actual Claude
# backup names. A glob such as * is refused everywhere because it matches .env.
# More than 512 brace expansions are refused as too complex to check.
# This needs bash (the wiring runs the script with bash).
#
# Claude Code splits a Grep glob on whitespace, then each piece on commas unless
# the piece holds braces, and passes each part to ripgrep as its own --glob. The
# guard splits the same way and runs every part, as well as the whole glob,
# through the checks above, so *.md,.env and "*.md .env" are refused. A part
# that starts with ! is refused outright: ripgrep reads it as "every file but
# these", hidden ones included.
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
P=$(printf '%s' "$IN" | jq -r '.tool_input | (.file_path, .path) | select(type == "string" and . != "")' 2>/dev/null) || { echo "guard: cannot parse hook input" >&2; exit 2; }
G=$(printf '%s' "$IN" | jq -r '.tool_input.glob | select(type == "string" and . != "")' 2>/dev/null) || { echo "guard: cannot parse hook input" >&2; exit 2; }
CWD=$(printf '%s' "$IN" | jq -r '.cwd | select(type == "string" and . != "")' 2>/dev/null) || { echo "guard: cannot parse hook input" >&2; exit 2; }
CWD=${CWD:-$PWD}

absolute_path() {
  case $1 in
    \~) printf '%s' "$HOME" ;;
    \~/*) printf '%s' "$HOME/${1:2}" ;;
    /*) printf '%s' "$1" ;;
    *) printf '%s' "$CWD/$1" ;;
  esac
}

physical_dir() (
  unset CDPATH
  cd -P -- "$1" 2>/dev/null && pwd -P
)

normalize_dir() {
  local path=$1 clean='' segment IFS=/
  set -f
  for segment in $path; do
    case $segment in
      ''|.) ;;
      ..) clean=${clean%/*} ;;
      *) clean=$clean/$segment ;;
    esac
  done
  printf '%s' "${clean:-/}"
}

CLAUDE=0; CODEX=0; HOME_DIRS=(); BACKUP_DIRS=()
# Record which stores a root can reach, including the macOS data-volume alias.
# The caller enables case-insensitive matching.
check_root() {
  local dir=$1 home
  [ "$dir" = / ] && CLAUDE=1
  [ -n "$HOME" ] || return 0
  for home in "$HOME" "/System/Volumes/Data$HOME"; do
    home=$(normalize_dir "$home")
    if [[ $dir == / || $home == "$dir" || $home == "$dir"/* ]]; then
      CLAUDE=1; CODEX=1
      HOME_DIRS+=("$home")
      BACKUP_DIRS+=("$home/.claude/backups")
    elif [[ $dir == "$home/.claude" ]]; then
      CLAUDE=1
      BACKUP_DIRS+=("$dir/backups")
    elif [[ $dir == "$home/.claude/backups" || $dir == "$home/.claude/backups"/* ]]; then
      CLAUDE=1
      BACKUP_DIRS+=("$dir")
    elif [[ $dir == "$home/.codex" ]]; then
      CODEX=1
    fi
  done
}

# A broad Grep runs ripgrep with --hidden. Resolve its root both lexically and
# physically so relative paths, dot segments and directory symlinks count.
GREP=$(printf '%s' "$IN" | jq -r 'if ((.tool_name // "") | ascii_downcase) == "grep" or .tool_input.pattern != null then "1" else empty end' 2>/dev/null) || { echo "guard: cannot parse hook input" >&2; exit 2; }
if [ -n "$GREP" ] || [ -n "$G" ]; then
  ROOT=$(printf '%s' "$IN" | jq -r '.tool_input.path | select(type == "string" and . != "")' 2>/dev/null) || { echo "guard: cannot parse hook input" >&2; exit 2; }
  TYPE=$(printf '%s' "$IN" | jq -r '.tool_input.type | select(type == "string" and . != "")' 2>/dev/null) || { echo "guard: cannot parse hook input" >&2; exit 2; }
  r=$(absolute_path "${ROOT:-$CWD}")
  shopt -s nocasematch
  lexical=$(normalize_dir "$r")
  check_root "$lexical"
  if physical=$(physical_dir "$r") && [ "$physical" != "$lexical" ]; then
    check_root "$physical"
  fi
  shopt -u nocasematch
  if [ -n "$GREP" ] && { [ "$CLAUDE" -eq 1 ] || [ "$CODEX" -eq 1 ]; } && { [ -z "$G" ] || [ -n "$TYPE" ]; }; then
    echo "BLOCKED: a Grep with no glob (or with a type filter) rooted at $r can search hidden credential files. Use a project directory or a glob that names the files you want." >&2
    exit 2
  fi
fi

# Keep each original target and check its basename in the resolved parent.
# Fall back to lexical normalization when the parent does not exist.
P=$(printf '%s\n' "$P" | while IFS= read -r target; do
  [ -n "$target" ] || continue
  printf '%s\n' "$target"
  absolute=$(absolute_path "$target")
  parent=${absolute%/*}; parent=${parent:-/}
  resolved=$(physical_dir "$parent") || resolved=$(normalize_dir "$parent")
  normalized=${resolved%/}/${absolute##*/}
  [ "$normalized" = "$target" ] || printf '%s\n' "$normalized"
done)

# Split the glob as Claude Code does. Whitespace is JavaScript's \s, so the
# Unicode spaces (U+00A0, U+1680, U+2000-200A, U+2028/9, U+202F, U+205F,
# U+3000, U+FEFF) become plain spaces first.
PARTS=()
if [ -n "$G" ]; then
  S=$G
  for u in $(printf '\302\240 \341\232\200 \342\200\200 \342\200\201 \342\200\202 \342\200\203 \342\200\204 \342\200\205 \342\200\206 \342\200\207 \342\200\210 \342\200\211 \342\200\212 \342\200\250 \342\200\251 \342\200\257 \342\201\237 \343\200\200 \357\273\277'); do
    S=${S//"$u"/ }
  done
  OIFS=$IFS; IFS=$' \t\n\v\f\r'; set -f
  for piece in $S; do
    if [[ $piece == *[{]* && $piece == *[}]* ]]; then
      PARTS+=("$piece")
    else
      rest="$piece,"
      while [ -n "$rest" ]; do
        a=${rest%%,*}; rest=${rest#*,}
        [ -n "$a" ] && PARTS+=("$a")
      done
    fi
  done
  set +f; IFS=$OIFS
  for a in "${PARTS[@]}"; do
    case $a in
      '!'*) echo "BLOCKED: negated Grep glob $a would search every other file, hidden ones included" >&2; exit 2 ;;
    esac
  done
  P=$(printf '%s\n' "$P" "$G" "${PARTS[@]}")
fi
[ -z "$P" ] && exit 0

if printf '%s\n' "$P" | grep -qEi '(^|/)(\.claude\.json([.]|$)|\.codex/auth\.json$)'; then
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
  for a in "$G" "${PARTS[@]}"; do
    expand "$a" || { echo "BLOCKED: Grep glob too complex to check: $G" >&2; exit 2; }
  done
  NAMES=(.env .env.local .env.production .env.development .env.test .envrc .claude.json.backup)
  [ "$CODEX" -eq 1 ] && NAMES+=(auth.json)

  # Collect names only. Search the home directory non-recursively and descend
  # only into the Claude backup tree (or the subtree rooted at the Grep path).
  shopt -s nullglob nocaseglob
  for dir in "${HOME_DIRS[@]}"; do
    for entry in "$dir"/.claude.json.*; do NAMES+=("${entry##*/}"); done
  done
  for dir in "${BACKUP_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    listed=0
    while IFS= read -r -d '' entry; do
      if [ -z "$entry" ]; then listed=1; break; fi
      NAMES+=("${entry##*/}")
    done < <(find -H "$dir" -iname '.claude.json.*' -print0 2>/dev/null && printf '\0')
    if [ "$listed" -eq 0 ]; then
      echo "guard: cannot list Claude backup names" >&2
      exit 2
    fi
  done
  shopt -u nullglob nocaseglob

  STORE='^\.claude\.json([.]|$)'
  shopt -s nocasematch
  for e in "${EXP[@]}"; do
    seg=${e##*/}
    [ -z "$seg" ] && continue
    if [[ $seg =~ $STORE ]] || { [[ .claude.json == $seg ]] && { [ "$CLAUDE" -eq 1 ] || [[ $seg != '*.json' ]]; }; }; then
      echo "BLOCKED: Grep glob $G names the credential store or a backup" >&2
      exit 2
    fi
    for f in "${NAMES[@]}"; do
      # $seg unquoted on purpose: it is matched as a shell pattern.
      if [[ $f == $seg ]]; then
        echo "BLOCKED: Grep glob $G matches the protected file $f" >&2
        exit 2
      fi
    done
  done
fi
exit 0
