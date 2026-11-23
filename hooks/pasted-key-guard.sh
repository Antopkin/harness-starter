#!/usr/bin/env bash
# UserPromptSubmit guard: trip when an API key or a private key is pasted in
# plain text into a prompt, where it would otherwise land in the transcript
# verbatim.
#
# Wiring: .claude/settings.json runs this as bash "$CLAUDE_PROJECT_DIR/hooks/pasted-key-guard.sh".
# Exit 2 blocks the prompt and shows the reason to you; exit 0 lets it through.
#
# jq decodes the top-level prompt string. Hook metadata is outside the scan.
# If jq is missing or fails, scan the raw input for contiguous keys and
# private-key headers using Bash builtins.
#
# A speed bump, not a boundary: do NOT grow the pattern set beyond the known
# high-signal key shapes below. The real fix for secrets in transcripts is to
# keep them out of the session (environment variables, a secrets manager), not
# an ever-widening regex.
#
# High-signal key shapes:
#   sk-ant-...           Anthropic API keys
#   github_pat_...       GitHub fine-grained personal access tokens
#   gh[pousr]_...        GitHub classic tokens (ghp_/gho_/ghu_/ghs_/ghr_)
#   xox[baprse]-, xoxe.xox[pb]-, xapp-  Slack tokens
#   AKIA / ASIA + 16     AWS access key IDs (long-term / temporary)
#   sk-proj-, sk-svcacct-, sk-admin-   OpenAI project, service-account, admin keys
#   sk- + 20 + T3BlbkFJ  OpenAI legacy user keys
#   sk_live_, rk_live_   Stripe live secret and restricted keys
#   AIza + 35            Google API keys
#   glpat-...            GitLab personal access tokens
#   hf_ + 30 or more     Hugging Face tokens
#   PEM or PGP private-key header followed by key material
#
# A masked example whose body is only a run of X (sk-proj-XXXX..., AKIAXXXX...)
# is let through, so the format can still be discussed, and so is an AWS key
# whose body ends in EXAMPLE (AWS's own documentation key, AKIA...EXAMPLE).
# Every match in the prompt is checked, so a masked example cannot shield a
# real key after it.
# Split forms allow one gap after a supported prefix, or one line wrap inside
# its body. The rejoined body must match that format's alphabet and minimum.
SLACK='xox[baprse]-|xoxe\.xox[pb]-|xapp-'
# Check the components of each Slack format after joining a split token.
# Bot tokens can have one (legacy) or two numeric IDs.
SLACK_JOINED='xoxb-([0-9]{8,}-){1,2}[A-Za-z0-9]{18,}'\
'|xoxp-([0-9]{8,}-){3}[A-Za-z0-9]{6,}'\
'|xoxs-([0-9]{8,}-){3}[A-Fa-f0-9]+'\
'|xox[ar]-[0-9]-[A-Za-z0-9]{10,}'\
'|xoxe-([0-9]-[A-Za-z0-9]{16,}|([0-9]{8,}-){3}[A-Za-z0-9]{6,})'\
'|xoxe\.xox[pb]-[0-9](-[0-9]+){0,3}-[A-Za-z0-9]{16,}'\
'|xapp-[0-9]+-[A-Z][A-Z0-9]+-[0-9]+-[A-Za-z0-9]{10,}'
ANTHROPIC='sk-ant-(api[0-9]+-)?'
SPLIT="($ANTHROPIC|sk-(proj|svcacct|admin)-|[sr]k_live_|github_pat_|gh[pousr]_|$SLACK|glpat-|hf_)"
SPLIT_KEYS="(sk-(proj|svcacct|admin)-|glpat-)[A-Za-z0-9_-]{20,}|([sr]k_live_|gh[pousr]_)[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{22,}|hf_[A-Za-z0-9]{30,}|($SLACK)[A-Za-z0-9-]{10,}"
KEYS="$SPLIT_KEYS|sk-ant-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{20}T3BlbkFJ[A-Za-z0-9]*|A[KS]IA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}"
PREFIX="^($SPLIT|A[KS]IA|AIza)"
BOUNDARY='(^|[^A-Za-z0-9_-]|\\u[0-9A-Fa-f]{4})'
END='($|[^A-Za-z0-9_-])'
WORD='[A-Za-z0-9_-]+'
GAP='([[:space:]]|\\[ntr])+'
NL=$'\n'; CR=$'\r'
WRAP="[[:blank:]]*($CR?$NL|$CR|\\\\[nr])[[:blank:]]*"
MASKED='^[Xx]+$'
AWSDOC='^A[KS]IA[0-9A-Z]*EXAMPLE$'
ARMOR_HEADER='-----BEGIN [A-Z ]*PRIVATE KEY( BLOCK)?-----'

block_key() {
  echo "BLOCKED: a value in your prompt matches an API-key or private-key pattern. If it is a real credential, rotate it: it may already be in the transcript. If it is an example or you are discussing the format, mask the fragment (for example sk-ant-XXXX) and resend." >&2
  exit 2
}

scan_keys() {
  local pat=$1 key_group=$2 split=${3:-} rest=$prompt whole key body
  while [[ $rest =~ $pat ]]; do
    whole=${BASH_REMATCH[0]}; key=${BASH_REMATCH[$key_group]}
    rest=${rest#*"$whole"}
    if [ -n "$split" ]; then
      key=${key//\\[ntr]/}
      key=${key//[[:space:]]/}
      [[ $key =~ $PREFIX ]] || continue
      body=${key:${#BASH_REMATCH[0]}}
      if [[ $key =~ ^$ANTHROPIC ]]; then
        [[ $body =~ ^[A-Za-z0-9_-]{20,}$ ]] || continue
      else
        [[ $key =~ ^($SPLIT_KEYS)$ ]] || continue
        if [[ $key =~ ^($SLACK) ]]; then
          [[ $key =~ ^($SLACK_JOINED)$ ]] || continue
        fi
      fi
    else
      body=$key
      [[ $key =~ $PREFIX ]] && body=${key:${#BASH_REMATCH[0]}}
    fi
    [[ $body =~ $MASKED || $key =~ $AWSDOC ]] || block_key
  done
}

scan_bounded_keys() {
  local pattern=$1 split=${2:-} emphasis
  scan_keys "$BOUNDARY($pattern)" 2 "$split"
  for emphasis in _ __ ___; do
    scan_keys "$BOUNDARY$emphasis($pattern)$emphasis$END" 2 "$split"
  done
}

IFS= read -r -d '' input || true
LC_ALL=C
# Bash cannot store NUL; substitute a non-whitespace control delimiter. The
# final period preserves trailing newlines through command substitution.
if ! prompt=$(printf '%s' "$input" | jq -rs 'if length == 1 then .[0].prompt | strings else error("expected one hook payload") end | gsub("\u0000"; "\u0001") + "."' 2>/dev/null); then
  prompt=$input
  # Preserve the raw substring scan for installations without a working jq.
  scan_keys "$KEYS|$ARMOR_HEADER" 0
  exit 0
fi
prompt=${prompt%.}
[ -n "$prompt" ] || exit 0

# Remove common invisible characters and their literal Unicode escape forms.
for invisible in '\302\255' '\342\200\213' '\342\200\214' '\342\200\215' '\342\201\240' \
                 '\342\201\241' '\342\201\242' '\342\201\243' '\342\201\244' '\357\273\277'; do
  printf -v char '%b' "$invisible"
  prompt=${prompt//"$char"/}
done
prompt=${prompt//\\u200[bBcCdD]/}; prompt=${prompt//\\u206[0-4]/}
prompt=${prompt//\\u[fF][eE][fF][fF]/}; prompt=${prompt//\\u00[aA][dD]/}

scan_bounded_keys "$KEYS"
for split_key in "$SPLIT$GAP$WORD" "$SPLIT$WORD$WRAP$WORD"; do
  scan_bounded_keys "$split_key" split
done

# Require a separate base64-like line after the armor header. Blank lines and
# armor metadata may come before the first fragment, including short fragments.
PEM="$ARMOR_HEADER[[:blank:]]*$CR?$NL"
ARMOR_LINE="[[:blank:]]*([A-Za-z-]+:[^$NL]*)?$CR?$NL"
ARMOR_BODY="[[:blank:]]*[A-Za-z0-9+/]{6,}={0,2}[[:blank:]]*$CR?($NL|$)"
[[ $prompt =~ $PEM($ARMOR_LINE)*$ARMOR_BODY ]] && block_key
exit 0
