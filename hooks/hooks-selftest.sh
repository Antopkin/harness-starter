#!/bin/sh
# Hooks self-test. Extracts the FULL hook command strings from a settings.json
# (argument $1, default <repo>/.claude/settings.json), feeds each test case to
# them as simulated JSON on stdin, and asserts the aggregate exit code. Running
# the real wired command strings (not just the regexes) catches quoting, rc=2
# and path bugs that a regex-only test would miss: exactly the class of bug
# that once left hooks/file-guard.sh blocking nothing at all.
#
# Usage, from anywhere:
#   bash hooks/hooks-selftest.sh                 # tests .claude/settings.json of this repo
#   bash hooks/hooks-selftest.sh path/to/settings.json
#
# The wired commands refer to "$CLAUDE_PROJECT_DIR/hooks/...", so the script
# exports CLAUDE_PROJECT_DIR as the repo root, just as Claude Code does. It needs
# jq and git itself; the guards are also run once with jq removed from PATH, and
# once with a jq that fails, to prove they fail closed. Dangerous test tokens
# and fake keys are assembled from
# fragments so this file never contains a contiguous dangerous command or key.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
export CLAUDE_PROJECT_DIR="$ROOT"
SETTINGS="${1:-$ROOT/.claude/settings.json}"
[ -f "$SETTINGS" ] || { echo "FATAL: settings not found: $SETTINGS" >&2; exit 3; }
command -v jq >/dev/null 2>&1 || { echo "FATAL: the self-test needs jq (brew install jq / apt install jq)" >&2; exit 3; }
command -v git >/dev/null 2>&1 || { echo "FATAL: the self-test needs git" >&2; exit 3; }
SH=$(command -v sh)

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

jq -r '.hooks.PreToolUse[]? | select(.matcher=="Bash") | .hooks[].command' "$SETTINGS" > "$TMP/bash_hooks.txt"
jq -r '.hooks.PreToolUse[]? | select(.matcher=="Edit|Write|MultiEdit|NotebookEdit") | .hooks[].command' "$SETTINGS" > "$TMP/file_hooks.txt"
jq -r '.hooks.PreToolUse[]? | select(.matcher=="Read|Grep") | .hooks[].command' "$SETTINGS" > "$TMP/read_hooks.txt"
jq -r '.hooks.UserPromptSubmit[]? | .hooks[].command' "$SETTINGS" > "$TMP/prompt_hooks.txt"
grep 'skip-ci-guard' "$TMP/bash_hooks.txt" > "$TMP/skipci_hooks.txt"

# A PATH with everything the guards may need at start-up except jq.
mkdir -p "$TMP/nojq"
for t in bash sh cat env; do
  p=$(command -v "$t") && ln -s "$p" "$TMP/nojq/$t"
done
# A jq that is present but fails, first on PATH.
mkdir -p "$TMP/badjq"
printf '#!/bin/sh\nexit 126\n' > "$TMP/badjq/jq"; chmod +x "$TMP/badjq/jq"

run_hooks() {  # <hooks_file> <json> [PATH] -> echoes 2 if any hook exits 2, else 0
  hf="$1"; json="$2"; path="${3:-$PATH}"; result=0
  while IFS= read -r hk; do
    [ -z "$hk" ] && continue
    rc=0
    printf '%s' "$json" | PATH="$path" "$SH" -c "$hk" >/dev/null 2>&1 || rc=$?
    [ "$rc" -eq 2 ] && result=2
  done < "$hf"
  echo "$result"
}

PASS=0; FAIL=0
report() {  # <label> <expect> <got>
  want=0; [ "$2" = "block" ] && want=2
  if [ "$3" -eq "$want" ]; then
    PASS=$((PASS+1)); printf 'PASS  [%s] %s\n' "$2" "$1"
  else
    FAIL=$((FAIL+1)); printf 'FAIL  [want=%s got=%s] %s\n' "$2" "$3" "$1"
  fi
}
payload() {  # <kind> <input>
  case "$1" in
    file)   jq -n --arg p "$2" '{tool_name:"Write", tool_input:{file_path:$p}}' ;;
    notebook) jq -n --arg p "$2" '{tool_name:"NotebookEdit", tool_input:{notebook_path:$p, new_source:"x"}}' ;;
    read)   jq -n --arg p "$2" '{tool_name:"Read", tool_input:{file_path:$p}}' ;;
    grep)   jq -n --arg p "$2" '{tool_name:"Grep", tool_input:{pattern:"x", path:$p}}' ;;
    grepglob) jq -n --arg d "$ROOT" --arg g "$2" '{tool_name:"Grep", tool_input:{pattern:"x", path:$d, glob:$g}}' ;;
    greptype) jq -n --arg p "$2" '{tool_name:"Grep", tool_input:{pattern:"x", path:$p, type:"py"}}' ;;
    grepcwd)  jq -n --arg c "$2" '{tool_name:"Grep", tool_input:{pattern:"x"}, cwd:$c}' ;;
    grephome) jq -n --arg p "$HOME" --arg g "$2" '{tool_name:"Grep", tool_input:{pattern:"x", path:$p, glob:$g}}' ;;
    prompt) jq -n --arg p "$2" '{hook_event_name:"UserPromptSubmit", prompt:$p}' ;;
    *)      jq -n --arg c "$2" '{tool_name:"Bash", tool_input:{command:$c}}' ;;
  esac
}
hooks_for() {  # <kind> -> hooks file
  case "$1" in
    file|notebook) echo "$TMP/file_hooks.txt" ;;
    read|grep|grepglob|greptype|grepcwd|grephome) echo "$TMP/read_hooks.txt" ;;
    prompt) echo "$TMP/prompt_hooks.txt" ;;
    skipci) echo "$TMP/skipci_hooks.txt" ;;
    *) echo "$TMP/bash_hooks.txt" ;;
  esac
}
check() {  # <label> <file|read|grep|prompt|bash> <input> <block|allow>
  report "$1" "$4" "$(run_hooks "$(hooks_for "$2")" "$(payload "$2" "$3")")"
}
check_nojq() {  # same, with jq missing from PATH
  report "$1" "$4" "$(run_hooks "$(hooks_for "$2")" "$(payload "$2" "$3")" "$TMP/nojq")"
}
check_badjq() {  # same, with a failing jq first on PATH
  report "$1" "$4" "$(run_hooks "$(hooks_for "$2")" "$(payload "$2" "$3")" "$TMP/badjq:$PATH")"
}

echo "== wiring =="
for k in bash file read prompt; do
  n=$(grep -c . "$(hooks_for "$k")")
  if [ "$n" -gt 0 ]; then PASS=$((PASS+1)); printf 'PASS  %s hooks wired: %s\n' "$k" "$n"
  else FAIL=$((FAIL+1)); printf 'FAIL  no %s hook wired in %s\n' "$k" "$SETTINGS"; fi
done

# skip-ci fixtures: two throwaway repos (one code-staged, one docs-staged)
REPO_PY="$TMP/repo_py"; REPO_MD="$TMP/repo_md"
for R in "$REPO_PY" "$REPO_MD"; do
  mkdir -p "$R"; git -C "$R" init -q; git -C "$R" config user.email t@t; git -C "$R" config user.name t
done
printf 'x=1\n' > "$REPO_PY/mod.py"; git -C "$REPO_PY" add mod.py
printf '# doc\n' > "$REPO_MD/doc.md"; git -C "$REPO_MD" add doc.md
# three more: a staged shell script, and two with a first commit and unstaged
# edits (code in one, docs only in the other) for commands that stage themselves
REPO_SH="$TMP/repo_sh"; REPO_CM="$TMP/repo_cm"; REPO_DOC="$TMP/repo_doc"
for R in "$REPO_SH" "$REPO_CM" "$REPO_DOC"; do
  mkdir -p "$R"; git -C "$R" init -q; git -C "$R" config user.email t@t; git -C "$R" config user.name t
  git -C "$R" config commit.gpgsign false
done
printf 'echo hi\n' > "$REPO_SH/tool.sh"; git -C "$REPO_SH" add tool.sh
printf 'echo hi\n' > "$REPO_CM/run.sh"; git -C "$REPO_CM" add run.sh; git -C "$REPO_CM" commit -q -m init
printf 'echo bye\n' > "$REPO_CM/run.sh"
printf '# doc\n' > "$REPO_DOC/README.md"; printf 'MIT\n' > "$REPO_DOC/LICENSE"
git -C "$REPO_DOC" add README.md LICENSE; git -C "$REPO_DOC" commit -q -m init
printf '# doc, edited\n' > "$REPO_DOC/README.md"; printf 'MIT, edited\n' > "$REPO_DOC/LICENSE"
# one more: HEAD touches code, only a doc is staged, for git commit --amend
REPO_AM="$TMP/repo_am"
mkdir -p "$REPO_AM"; git -C "$REPO_AM" init -q; git -C "$REPO_AM" config user.email t@t; git -C "$REPO_AM" config user.name t
git -C "$REPO_AM" config commit.gpgsign false
printf 'echo hi\n' > "$REPO_AM/run.sh"; git -C "$REPO_AM" add run.sh; git -C "$REPO_AM" commit -q -m init
printf '# doc\n' > "$REPO_AM/README.md"; git -C "$REPO_AM" add README.md

# dangerous tokens from fragments
RST="rese""t"; HRD="--ha""rd"; PSH="pu""sh"; FRC="--for""ce"; NV="--no-ver""ify"; RMR="r""m"; RF="-r""f"
FRO="-f""r"; RSEP="-R"; FSEP="-f"  # flag-order and case variants
CJ=".claude"".json"                # the credential store's file name
MEM="$ROOT/memory"

echo "== FILE guard =="
check ".env"                     file ".env"                                  block
check ".env in project root"     file "$ROOT/.env"                            block
check ".env.production"          file "app/.env.production"                   block
check ".git/config"              file ".git/config"                           block
check "secrets/ jwt"             file "secrets/service_jwt.txt"               block
check "token json"               file "config/api_token.json"                 block
check ".env.example ALLOW"       file ".env.example"                          allow
check "memory token note ALLOW"  file "$MEM/feedback_token_short_lived.md"    allow
check "memory rotation ALLOW"    file "$MEM/reference_token_rotation.md"      allow
check "memory credentials ALLOW" file "$MEM/project_credentials_strategy.md"  allow
check "normal doc ALLOW"         file "docs/modules/pipeline.md"              allow
check ".ENV upper-case"          file ".ENV"                                  block
check ".Env.Local mixed case"    file "app/.Env.Local"                        block
check ".envrc"                   file ".envrc"                                block
check ".GIT/config upper-case"   file ".GIT/config"                           block
check "API_TOKEN.JSON upper"     file "config/API_TOKEN.JSON"                 block
check ".Env.Example ALLOW"       file "app/.Env.Example"                      allow
# last hardening round: notebook_path, the worktree gitfile, a narrower token rule
check "notebook .env BLOCK"      notebook "$ROOT/.env"                        block
check "notebook under .git BLOCK" notebook ".git/hooks/nb.ipynb"              block
check "notebook ALLOW"           notebook "notebooks/analysis.ipynb"          allow
check "worktree .git file BLOCK" file "/tmp/wt/.git"                          block
check "bare .git BLOCK"          file ".git"                                  block
check ".github/ ALLOW"           file ".github/workflows/ci.yml"              allow
check "token.json BLOCK"         file "token.json"                            block
check "gh-tokens.json BLOCK"     file "config/gh-tokens.json"                 block
check "client_secret.json BLOCK" file "client_secret.json"                    block
check "tokenizer.json ALLOW"     file "models/tokenizer.json"                 allow
check "tokens.json ALLOW"        file "design/tokens.json"                    allow
check ".env.sample ALLOW"        file ".env.sample"                           allow
check "src/app.py ALLOW"         file "src/app.py"                            allow

echo "== READ guard =="
check "Read credential store"    read "$TMP/fakehome/$CJ"                     block
check "Read upper-case variant"  read "$TMP/fakehome/.CLAUDE.JSON"            block
check "Grep credential store"    grep "$TMP/fakehome/$CJ"                     block
check "Read README ALLOW"        read "$ROOT/README.md"                       allow
check "Read settings ALLOW"      read "$ROOT/.claude/settings.json"           allow
check "Read store backup"        read "$TMP/fakehome/$CJ.backup"              block
check "Grep glob on store"       grepglob "**/$CJ"                            block
check "Grep glob on backups"     grepglob "$CJ.*"                             block
check "Read .env"                read "$ROOT/.env"                            block
check "Read .env.local"          read "app/.env.local"                        block
check "Read .ENV upper-case"     read "$ROOT/.ENV"                            block
check "Grep path .env"           grep "$ROOT/.env"                            block
check "Grep glob .env*"          grepglob ".env*"                             block
check "Read .env.example ALLOW"  read "$ROOT/.env.example"                    allow
check "Read environment.md ALLOW" read "docs/environment.md"                  allow
check "Grep glob *.md ALLOW"     grepglob "*.md"                              allow
# Grep globs: braces expanded, last segment tried as a shell pattern
check "Grep glob {.env,x} BLOCK"      grepglob "{.env,*.md}"                  block
check "Grep glob .env{..} BLOCK"      grepglob "**/.env{.bak,.local}"         block
check "Grep glob [.]env BLOCK"        grepglob "[.]env"                       block
check "Grep glob *.local BLOCK"       grepglob "src/*.local"                  block
check "Grep glob store ? BLOCK"       grepglob "{a,b/.claude.js?n}"           block
check "Grep glob backup BLOCK"        grepglob ".CLAUDE.json.b*"              block
check "Grep glob * BLOCK (cost)"      grepglob "*"                            block
check "Grep glob .env.example ALLOW"  grepglob ".env.example"                 allow
check "Grep glob .env.sample ALLOW"   grepglob "**/.env.sample"               allow
check "Grep glob {py,md} ALLOW"       grepglob "src/**/*.{py,md}"             allow
# Grep globs split as Claude Code splits them; a negated part is refused
check "Grep glob *.md,.env BLOCK"     grepglob "*.md,.env"                    block
check "Grep glob *.md .env BLOCK"     grepglob "*.md .env"                    block
check "Grep glob *.md,store BLOCK"    grepglob "*.md,$CJ"                     block
check "Grep glob NBSP .env BLOCK"     grepglob "*.md$(printf '\302\240').env" block
check "Grep glob !*.md BLOCK"         grepglob "!*.md"                        block
check "Grep glob !README.md BLOCK"    grepglob "!README.md"                   block
check "Grep glob **/*.py ALLOW"       grepglob "**/*.py"                      allow
check "Grep glob *.md,*.txt ALLOW"    grepglob "*.md,*.txt"                   allow
check "Read .env.sample ALLOW"        read "$ROOT/.env.sample"                allow
# A Grep with no glob (or only a type filter) rooted at home or a parent of it
# reaches the credential store under ripgrep's --hidden; a project dir is fine.
check "Grep no glob at HOME BLOCK"    grep     "$HOME"                        block
check "Grep no glob at / BLOCK"       grep     "/"                            block
check "Grep type at HOME BLOCK"       greptype "$HOME"                        block
check "Grep cwd HOME no path BLOCK"   grepcwd  "$HOME"                        block
check "Grep no glob under HOME ALLOW" grep     "$HOME/some-project"           allow
check "Grep glob at HOME ALLOW"       grephome "*.md"                         allow
check "Read file at HOME ALLOW"       read     "$HOME/notes.md"               allow

echo "== BASH guard (dangerous) =="
check "git -C reset --hard"      bash "git -C /p $RST $HRD"                   block
check "push args --force"        bash "git $PSH origin main $FRC"             block
check "commit --no-verify"       bash "git commit $NV"                        block
check "rm -rf"                   bash "$RMR $RF /tmp/x"                       block
check "rm -fr (order gap)"       bash "$RMR $FRO /tmp/x"                      block
check "rm -R -f (case/spaced)"   bash "$RMR $RSEP $FSEP /tmp/x"               block
check "plain reset --hard"       bash "git $RST $HRD"                         block
check "plain push --force"       bash "git $PSH $FRC"                         block
check "sudo"                     bash "sudo tail /var/log/x"                  block
check "cat credential store"     bash "cat /tmp/x/$CJ"                        block
check "git status ALLOW"         bash "git status"                            allow
check "git commit ALLOW"         bash "git commit -m msg"                     allow
check "ls ALLOW"                 bash "ls -la"                                allow
check "push no-force ALLOW"      bash "git $PSH origin main"                  allow

echo "== BASH guard (per-segment git) =="
# Verbs are assembled from fragments so this file holds no contiguous
# whole-tree or clean literal.
CLN="cle""an"; CO="check""out"; RSR="rest""ore"
check "clean -fd BLOCK"              bash "git $CLN -fd"                            block
check "clean -f BLOCK"               bash "git $CLN -f"                             block
check "-C dir clean -xdf BLOCK"      bash "git -C /tmp/r $CLN -xdf"                 block
check "cd && clean --force BLOCK"    bash "cd /tmp/r && git $CLN $FRC"              block
check "VAR= clean -fX BLOCK"         bash "FOO=1 git $CLN -fX"                      block
check "clean --forc prefix BLOCK"    bash "git $CLN --forc -d"                      block
check "requireForce=false BLOCK"     bash "git -c $CLN.requireForce=false $CLN -d"  block
check "checkout . BLOCK"             bash "git $CO ."                               block
check "checkout -- . BLOCK"          bash "git $CO -- ."                            block
check "checkout -- quoted . BLOCK"   bash "git $CO -- '.'"                          block
check "checkout :/ BLOCK"            bash "git $CO :/"                              block
check "checkout -- quoted * BLOCK"   bash "git $CO -- '*'"                          block
check "restore . BLOCK"              bash "git $RSR ."                              block
check "restore ./ BLOCK"             bash "git $RSR ./"                             block
check "restore --worktree . BLOCK"   bash "git $RSR --worktree ."                   block
check "restore :/ BLOCK"             bash "git $RSR :/"                             block
check "staged && worktree BLOCK"     bash "git $RSR --staged . && git $RSR ."       block
check "clean -n ALLOW"               bash "git $CLN -n"                             allow
check "clean --dry-run ALLOW"        bash "git $CLN --dry-run"                      allow
check "checkout main ALLOW"          bash "git $CO main"                            allow
check "checkout -b ALLOW"            bash "git $CO -b feat/x"                       allow
check "checkout --detach ALLOW"      bash "git $CO --detach v1"                     allow
check "checkout .gitignore ALLOW"    bash "git $CO .gitignore"                      allow
check "checkout -- ./src file ALLOW" bash "git $CO -- ./src/a.py"                   allow
check "restore --staged . ALLOW"     bash "git $RSR --staged ."                     allow
check "restore -S . ALLOW"           bash "git $RSR -S ."                           allow
check "restore file ALLOW"           bash "git $RSR src/app.py"                     allow
check "restore .gitignore ALLOW"     bash "git $RSR .gitignore"                     allow
check "restore .github/ ALLOW"       bash "git $RSR .github/x.yml"                  allow
# Bypasses a review found in the first version of the per-segment rules.
BS='\'; NL='
'
check "--attr-source value BLOCK"    bash "git --attr-source HEAD $CLN -f"          block
check "--super-prefix value BLOCK"   bash "git --super-prefix x/ $CO ."             block
check "clean -fe eats -n BLOCK"      bash "git $CLN -fe -n"                         block
check "clean --no-dry-run BLOCK"     bash "git $CLN -n --no-dry-run"                block
check "clean --no-d prefix BLOCK"    bash "git $CLN -n --no-d"                      block
check "clean --exc eats -n BLOCK"    bash "git $CLN -f --exc -n"                    block
check "clean --exclude= keeps -n"    bash "git $CLN --exclude=x -n"                 allow
check "restore --work abbrev BLOCK"  bash "git $RSR --staged --work ."              block
check "restore --no-staged BLOCK"    bash "git $RSR --staged --no-staged ."         block
check "backslash-newline BLOCK"      bash "git $RSR $BS$NL."                        block
check "ANSI-C quoted . BLOCK"        bash "git $CO \$'.'"                           block
check "restore ./. BLOCK"            bash "git $RSR ./."                            block
check "restore .// BLOCK"            bash "git $RSR .//"                            block
check "checkout :(top) BLOCK"        bash "git $CO ':(top)'"                        block
check "restore :(top,icase) BLOCK"   bash "git $RSR ':(top,icase)'"                 block
check "restore pathspec-file BLOCK"  bash "git $RSR --pathspec-from-file=list.txt"  block
check "checkout pathspec-file BLOCK" bash "git $CO --pathspec-from-file list.txt"   block
# Spellings a later review walked past, now read word by word.
SW="swi""tch"; UP=".""."; RFV="-r"" -i ""-f"; FU="-u""f"; FORC="--fo""rc"; HAR="--h""ar"
CN="-""n"; NVP="--no-ver""if"; DISC="--disc""ard-changes"; PLUS="+""main"
check "rm -v -rf BLOCK"              bash "$RMR -v $RF /tmp/x"                      block
check "rm -r --force BLOCK"          bash "$RMR -r $FRC /tmp/x"                     block
check "rm -r -i -f BLOCK"            bash "$RMR $RFV /tmp/x"                        block
check "rm x -rf BLOCK"               bash "$RMR /tmp/x $RF"                         block
check "rm --recursive -f BLOCK"      bash "$RMR --recursive $FSEP /tmp/x"           block
check "xargs rm -rf BLOCK"           bash "echo x | xargs $RMR $RF"                 block
check "reset -q --hard BLOCK"        bash "git $RST -q $HRD"                        block
check "reset HEAD~1 --hard BLOCK"    bash "git $RST HEAD~1 $HRD"                    block
check "reset --har prefix BLOCK"     bash "git $RST $HAR"                           block
check "push +refspec BLOCK"          bash "git $PSH origin $PLUS"                   block
check "push -uf BLOCK"               bash "git $PSH $FU origin main"                block
check "push --forc prefix BLOCK"     bash "git $PSH $FORC"                          block
check "commit -n BLOCK"              bash "git commit $CN -m x"                     block
check "commit -an BLOCK"             bash "git commit -a""n -m x"                   block
check "commit --no-verif BLOCK"      bash "git commit $NVP -m x"                    block
check "checkout -f HEAD BLOCK"       bash "git $CO $FSEP HEAD"                      block
check "checkout --force BLOCK"       bash "git $CO $FRC main"                       block
check "switch --discard-changes BLOCK" bash "git $SW $DISC main"                    block
check "switch --disc prefix BLOCK"   bash "git $SW --di""sc main"                   block
check "switch -f BLOCK"              bash "git $SW $FSEP main"                      block
check "checkout -- src/.. BLOCK"     bash "git $CO -- src/$UP"                      block
check "restore ./x/.. BLOCK"         bash "git $RSR ./x/$UP"                        block
check "push ALLOW"                   bash "git $PSH"                                allow
check "push --force-with-lease ALLOW" bash "git $PSH $FRC-with-lease origin feat"   allow
check "push -u ALLOW"                bash "git $PSH -u origin feat"                 allow
check "commit -m x ALLOW"            bash "git commit -m x"                         allow
check "commit -am x ALLOW"           bash "git commit -am x"                        allow
check "commit -mnote ALLOW"          bash "git commit -mnote"                       allow
check "checkout -b x ALLOW"          bash "git $CO -b x"                            allow
check "checkout -bfix ALLOW"         bash "git $CO -bfix"                           allow
check "switch -c feat ALLOW"         bash "git $SW -c feat"                         allow
check "switch main ALLOW"            bash "git $SW main"                            allow
check "checkout src/../src/a ALLOW"  bash "git $CO -- src/$UP/src/a.py"             allow
check "rm file.txt ALLOW"            bash "$RMR file.txt"                           allow
check "rm -r dir ALLOW"              bash "$RMR -r dir"                             allow
check "rm -f file ALLOW"             bash "$RMR $FSEP file.txt"                     allow
check "reset --soft HEAD~1 ALLOW"    bash "git $RST --soft HEAD~1"                  allow
# Last hardening round.
# 1. u and S end a commit cluster without taking the next word.
check "commit -u -n BLOCK"           bash "git commit -u $CN -m x"                  block
check "commit -S -n BLOCK"           bash "git commit -S $CN -m x"                  block
check "commit -u --no-verify BLOCK"  bash "git commit -u $NV -m x"                  block
check "commit -uno ALLOW"            bash "git commit -uno -m x"                    allow
# 2. checkout/switch --force from --f, --discard-changes from --di.
check "checkout --f prefix BLOCK"    bash "git $CO --f main"                        block
check "switch --di prefix BLOCK"     bash "git $SW --di main"                       block
# 3. exclude magic and glob-only pathspecs are whole-tree.
check "restore :!x BLOCK"            bash "git $RSR ':!x'"                          block
check "checkout :^x BLOCK"           bash "git $CO -- ':^docs'"                     block
check "restore :/!x BLOCK"           bash "git $RSR ':/!x'"                         block
check "restore :(exclude)x BLOCK"    bash "git $RSR ':(exclude)x'"                  block
check "checkout :(top,exclude) BLOCK" bash "git $CO -- ':(top,exclude)a.py'"        block
check "restore ** BLOCK"             bash "git $RSR '**'"                           block
check "checkout ?* BLOCK"            bash "git $CO -- '?*'"                         block
check "restore ./** BLOCK"           bash "git $RSR './**'"                         block
check "restore --staged :!x ALLOW"   bash "git $RSR --staged ':!x'"                 allow
check "restore *.py ALLOW"           bash "git $RSR '*.py'"                         allow
check "checkout -- src/*.py ALLOW"   bash "git $CO -- 'src/*.py'"                   allow
# 4. -c core.hooksPath on commit and push.
HKP="core.hoo""ksPath"
check "-c hooksPath commit BLOCK"    bash "git -c $HKP=/dev/null commit -m x"       block
check "-c HOOKSPATH push BLOCK"      bash "git -c CORE.HOOKSPATH=x $PSH"            block
check "--config-env hooksPath BLOCK" bash "git --config-env=$HKP=HP commit -m x"    block
check "-c user.name commit ALLOW"    bash "git -c user.name=x commit -m y"          allow
check "-c hooksPath status ALLOW"    bash "git -c $HKP=x status"                    allow
# 5. the value of -m/-F is not read as flags; --no-ver is not --no-verify.
check "commit -m quoted -n ALLOW"    bash "git commit -m \"fix $CN handling\""      allow
check "commit -m single -n ALLOW"    bash "git commit -m 'drop $CN and -S'"         allow
check "commit -m\"..-n\" ALLOW"      bash "git commit -m\"x $CN\""                  allow
check "commit -m -n unquoted ALLOW"  bash "git commit -m $CN"                       allow
check "commit -F -n file ALLOW"      bash "git commit -F $CN"                       allow
check "commit --message value ALLOW" bash "git commit --message 'a $CN b'"          allow
check "commit -am quoted -n ALLOW"   bash "git commit -am \"a $CN b\""             allow
check "commit --no-verbose ALLOW"    bash "git commit --no-verbose -m x"            allow
check "commit -m x -n BLOCK"         bash "git commit -m x $CN"                     block
check "commit -m 'x' -n BLOCK"       bash "git commit -m 'a b' $CN"                 block
check "bash -c commit -m x -n BLOCK" bash "bash -c 'git commit -m x $CN'"           block
check "commit --no-veri BLOCK"       bash "git commit --no-veri -m x"               block
# Everyday commands stay allowed.
check "commit -m quoted ALLOW"       bash "git commit -m \"feat: add the parser\""  allow
check "push --force-with-lease ALLOW" bash "git $PSH $FRC-with-lease"               allow
check "checkout main (again) ALLOW"  bash "git $CO main"                            allow
check "log -n 5 ALLOW"               bash "git log -n 5"                            allow
check "diff ALLOW"                   bash "git diff"                                allow
check "grep -rn ALLOW"               bash "grep -rn x ."                            allow
check "npm test ALLOW"               bash "npm test"                                allow
check "commit -F msg file ALLOW"     bash "git commit -F /tmp/msg.txt"              allow
check "-C commit --no-gpg-sign ALLOW" bash "git -C /tmp/r commit -q --no-gpg-sign -m x" allow
check "add a hook file ALLOW"        bash "git add hooks/skip-ci-guard.sh"          allow
check "gh pr merge ALLOW"            bash "gh pr merge 7 --squash"                  allow
check "push --delete ALLOW"          bash "git $PSH origin --delete feat/x"         allow
check "pull --ff-only ALLOW"         bash "git pull --ff-only"                      allow
check "python3 -m pytest ALLOW"      bash "python3 -m pytest -q"                    allow
check "restore '?*' BLOCK"           bash "git $RSR '?*'"                           block
check "checkout -- ':!README' BLOCK" bash "git $CO -- ':!README.md'"                block

echo "== BASH guard (heredocs, commit values, reset --help) =="
# A quoted heredoc body is data only when it feeds a sink (git commit/tag -F -,
# or a bare cat in a quoted $(...) argument of git commit, git tag or gh); the
# value of commit -m/-F is data up to its own end; git reset --help is allowed.
RMRF="$RMR $RF /tmp/x"; HEL="--h""el"
check "bash <<'X' rm body BLOCK"     bash "bash <<'X'${NL}$RMRF${NL}X"              block
check "cat <<X \$(rm) body BLOCK"    bash "cat <<X${NL}\$($RMRF)${NL}X"             block
check "python3 os.system rm BLOCK"   bash "python3 - <<'X'${NL}import os; os.system('$RMRF')${NL}X" block
check "cat <<'X' && rm marker BLOCK" bash "cat <<'X' && $RMRF${NL}body${NL}X"       block
check "cat <<'X' | bash BLOCK"       bash "cat <<'X' | bash${NL}$RMRF${NL}X"        block
check "rm after terminator BLOCK"    bash "git commit -F - <<'MSG'${NL}note${NL}MSG${NL}$RMRF" block
check "reset --hel BLOCK"            bash "git $RST $HEL"                           block
check "commit -m then rm BLOCK"      bash "git commit -m \"x\" && $RMRF"            block
check "commit -m \$(rm) BLOCK"       bash "git commit -m \"\$($RMRF)\""             block
check "commit -m backtick rm BLOCK"  bash "git commit -m \"\`$RMRF\`\""             block
check "commit heredoc tidy ALLOW"    bash "git commit -q -F - <<'MSG'${NL}fix: tidy${NL}${NL}- $RMR stale dirs, not -r -f${NL}- say why git $PSH $FRC is risky${NL}MSG" allow
check "commit heredoc docs ALLOW"    bash "git commit -q -F - <<'MSG'${NL}docs: explain why git $CO . and git $CLN -fd are refused${NL}MSG" allow
check "commit -m -n in text ALLOW"   bash "git commit -m \"document the $CN flag of grep\"" allow
check "commit -m push text ALLOW"    bash "git commit -m \"say why git $PSH $FRC is risky\"" allow
check "commit -m \$(cat heredoc) ALLOW" bash "git commit -m \"\$(cat <<'EOF'${NL}why git $PSH $FRC is risky${NL}EOF${NL})\"" allow
# The sink allowlist: every other reader of a quoted body gets it scanned, and
# a <<, a quote or a value inside a comment or arithmetic opens nothing.
check "<< inside a comment BLOCK"    bash "true # <<'X'${NL}$RMRF${NL}X"              block
check "<< in arithmetic BLOCK"       bash "echo \$(( 1 << \"2\" ))${NL}$RMRF"         block
check "marker line ends in | BLOCK"  bash "cat <<'X' |${NL}$RMRF${NL}X${NL}sh"        block
check "unquoted \$(cat <<) BLOCK"    bash "\$(cat <<'X'${NL}$RMRF${NL}X${NL})"        block
check "backtick cat << BLOCK"        bash "\`cat <<'X'${NL}$RMRF${NL}X${NL}\`"        block
check "cat <<'X' | \$SHELL BLOCK"    bash "cat <<'X' | \$SHELL${NL}$RMRF${NL}X"       block
check "function reads body BLOCK"    bash "f() { sh; }${NL}f <<'X'${NL}$RMRF${NL}X"   block
check "cat <<'X' | tcsh BLOCK"       bash "cat <<'X' | tcsh${NL}$RMRF${NL}X"          block
check "gawk system() body BLOCK"     bash "gawk -f /dev/stdin <<'X'${NL}BEGIN{system(\"$RMRF\")}${NL}X" block
check "nodejs execSync body BLOCK"   bash "nodejs <<'X'${NL}require('child_process').execSync('$RMRF')${NL}X" block
check "commit -m #' comment BLOCK"   bash "git commit -m #'${NL}$RMRF${NL}'"          block
check "bash<<<'rm' no space BLOCK"   bash "bash<<<'$RMRF'"                            block
check "cat <<'X' > file BLOCK"       bash "cat <<'X' > /tmp/s.sh && bash /tmp/s.sh${NL}$RMRF${NL}X" block
check "bash -c \"\$(cat <<)\" BLOCK" bash "bash -c \"\$(cat <<'X'${NL}$RMRF${NL}X${NL})\"" block
check "git() then commit -F - BLOCK" bash "git() { sh; }${NL}git commit -F - <<'X'${NL}$RMRF${NL}X" block
check "commit -F - <<'X' | BLOCK"    bash "git commit -F - <<'X' |${NL}$RMRF${NL}X${NL}sh" block
check "gh --body \$(cat) ALLOW"      bash "gh pr create --title t --body \"\$(cat <<'EOF'${NL}why git $PSH $FRC is risky${NL}EOF${NL})\"" allow
check "commit -m \$(cat) tidy ALLOW" bash "git commit -m \"\$(cat <<'EOF'${NL}fix: tidy${NL}${NL}- $RMR stale dirs, not -r -f${NL}EOF${NL})\"" allow
check "tag -F - heredoc ALLOW"       bash "git tag -a v1 -F - <<'M'${NL}why git $PSH $FRC is risky${NL}M" allow
check "reset --help ALLOW"           bash "git $RST --help"                         allow

echo "== BASH guard (audit r3: heredoc, editor, rebind, ANSI-C, brace) =="
# N1: a " in a cat-sink body must not close the outer word early and let a
# later -m ' swallow the real code after the terminator.
check "N1 heredoc quote bypass BLOCK" bash "git commit -m \"\$(cat <<'EOF'${NL}x\" -m '${NL}EOF${NL})\" ; $RMRF ; echo done" block
# N2: a ) or a nested \$( in a cat-sink body makes it code, not data (bash 3.2
# closes the substitution at the ), and bash 5 runs the nested one).
check "N2 cat-sink ) body BLOCK"      bash "git commit -m \"\$(cat <<'EOF'${NL}) \$($RMRF)${NL}EOF${NL})\"" block
check "N2 gh body ) subst BLOCK"      bash "gh pr create --title t --body \"\$(cat <<'EOF'${NL}) \$($RMRF)${NL}EOF${NL})\"" block
check "N2 balanced-quote body ALLOW"  bash "git commit -m \"\$(cat <<'EOF'${NL}say \"hi\" to the team${NL}EOF${NL})\"" allow
# N3: an editor context runs the message, so the body/value is scanned, not data.
check "N3 GIT_EDITOR -e -F - BLOCK"   bash "GIT_EDITOR=sh git commit -e -F - <<'X'${NL}$RMRF${NL}X" block
check "N3 GIT_EDITOR -e -m BLOCK"     bash "GIT_EDITOR=sh git commit -e -m '$RMRF'"    block
check "N3 -e -F - no env BLOCK"       bash "git commit -e -F - <<'X'${NL}$RMRF${NL}X"  block
check "N3 core.editor -F - BLOCK"     bash "git -c core.editor=sh commit -e -F - <<'X'${NL}$RMRF${NL}X" block
check "N3 plain -F - heredoc ALLOW"   bash "git commit -q -F - <<'MSG'${NL}fix: tidy the docs${NL}MSG" allow
# N4: rebinding cat (hash -p) or a PATH= prefix means the cat-sink body is code.
check "N4 hash -p rebinds cat BLOCK"  bash "hash -p /bin/sh cat; git commit -m \"\$(cat <<'EOF'${NL}$RMRF${NL}EOF${NL})\"" block
check "N4 PATH= prefix cat BLOCK"     bash "PATH=/tmp git commit -m \"\$(cat <<'EOF'${NL}$RMRF${NL}EOF${NL})\"" block
# N5: ANSI-C quoting and brace expansion hide rm or its flags.
check "N5 ANSI-C hex rm arg BLOCK"    bash "$RMR \$'\\x2d'rf /tmp/x"                  block
check "N5 ANSI-C octal rm arg BLOCK"  bash "$RMR \$'\\055rf' /tmp/x"                  block
check "N5 ANSI-C rm command BLOCK"    bash "\$'\\x72m' -rf /tmp/x"                    block
check "N5 brace-expansion rm BLOCK"   bash "{$RMR,$RF,/tmp/x}"                        block
check "N5 brace abs-path rm BLOCK"    bash "{/bin/$RMR,$RF,/tmp/x}"                   block
check "N5 ANSI-C no escape ALLOW"     bash "echo \$'hello there'"                     allow
check "N5 brace in arg position ALLOW" bash "echo {a,b}.txt"                          allow
check "N5 brace group ALLOW"          bash "{ echo hi; }"                            allow
# Hotfix after N5 round 3: the ANSI-C and brace refusals read shell code only
# (top level, substitutions, bodies and here-strings a shell reads), not data,
# the bodies of other interpreters, or the -c/-e strings of python or node.
check "HF json in cat heredoc ALLOW"  bash "cat > /tmp/a.json <<'EOF'${NL}{\"a\":1,\"b\":2}${NL}EOF" allow
check "HF python regex body ALLOW"    bash "python3 - <<'PY'${NL}import re${NL}print(re.findall(r\"\\d{1,3}\", \"a12\"))${NL}PY" allow
check "HF python f-string body ALLOW" bash "python3 - <<'PY'${NL}x, y = 1, 2${NL}print(f\"{x},{y}\")${NL}PY" allow
check "HF python {1,3} body ALLOW"    bash "python3 - <<'PY'${NL}{1,3}${NL}PY"        allow
check "HF python3 -c regex ALLOW"     bash "python3 -c 'import re; print(re.findall(r\"\\d{1,3}\", \"a\"))'" allow
check "HF node -e object ALLOW"       bash "node -e 'console.log([1,2].map(x => ({a:x,b:x})))'" allow
check "HF printf ANSI-C tab ALLOW"    bash "printf \$'a\\tb\\n'"                      allow
check "HF mkdir {a,b} ALLOW"          bash "mkdir -p /tmp/src/{a,b}"                  allow
check "HF brace in bash body BLOCK"   bash "bash <<'X'${NL}{$RMR,$RF,/tmp/x}${NL}X"   block
check "HF ANSI-C rm top level BLOCK"  bash "\$'\\x72m' $RF /tmp/x"                    block
check "HF brace in env sh body BLOCK" bash "env -i sh <<'X'${NL}{$RMR,$RF,/tmp/x}${NL}X" block
check "HF brace bash here-str BLOCK"  bash "bash <<< '{$RMR,$RF,/tmp/x}'"             block
check "HF brace in \"\$(...)\" BLOCK" bash "echo \"\$({$RMR,$RF,/tmp/x})\""          block
check "HF brace in sh -c BLOCK"       bash "sh -c 'true; {$RMR,$RF,/tmp/x}'"          block
check "HF python os.system rm BLOCK"  bash "python3 -c 'import os; os.system(\"$RMR $RF /tmp/x\")'" block

echo "== skip-ci guard =="
check "skip-ci + code BLOCK"     bash "git -C $REPO_PY commit -m \"x [skip ci]\""    block
check "skip-ci docs ALLOW"       bash "git -C $REPO_MD commit -m \"docs [skip ci]\"" allow
check "skip-ci staged .sh BLOCK"   skipci "git -C $REPO_SH commit -m \"x [skip ci]\""                block
check "skip-ci cd && commit BLOCK" skipci "cd $REPO_PY && git commit -m \"x [skip ci]\""            block
check "skip-ci add -A BLOCK"       skipci "cd $REPO_CM && git add -A && git commit -m 'x [skip ci]'" block
check "skip-ci commit -am BLOCK"   skipci "git -C $REPO_CM commit -am \"x [skip ci]\""               block
check "skip-ci -am docs ALLOW"     skipci "cd $REPO_DOC && git commit -am \"docs [skip ci]\""        allow
check "skip-ci git fails ALLOW"    skipci "git -C $TMP/no-such-repo commit -m \"x [skip ci]\""       allow
# every marker CI services honour, and the ci.skip push option
check "[ci skip] + code BLOCK"     skipci "git -C $REPO_PY commit -m \"x [ci skip]\""                block
check "[no ci] + code BLOCK"       skipci "git -C $REPO_PY commit -m \"x [NO CI]\""                  block
check "[skip actions] BLOCK"       skipci "git -C $REPO_PY commit -m \"x [skip actions]\""           block
check "[actions skip] BLOCK"       skipci "git -C $REPO_PY commit -m \"x [actions skip]\""           block
check "***NO_CI*** BLOCK"          skipci "git -C $REPO_PY commit -m \"x ***NO_CI***\""              block
check "skip-checks trailer BLOCK"  skipci "git -C $REPO_PY commit -m x -m \"skip-checks: true\""     block
check "[no ci] docs ALLOW"         skipci "git -C $REPO_MD commit -m \"docs [no ci]\""               allow
check "plain commit code ALLOW"    skipci "git -C $REPO_PY commit -m \"feat: skip nothing\""         allow
check "push -o ci.skip BLOCK"      skipci "git $PSH -o ci.skip origin feat"                         block
check "push --push-option BLOCK"   skipci "git $PSH --push-option=ci.skip"                          block
check "push -o other ALLOW"        skipci "git $PSH -o merge_request.create origin feat"            allow
check "plain push ALLOW"           skipci "git $PSH origin feat"                                    allow
# --amend counts the files HEAD already touches
check "amend over code BLOCK"      skipci "git -C $REPO_AM commit --amend -m \"x [skip ci]\""        block
check "no amend docs ALLOW"        skipci "git -C $REPO_AM commit -m \"docs [skip ci]\""             allow

echo "== pasted-key guard =="
# fake keys assembled from fragments so this file holds no contiguous key
SK="sk-""ant-""api03-""AbCdEf0123456789AbCdEf0123456789"
GHPAT="github_""pat_""11ABCDEFG0123456789_abcdefghijklmnopqrstuvwxyz012345"
GHP="gh""p_""abcdefghijklmnopqrstuvwxyz0123"
AWSK="AK""IA""QWERTYUIOPASDFGH"
PEM="-----BEGIN ""RSA PRIVATE ""KEY-----"
check "key sk-ant BLOCK"         prompt "my key $SK ok"                       block
check "key github_pat BLOCK"     prompt "token $GHPAT"                        block
check "key ghp_ BLOCK"           prompt "use $GHP please"                     block
check "key AKIA BLOCK"           prompt "aws $AWSK end"                       block
check "PEM header BLOCK"         prompt "$PEM${NL}MIIEow"                     block
check "plain prompt ALLOW"       prompt "please refactor the parser"          allow
check "masked key ALLOW"         prompt "the format is sk-ant-XXXX"           allow
PGP="-----BEGIN ""PGP PRIVATE ""KEY BLOCK-----"
SKP="sk-""proj-""Ab12Cd34Ef56Gh78Ij90Kl12"
GOOG="AI""za""SyA1b2C3d4E5f6G7h8I9j0K1l2M3n4O5p6q"
GLP="gl""pat-""xY12zW34vU56tS78rQ90"
ASIAK="AS""IA""ZXCVBNMASDFGHJKL"
HFT="hf""_""aBcDeFgHiJkLmNoPqRsTuVwXyZ012345"
MSKP="sk-""proj-""XXXXXXXXXXXXXXXXXXXXXXXX"
MAWS="AK""IA""XXXXXXXXXXXXXXXX"
check "PGP header BLOCK"         prompt "$PGP${NL}lQOYBF"                     block
check "key sk-proj BLOCK"        prompt "openai $SKP end"                     block
check "key AIza BLOCK"           prompt "google $GOOG end"                    block
check "key glpat BLOCK"          prompt "gitlab $GLP end"                     block
check "key ASIA BLOCK"           prompt "aws $ASIAK end"                      block
check "key hf_ BLOCK"            prompt "hf $HFT end"                         block
check "masked sk-proj ALLOW"     prompt "the format is $MSKP"                 allow
check "masked AKIA ALLOW"        prompt "the format is $MAWS"                 allow
check "masked then real BLOCK"   prompt "like $MSKP, mine is $SKP"            block
SVC="sk-""svcacct-""Zy98Xw76Vu54Ts32Rq10Po98"
ADM="sk-""admin-""Mn12Op34Qr56St78Uv90Wx12"
LEG="sk-""Ab12Cd34Ef56Gh78Ij90""T3Blbk""FJ""Kl12Mn34Op56Qr78St90"
STR="sk""_live_""51Hq8mA2bC3dE4fG5hI6jK7lM8"
RKS="rk""_live_""51Hq8mA2bC3dE4fG5hI6jK7lM8"
AWSDOC="AK""IA""IOSFODNN7""EXAMPLE"
check "key sk-svcacct BLOCK"     prompt "svc $SVC end"                        block
check "key sk-admin BLOCK"       prompt "admin $ADM end"                      block
check "legacy sk- T3Blbk BLOCK"  prompt "old $LEG end"                        block
check "Stripe sk_live BLOCK"     prompt "stripe $STR end"                     block
check "Stripe rk_live BLOCK"     prompt "stripe $RKS end"                     block
check "AWS doc EXAMPLE ALLOW"    prompt "the docs use $AWSDOC as a sample"    allow
check "EXAMPLE then real BLOCK"  prompt "like $AWSDOC, mine is $AWSK"         block
check "api key in prose ALLOW"   prompt "where do I put the api key for the service?" allow
check_nojq "key guard new shape blocks" prompt "stripe $STR end"             block

echo "== without jq on PATH =="
check_nojq "bash guards fail closed"   bash   "ls -la"                        block
check_nojq "file guard fails closed"   file   "docs/a.md"                     block
check_nojq "read guard fails closed"   read   "$ROOT/README.md"               block
check_nojq "key guard still blocks"    prompt "my key $SK ok"                 block
check_nojq "key guard still allows"    prompt "hello"                         allow

echo "== with a failing jq on PATH =="
check_badjq "bash guards fail closed"    bash   "ls -la"                      block
check_badjq "skip-ci guard fails closed" skipci "ls -la"                      block
check_badjq "file guard fails closed"    file   "docs/a.md"                   block
check_badjq "read guard fails closed"    read   "$ROOT/README.md"             block

echo "------------------------------------------------------------"
echo "RESULT: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
