#!/usr/bin/env bash
# UserPromptSubmit guard: trip when an API key or a private key is pasted in
# plain text into a prompt, where it would otherwise land in the transcript
# verbatim.
#
# Wiring: .claude/settings.json runs this as bash "$CLAUDE_PROJECT_DIR/hooks/pasted-key-guard.sh".
# Exit 2 blocks the prompt and shows the reason to you; exit 0 lets it through.
#
# It needs no outside tool at all, not even jq, grep or cat. The whole hook
# payload is read with bash's builtin read and matched with its builtin
# [[ =~ ]], so a missing tool can neither block an ordinary prompt nor let a
# key through. The payload is JSON, but none of the
# key shapes below contains a character JSON escapes, so matching the raw text
# is as good as matching the decoded prompt.
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
#   xox[baprs]-...       Slack tokens
#   AKIA / ASIA + 16     AWS access key IDs (long-term / temporary)
#   sk-proj-, sk-svcacct-, sk-admin-   OpenAI project, service-account, admin keys
#   sk- + 20 + T3BlbkFJ  OpenAI legacy user keys
#   sk_live_, rk_live_   Stripe live secret and restricted keys
#   AIza + 35            Google API keys
#   glpat-...            GitLab personal access tokens
#   hf_ + 30 or more     Hugging Face tokens
#   -----BEGIN ... PRIVATE KEY-----        PEM private-key header
#   -----BEGIN PGP PRIVATE KEY BLOCK-----  PGP private-key header
#
# A masked example whose body is only a run of X (sk-proj-XXXX..., AKIAXXXX...)
# is let through, so the format can still be discussed, and so is an AWS key
# whose body ends in EXAMPLE (AWS's own documentation key, AKIA...EXAMPLE).
# Every match in the prompt is checked, so a masked example cannot shield a
# real key after it.
IFS= read -r -d '' input || true

PAT='sk-ant-[A-Za-z0-9_-]{20,}|sk-(proj|svcacct|admin)-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{20}T3BlbkFJ[A-Za-z0-9]*|[sr]k_live_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{22,}|gh[pousr]_[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|A[KS]IA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|glpat-[A-Za-z0-9_-]{20,}|hf_[A-Za-z0-9]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY( BLOCK)?-----'
PREFIX='^(sk-ant-(api[0-9]+-)?|sk-(proj|svcacct|admin)-|[sr]k_live_|github_pat_|gh[pousr]_|xox[baprs]-|A[KS]IA|AIza|glpat-|hf_)'
MASKED='^[Xx]+$'
AWSDOC='^A[KS]IA[0-9A-Z]*EXAMPLE$'
rest=$input
while [[ $rest =~ $PAT ]]; do
  m=${BASH_REMATCH[0]}
  body=$m
  [[ $m =~ $PREFIX ]] && body=${m:${#BASH_REMATCH[0]}}
  if ! [[ $body =~ $MASKED || $m =~ $AWSDOC ]]; then
    echo "BLOCKED: a value in your prompt matches an API-key or private-key pattern. If it is a real credential, rotate it: it may already be in the transcript. If it is an example or you are discussing the format, mask the fragment (for example sk-ant-XXXX) and resend." >&2
    exit 2
  fi
  rest=${rest#*"$m"}
done
exit 0
