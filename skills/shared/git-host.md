---
name: git-host
description: Foundation reference for dual-host git tooling (GitHub via gh + Forgejo via tea/curl). Host detection, CI-status parsing, merge-strategy translation, setup gate. Loaded by reference from git-finalize, git-worktree-status and review — not invoked directly.
disable-model-invocation: true
---

# git-host — dual-host detection & CI foundation

Single source of truth for **host detection** and **CI-status parsing** across the
dual-host finalize suite. Consumers (`git-finalize`, `git-worktree-status`,
`review`) **link to this file and run the snippets verbatim** — they do **not**
re-implement detection or CI parsing. One producer, several consumers: if a
consumer reinterprets `error` vs `failure` or collapses `no-checks` into
`success`, the suite diverges and goes false-green. Don't.

Two backends:
- **GitHub** (the default) → `gh` CLI, over ssh or https, with one or more accounts.
- **Forgejo** (`<your-forgejo-host>`, a self-hosted instance you name yourself) →
  hybrid: `tea` for verbs (PR create/list/merge), `curl /api/v1` for CI status
  (`tea` has no `checks` command).

Replace `<your-forgejo-host>` below with your Forgejo hostname (for example
`git.example.org`). If you only use GitHub, leave the placeholder as it is: it never
matches a real host, and every Forgejo path simply stays unused.

---

## 1. Output contract (producer → consumer interface)

The detection block prints to **stdout**, one `key=value` per line, no spaces
around `=`:

```
backend=gh|forgejo|unknown
host=<real hostname>
owner=<owner>
repo=<repo>
remote=<remote name used>
```

For Forgejo hosts behind an auth proxy it additionally prints:

```
requires_proxy_auth=yes
```

- **Data → stdout** as `key=value` (parseable). **Diagnostics, setup instructions,
  and `reason=` → stderr** — so they never pollute `backend=` parsing.
- On failure to classify, **still print `backend=unknown` to stdout** and a
  `reason=<why>` line to **stderr**. `reason ∈ {unreachable, not-forgejo, no-remote,
  unparseable-url, http <code>}`.
- The block is **idempotent and pure** — a function of `--remote`/current branch,
  no global cache, no state files. `git-worktree-status` calls it per-branch in a
  loop, so repeated calls must not interfere.

**Consumer behaviour on `backend=unknown`:**

| Consumer            | On `unknown` |
|---------------------|--------------|
| `git-finalize`      | **STOP** — print `reason`, do nothing else. |
| `review`            | **fall through** — print `reason`, try the next spec source. |
| `git-worktree-status` | **degrade** — still show the branch row, CI column = `n/a`. |

`unreachable` is surfaced as `backend=unknown` + `reason=unreachable` with a
distinct stderr message ("Forgejo is unreachable — check your network/VPN"), so the
user can tell "no Forgejo here" from "Forgejo here but I can't reach it".

---

## 2. Remote resolution (single rule, no alternatives)

1. If an explicit remote was passed, use it. Otherwise resolve from the branch's
   upstream; a branch with **no upstream** (`git rev-parse` exits 128 — normal for a
   fresh feature branch) falls back to `origin`:

   ```bash
   if [ -n "$EXPLICIT_REMOTE" ]; then
     remote="$EXPLICIT_REMOTE"
   else
     up=$(git rev-parse --abbrev-ref '@{u}' 2>/dev/null)
     if [ -z "$up" ]; then remote=origin; else remote="${up%%/*}"; fi
   fi
   ```

2. Get the URL with `--all` (plain `get-url` does **not** apply `insteadOf`
   rewrites; we need the rewritten URL):

   ```bash
   url=$(git remote get-url --all "$remote" 2>/dev/null | head -1)
   [ -z "$url" ] && { echo "backend=unknown"; echo "reason=no-remote ($remote)" >&2; exit 0; }
   ```

3. Parse `host` / `owner` / `repo` from ssh or https form, strip `.git`:

   ```bash
   # ⚠️ The variable is called rpath, NOT path: in zsh `path` is an array
   # tied to $PATH, and assigning `path=...` wipes PATH entirely.
   # After that git, awk and sed "disappear", and the skill answers
   # "nothing to clean" on empty output instead of an error.
   case "$url" in
     git@*)            rest=${url#git@};      host=${rest%%:*}; rpath=${rest#*:} ;;
     ssh://*)          rest=${url#ssh://}; rest=${rest#*@}; host=${rest%%/*}; rpath=${rest#*/} ;;
     https://*|http://*) rest=${url#*://};  rest=${rest#*@}; host=${rest%%/*}; rpath=${rest#*/} ;;
     *) echo "backend=unknown"; echo "reason=unparseable-url ($url)" >&2; exit 0 ;;
   esac
   rpath=${rpath%.git}
   owner=${rpath%%/*}
   rest=${rpath#*/}; repo=${rest%%/*}
   ```

4. **Resolve ssh host aliases** via `ssh -G` (pure local config lookup, no network).
   Without this, a remote such as `git@github-work:<owner>/<repo>.git` keeps
   `host=github-work` and a multi-account setup misclassifies. `ssh -G` echoes the
   input for non-aliases, so it is safe to always run:

   ```bash
   real=$(ssh -G "$host" 2>/dev/null | awk '/^hostname /{print $2; exit}')
   [ -n "$real" ] && host="$real"
   ```

   Example: an `~/.ssh/config` entry `Host github-work` with `HostName github.com`
   resolves `github-work` → `github.com` (a second GitHub account).

---

## 3. Backend classification (proxy-auth resistant)

Order matters — allowlist before any network probe:

```bash
requires_proxy_auth=
case "$host" in
  github.com)
    backend=gh ;;
  '<your-forgejo-host>')                 # known-instances allowlist — deterministic, no network; replace with your hostname
    backend=forgejo ;;                   # append `requires_proxy_auth=yes` if a Basic-auth reverse proxy fronts it (§6)
  *)
    code=$(curl -s -o /dev/null -w '%{http_code}' -m 8 "https://$host/api/v1/version" 2>/dev/null)
    crc=$?
    if [ "$code" = "000" ] || [ $crc -eq 28 ] || [ $crc -eq 56 ] || [ $crc -eq 7 ]; then
      backend=unknown; reason=unreachable
    elif printf '%s' "$code" | grep -qE '^2'; then
      backend=forgejo
    elif [ "$code" = "401" ] || [ "$code" = "403" ]; then
      backend=forgejo                     # API exists but gated by auth — still Forgejo
    else
      backend=unknown; reason="http $code"
    fi ;;
esac
```

- A Forgejo instance behind an auth proxy must **not** be classified by an
  anonymous JSON probe: such a proxy answers anonymous `/api/v1` calls with a
  **`401` HTML** page (`www-authenticate: Basic …`) from the proxy, not with
  Forgejo JSON. Hence the allowlist.
- For non-allowlisted hosts the probe is best-effort: `2xx` **or** `401/403` →
  `forgejo`; network failure (`000`/curl 7/28/56) → `unknown` + `reason=unreachable`
  (VPN message, **not** plain unknown); `404`/other → `unknown`.

To extend the allowlist, add a `case` arm with the host and (if proxied)
`requires_proxy_auth=yes`.

---

## 4. CI-status parse (source of truth for both consumers)

Combined CI state collapses to **exactly one** of:
`success | pending | failure | error | no-checks | unreachable`.

`no-checks` and `unreachable` are **distinct outcomes** and **never** fold into
`success` — that is the primary false-green trap. An empty check set means "CI is
not configured", not "CI passed".

### GitHub

```bash
gh_ci_state() {            # $1 = PR number
  local j
  j=$(gh pr view "$1" --json statusCheckRollup -q '.statusCheckRollup' 2>/dev/null) \
     || { echo unreachable; return; }
  if [ -z "$j" ] || [ "$j" = "null" ] || [ "$j" = "[]" ]; then echo no-checks; return; fi
  printf '%s' "$j" | jq -r '
    # WARNING: for a running check GitHub returns conclusion="" (an EMPTY STRING, not null),
    # and the jq operator // skips only null and false. So the naive
    # (.conclusion // .state // .status) returned "" → none of the patterns below
    # matched → else "success". A running check read as a successful one — exactly the
    # false green the §4 header warns about.
    # Observed on a real PR: {"status":"IN_PROGRESS",
    # "conclusion":"","state":null} gave success instead of pending.
    [ .[] | (if (.conclusion // "") != "" then .conclusion
             elif (.state // "") != "" then .state
             else (.status // "") end) ] as $s
    | if   ($s | length) == 0 or all($s[]; . == "") then "no-checks"
      elif any($s[]; . == "FAILURE" or . == "FAILED" or . == "TIMED_OUT"
                  or . == "CANCELLED" or . == "ACTION_REQUIRED"
                  or . == "STARTUP_FAILURE") then "failure"
      elif any($s[]; . == "ERROR") then "error"
      elif any($s[]; . == "PENDING" or . == "QUEUED" or . == "IN_PROGRESS"
                  or . == "EXPECTED" or . == "WAITING") then "pending"
      else "success" end'
}
```

Empty / `null` rollup → **`no-checks`** (not success).

### Forgejo

Needs the **PR head SHA** as `ref` — get it from the API / `tea pulls`, **not** from
local `git rev-parse HEAD` (that is a fallback only; local HEAD may differ from the
PR head after a remote rebase).

```bash
forgejo_ci_state() {       # $1=host $2=owner $3=repo $4=headSHA
  [ -n "$FORGEJO_TOKEN" ] || { echo unreachable; return; }     # caller prints PAT hint
  local args=(-s -m 10 -H "Authorization: token $FORGEJO_TOKEN")
  [ -n "$FORGEJO_PROXY_AUTH" ] && args+=(-u "$FORGEJO_PROXY_AUTH")   # optional reverse-proxy Basic auth (see §6)
  local out code body
  out=$(curl "${args[@]}" -w $'\n%{http_code}' \
        "https://$1/api/v1/repos/$2/$3/commits/$4/status")
  code=${out##*$'\n'}; body=${out%$'\n'*}
  case "$code" in
    2*) : ;;
    401|403) echo unreachable; return ;;     # missing/expired PAT *or* proxy cred
    404)     echo no-checks;   return ;;     # ref/repo not visible to CI view
    *)       echo unreachable; return ;;
  esac
  local n state
  n=$(printf '%s' "$body" | jq -r '.statuses | length')
  state=$(printf '%s' "$body" | jq -r '.state // empty')
  if [ -z "$n" ] || [ "$n" = "0" ]; then echo no-checks; return; fi   # empty statuses[] → no-checks even if state=success
  case "$state" in
    success) echo success ;;
    pending) echo pending ;;
    failure) echo failure ;;
    error)   echo error ;;
    *)       echo no-checks ;;
  esac
}
```

Key invariant: **empty `statuses[]` → `no-checks` even when `state` reads
`success`** (self-hosted Forgejo with no CI returns exactly this). A `401/403` here
means a credential is missing — the Forgejo PAT or, behind a proxy, the proxy
credential; the message must mention both (see §6).

---

## 5. Merge-strategy translation (intent → backend flag)

Used by `git-finalize` only, at the STOP-before-merge step, when printing the
ready-to-merge command. The merge itself is the user's: ask before merging a pull
request.

| Intent                | gh           | tea `--style`  | API field `Do` |
|-----------------------|--------------|----------------|----------------|
| merge commit          | `--merge`    | `merge`        | `merge`        |
| squash                | `--squash`   | `squash`       | `squash`       |
| rebase (fast-forward) | `--rebase`   | `rebase`       | `rebase`       |
| rebase + merge commit | *(n/a)*      | `rebase-merge` | `rebase-merge` |

gh has no direct equivalent of `rebase-merge`; on GitHub use `--rebase` or
`--merge`.

---

## 6. Credential layer (optional reverse proxy)

Every Forgejo `/api/v1` call needs the Forgejo token:

- `FORGEJO_TOKEN` — the Forgejo PAT, sent as `Authorization: token $FORGEJO_TOKEN`.
  Generate it at `https://<your-forgejo-host>/user/settings/applications`. Source:
  an **env var**; export it before any CI check. Never paste it into a file you
  commit.

Some self-hosted instances sit behind a reverse proxy (nginx, Caddy, Traefik) that
adds its own HTTP Basic auth in front of Forgejo. This is optional; only if your
host has one, mark it with `requires_proxy_auth=yes` in the §3 allowlist and supply
a second credential:

- `FORGEJO_PROXY_AUTH` — the proxy's Basic credential in `<user>:<password>` form,
  sent as `curl -u "$FORGEJO_PROXY_AUTH"`. Applied automatically by the snippets
  when set; **required** for `requires_proxy_auth=yes` hosts.

The same Basic layer then also fronts `tea` and git over https. For `tea`, embed
the proxy credential in the login URL:
`tea logins add --name <slug> --url https://<user>:<password>@<your-forgejo-host> --token <PAT>`.
For git clone/push over https, the proxy credential must be in the URL or a
credential helper. ssh remotes bypass an https proxy.

---

## 7. Setup gate (print to stderr, never traceback)

Check before attempting Forgejo verbs / CI; print the actionable hint, do not crash:

```bash
# tea missing
command -v tea >/dev/null 2>&1 || \
  echo "Forgejo: install tea — 'brew install tea' (or see the Forgejo docs)" >&2

# tea present but no login for host
if command -v tea >/dev/null 2>&1 && ! tea logins list 2>/dev/null | grep -q "$host"; then
  echo "Forgejo: no login for $host — 'tea logins add --name <slug> --url https://[user:pass@]$host --token <PAT>'" >&2
fi

# PAT missing before a curl CI check
[ -n "$FORGEJO_TOKEN" ] || \
  echo "Forgejo: \$FORGEJO_TOKEN is empty — create a PAT at https://$host/user/settings/applications and export FORGEJO_TOKEN" >&2

# proxy cred missing for a proxied host
if [ "$requires_proxy_auth" = "yes" ] && [ -z "$FORGEJO_PROXY_AUTH" ]; then
  echo "Forgejo: \$FORGEJO_PROXY_AUTH is empty — $host sits behind a Basic-auth reverse proxy, 'user:pass' is required (see §6)" >&2
fi
```

These are **distinct messages** so the user knows which credential is missing.

---

## 8. Forgejo / Gitea API reference

- Auth header: `Authorization: token <PAT>`. Base: `https://<instance>/api/v1/`.
  Swagger at `/swagger.v1.json`. PAT at `/user/settings/applications`.
- CI status: `GET /api/v1/repos/{owner}/{repo}/commits/{ref}/status` → combined
  `state` + `statuses[]`. **Empty `statuses[]` ≠ green** (see §4).
- Issues: `GET /api/v1/repos/{owner}/{repo}/issues/{index}`, or `tea issues`.
- PRs are **pull requests** (not "merge requests"), per-repo index.
- `tea`: `tea logins add --name <n> --url <url> --token <tok>`; `--login <n>`
  per-command; `tea pulls list|create|merge --style <merge|squash|rebase|rebase-merge>`;
  `tea issues list|create`.
- Forgejo Actions: workflows in `.forgejo/workflows/` (fallback `.github/workflows/`).
  CI on a self-host may be external (Woodpecker/Drone), so
  `https://<host>/<owner>/<repo>/actions` may 404 — use the combined-status endpoint
  as the authority, not the Actions URL.
