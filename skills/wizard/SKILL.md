---
name: wizard
description: Write an interactive bash wizard that walks the user through steps only the user may perform, such as entering credentials, setting CI secrets on GitHub or Forgejo, rotating a token, or running a one-off cutover. The agent writes and checks the script and never runs it; the user runs it in their own terminal. User-invoked only, through /wizard.
argument-hint: "[user-only procedure, e.g. rotate the CI deploy token]"
disable-model-invocation: true
---

# Wizard

A **wizard** is a bash script that walks the user, stage by stage, through a manual procedure that only they may carry out: pasting a credential, setting a CI secret, rotating a token, flipping a cutover. It opens each URL, says exactly what to click and copy, captures the values with hidden input, writes them where they belong (`.env`, a GitHub secret, a Forgejo secret), asks for confirmation before anything irreversible, and shows how many stages are left.

The UX and the secret transport are already solved by [template.sh](template.sh): stage progress, confirmation gates, cross-platform URL opening, hidden and non-empty secret entry, idempotent `.env` upserts, GitHub and Forgejo secret writes, and a closing summary. **Your job is only to scope the procedure and author its stages.** The library above the `STAGES` marker is identical in every wizard; never hand-edit it, because its safety properties are the point.

Talk to the user in the language of the user's request, and write the stage text of the script in that language too. The library's own messages stay as they are.

This skill is user-invoked: you start it yourself with `/wizard`. The `disable-model-invocation` flag that stops the agent from starting it on its own is honoured only by Claude Code; OpenCode and Codex may still invoke it automatically. The line below holds however the skill was started.

## The line you never cross

You write the script, check it, and hand it over. You never run it, and you never collect a secret yourself: no secret goes into chat, into a file you write, or into a command you run. If the user pastes a secret into the conversation anyway, do not repeat it anywhere, and tell them to rotate it and to use the wizard for the new value. Every hand-off says, in so many words, "run this in your own terminal".

## Process

### 1. Scope the procedure

Work out every manual step the user must take and every value captured along the way. Read the repo first rather than asking cold:

- For setup and secrets: `.env.example`, `README`, `docker-compose*`, framework config, and the CI workflows under `.github/workflows/` or `.forgejo/workflows/`. Every `secrets.*` or `vars.*` reference there is a value the wizard must produce. Never open `.env` or any other `.env.*` file: they hold real values. When `.env.example`, the CI workflows and the README do not name every key, ask the user for the key names, never the values.
- For a rotation, cutover or migration: the current state, the target state, and the irreversible actions between them, including when the old credential may be revoked.
- For the backend: the git remote decides it. Classify it as the harness does in [../shared/git-host.md](../shared/git-host.md); a GitHub remote uses `set_secret`, a Forgejo remote uses `set_forgejo_secret`. Never write a host name into the script; the template reads it from the remote.

Then show the user the ordered list of stages and the values each produces, and confirm; they may add, drop or reorder stages.

**Done when:** every stage is named in order, and for each captured value you know (a) where the user gets it, (b) where it is written (`.env`, a CI secret, both, or nowhere, since some stages are pure actions), and (c) whether it is secret (hidden entry) or public.

### 2. Map each stage's journey

For each stage, write the precise path a human follows: which URL to open, what to do there, where the value is shown, and which variable it fills, for example "Settings → Applications → Generate token → copy". Where you do not know the current UI or the exact command, say so and ask the user or check the docs; never invent steps that may not exist.

**Done when:** every stage traces to concrete instructions a stranger could follow.

### 3. Author the wizard

Copy `template.sh` to the target path. A wizard is ephemeral by default, so save it under `$TMPDIR`; use the repo's `scripts/` only when the user wants a repeatable setup path that lives in the repo. Replace the example stages with one `stage` per step, in dependency order, and set `TOTAL_STAGES` to the number of stages you wrote.

Use the library helpers: `stage`, `say`/`step`/`note`, `open_url`, `ask` for public values, `ask_secret` for secrets, `write_env`, `set_secret`/`set_var` for GitHub, `set_forgejo_secret`/`set_forgejo_var` for Forgejo, `pause`/`confirm`, and `die` to stop cleanly.

Hold the bar the template sets:

- Open the URL before asking for the value it shows.
- Read every secret with `ask_secret`; it uses hidden input and refuses an empty value.
- `write_env` only values the user wants on disk locally; `set_secret` or `set_forgejo_secret` only the values CI actually needs.
- Put a `confirm` before every irreversible action (revoking a credential, switching traffic, deleting data), and make a "no" stop the wizard with `die` before anything changes.
- Keep a stage to one focused task, because each `stage` clears the screen.
- Never add `set -x`, never echo a secret variable, and never pass a secret as a command-line argument: secrets travel on stdin, never on any command line.

### 4. Verify and hand off

- Run `bash -n <script>`, and `shellcheck <script>` when it is available.
- Run `chmod +x <script>`.
- Do not run it, not even to test it: it opens browsers, blocks on hidden input and writes real secrets. The template also refuses to start without a TTY. Trace it statically instead: every value from step 1 is captured and lands where step 1 said, and every secret name matches a `secrets.*` reference in CI exactly.
- Hand it to the user with one line: "Run this in your own terminal: `bash <path>`". For Forgejo, add that they need a token with write access to the repository and, only if the instance sits behind a reverse proxy that asks for its own login, that credential as `user:password` at the optional "reverse-proxy auth" prompt; pressing Enter at that prompt skips it.
- If the user wants a repeatable setup path, offer to commit the script and link it from the README; otherwise tell them to delete it after the run.

## How the template moves secrets

This is what you check when tracing a script, and what you must not undo in the stages:

- **No TTY, no run.** The script stops at once unless stdin is a terminal (`[ -t 0 ] ||`), so an agent or a pipe cannot drive it.
- **Secrets travel on stdin, never on any command line.** Any argument of any command shows up in the process list, so a secret only ever moves through a pipe that starts at the `printf` builtin.
- **GitHub.** The value is piped to `gh secret set NAME` on stdin, never with `--body`. When `gh` is missing or not logged in, the step is skipped and listed at the end; once `gh` is authenticated, a failed set (a 403, the wrong repo) shows gh's own error and stops the run.
- **Forgejo.** The host, owner and repo come from the git remote (override with `FORGEJO_URL` or `FORGEJO_REMOTE`), and the script asks the user to confirm them. The optional "reverse-proxy auth" prompt comes first and is skipped with Enter, then the token prompt. Both credentials reach `curl` through a config file on a process substitution (`curl -K <(printf …)`), never as a `curl` user flag or a header argument. For a secret, `printf` pipes the value into `jq -Rs`, which builds the JSON body on stdin; only a public variable value may go through `jq -n --arg`. `curl` sends the body on stdin with `--data-binary @-`, reads the status with `-w '%{http_code}'` and accepts only 201 (created) or 204 (updated); anything else stops the run with a hint.
- **Memory only.** Credentials live in unexported shell variables for the length of the run and are unset at the end.

Adapted from mattpocock/skills@c55ee46 engineering/wizard (MIT).
