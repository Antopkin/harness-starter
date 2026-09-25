#!/usr/bin/env bash
# retro digest: prefilter a Claude Code session transcript into a short digest in $TMPDIR.
#
# Usage: digest.sh [session-id | path/to/session.jsonl]
#   no argument   fallback only: the newest transcript of the current directory's project, which may
#                 belong to a parallel session; it warns loudly on stderr naming the file it guessed
#   session-id    <session>.jsonl in the current project, or in any project if it is not there
#   path          that transcript file
#
# Prints the digest path on stdout. When no transcript is found it says so loudly on
# stderr and exits 2: a missing transcript is never a session without friction.
# Adapted from mattpocock/skills@c55ee46 in-progress/retro (MIT).
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
root="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
slug=$(pwd | sed 's#[^A-Za-z0-9]#-#g')
arg="${1:-}"
t=""

if [[ -n $arg && -f $arg ]]; then
  t=$arg
elif [[ -n $arg ]]; then
  if [[ -f "$root/$slug/$arg.jsonl" ]]; then
    t="$root/$slug/$arg.jsonl"
  else
    t=$(ls -t "$root"/*/"$arg.jsonl" 2>/dev/null | head -n 1 || true)
  fi
else
  t=$(ls -t "$root/$slug"/*.jsonl 2>/dev/null | head -n 1 || true)
  if [[ -n $t ]]; then
    {
      echo "RETRO WARNING: NO SESSION GIVEN. Guessing the newest transcript of this project: $t"
      echo "It may belong to another session running in parallel; pass the session id to be sure."
    } >&2
    recent=$(find "$root/$slug" -maxdepth 1 -name '*.jsonl' -mmin -10 ! -path "$t" 2>/dev/null | head -n 5 || true)
    if [[ -n $recent ]]; then
      {
        echo "RETRO WARNING: OTHER TRANSCRIPTS IN THIS PROJECT CHANGED IN THE LAST 10 MINUTES, so the guess above may be the wrong session:"
        echo "$recent"
      } >&2
    fi
  fi
fi

if [[ -z $t || ! -s $t ]]; then
  {
    echo "RETRO: NO TRANSCRIPT FOUND."
    echo "Looked for: ${arg:-the newest session} under $root/$slug"
    echo "This retro reviewed nothing. Do not report 'no friction'; ask the user for the session id or path."
  } >&2
  exit 2
fi

command -v jq >/dev/null || { echo "RETRO: jq is not installed; cannot build the digest." >&2; exit 2; }

out="${TMPDIR:-/tmp}"
out="${out%/}/retro-$(basename "$t" .jsonl).digest.txt"
jq -R -r -f "$here/digest.jq" "$t" >"$out"

lines=$(wc -l <"$t" | tr -d ' ')
kept=$(wc -l <"$out" | tr -d ' ')
if [[ $kept -eq 0 ]]; then
  echo "RETRO: THE DIGEST IS EMPTY although the transcript has $lines lines. The transcript format may have changed; do not report 'no friction'." >&2
  exit 3
fi
echo "transcript: $t ($lines lines) -> digest: $kept lines" >&2
echo "$out"
