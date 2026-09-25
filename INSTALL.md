# Installing the harness: instructions for the agent

> **For the human (read these lines and you are done).**
> What this is and why is in `README.md` next to this file; this file is the installation guide.
> Install jq first (brew install jq / apt install jq): the guards need it.
> Open your agent (Claude Code, OpenCode or Codex) right in this folder and tell it:
> **"read INSTALL.md and set up the harness for my tool"**. It does the rest itself.

---

## From here on: instructions for the agent

You are a coding agent (Claude Code, OpenCode or Codex). You were opened in this folder and asked to "set up the harness". The harness is four things plus a safety layer: **rules** (how to behave), **skills** (ready-made procedures for frequent tasks), **agent roles** (subagents you can delegate to), **memory** (facts that survive sessions) and **guards** (hooks that block the most dangerous actions). Your job is to put them where your tool picks them up, and then explain to the user in plain words what you did.

Work in small steps. Before you write or copy anything, show the user a one- or two-line plan. Do not touch anything outside this folder without asking.

**At a glance.** The commands per tool, explained step by step below:

| Step | Claude Code | OpenCode | Codex |
|---|---|---|---|
| skills | `mkdir -p .claude/skills && cp -R skills/. .claude/skills/` (academic overlay: `cp -R tracks/academic/skills/. .claude/skills/`) | reuses `.claude/skills/` or `.agents/skills/`; alone: `mkdir -p .opencode/skills && cp -R skills/. .opencode/skills/` | `mkdir -p .agents/skills && cp -R skills/. .agents/skills/` |
| agent roles | `mkdir -p .claude/agents && cp agents/*.md .claude/agents/` | `python3 hooks/opencode-agents-sync.py --apply` | read `agents/<role>.md` as a persona file |
| guards | ship in `.claude/settings.json`; prove with `bash hooks/hooks-selftest.sh` | `mkdir -p .opencode/plugins && cp hooks/opencode-guard-bridge.js .opencode/plugins/`; prove with `node hooks/opencode-guard-bridge.test.mjs` | this starter does not wire Codex hooks yet; the rules apply as AGENTS.md prose |

### Step 0. Look around: what the starter already contains

```
harness-starter/       ← repository root
├── README.md          ← landing page for the human: what this is and why
├── INSTALL.md         ← this file (installation guide)
├── AGENTS.md          ← the rule set. SOURCE OF TRUTH, read by all three tools
├── CLAUDE.md          ← thin wrapper of the rules for Claude Code (points to AGENTS.md)
├── hello.md           ← first exercise, to check that everything is connected
├── runbooks.md        ← recipes for frequent operations (browser, rollback, your own skill)
├── contexts/          ← rules read on demand (git workflow, guards, orchestration, writing…)
├── agents/            ← 21 agent roles, one Markdown file each
├── hooks/             ← guards, their self-test, the OpenCode bridge and agents sync
├── .claude/
│   └── settings.json  ← Claude Code wiring of the guards
├── memory/
│   ├── MEMORY.md      ← project memory index plus a short tutorial
│   └── feedback_example.md ← an example memory note
├── materials/         ← the user puts their PDFs and sources here
├── skills/            ← ready-made skills, one folder each: skills/<name>/SKILL.md
├── tracks/
│   └── academic/      ← academic overlay, installed on top of the base (see its README)
├── LICENSE            ← repository licence (MIT for the original parts)
└── CREDITS.md         ← attribution: third-party skills and roles and their licences
```

If a file from this list is missing, do not invent it; tell the user what is missing and carry on with what is there.

**Check jq.** Run `jq --version`. jq is required: the guards that parse JSON (`bash-guard.sh`, `file-guard.sh`, `read-guard.sh`, `skip-ci-guard.sh`) start with a jq check and, without jq, block every call they see with "guard inactive: install jq"; a jq that fails blocks the call too. If jq is missing, ask the user to install it (brew install jq / apt install jq) before you go on. Only `pasted-key-guard.sh` works without jq.

### Step 1. Work out your tool

Work out which of the three tools you are running in; your environment and system prompt make it clear: **Claude Code**, **OpenCode** or **Codex**. It decides _where_ the rules file goes and _how_ the tool finds skills, roles and guards. The three tools do this differently, so in steps 2 to 4 take the branch for your tool. The content of the rules and skills is the same for all; only the file layout differs.

### Step 2. Install the rules

`AGENTS.md` at the root is the single rule set and the **source of truth**. It stays where it is; do not copy its content into other files, let each tool read it in its own way.

- **Claude Code** does not read `AGENTS.md` by itself. It needs a `CLAUDE.md` that pulls the rules in with the line `@AGENTS.md`. The starter already has such a `CLAUDE.md` at the root; check that it is there and contains `@AGENTS.md`. If the file is missing, create it with the single line `@AGENTS.md` (it may also live in `.claude/CLAUDE.md`, which is the same project level).
  - Personal tweaks just for you that you do not commit go into `CLAUDE.local.md` at the root (it is already in `.gitignore`). Rules for all your projects go into `~/.claude/CLAUDE.md`.
  - The `/memory` command shows what was actually loaded into the session.
- **OpenCode** reads `AGENTS.md` from the project root **natively** (and looks for it up the directory tree). Nothing else is needed. OpenCode uses `CLAUDE.md` only as a fallback when there is no `AGENTS.md`; since `AGENTS.md` is present, `CLAUDE.md` is simply not read, so leave it for Claude Code. Rules for all projects go into `~/.config/opencode/AGENTS.md`.
- **Codex** reads `AGENTS.md` **natively** (from the root of the git repository down to the working folder). It does not read `CLAUDE.md` at all, so do not count on it. No action is needed.
  - Rules for all projects go into `~/.codex/AGENTS.md`.
  - Codex caps the size of its rules (about 32 KB by default). Our `AGENTS.md` is well below that; if it ever grows past it, raise `project_doc_max_bytes` in `~/.codex/config.toml`.

### Step 3. Connect the skills

The skills live in `skills/<name>/SKILL.md`. Each has `name` in its frontmatter (the same as the folder name: lower case and hyphens) and `description` (the tool uses it to decide when to apply the skill). Some skills have a `references/`, `scripts/` or `agents/` folder next to `SKILL.md`; that is part of the skill, so do not touch or drop it. `skills/shared/` is not a skill but a helper file that the git skills read; copy it along with the rest.

Good news: all three tools support skills **natively**, so there is no need to "read `SKILL.md` by hand". Only the folder and the way of calling differ.

- **Claude Code**: copy the skills to where the tool finds them:
  ```
  mkdir -p .claude/skills && cp -R skills/. .claude/skills/
  ```
  For the academic overlay, add `cp -R tracks/academic/skills/. .claude/skills/` afterwards (details in the track's README).
  After this, skills are called by name (`/ru-text`, `/review` and so on) and are picked up automatically by `description`.
  - Caveat: if `.claude/skills/` did not exist when the session started, Claude Code only notices it after a restart. If you copied the skills and they do not show up under `/`, restart the tool. (Edits inside an existing folder are picked up on the fly.)
- **OpenCode**: native skills too, and the layout is easiest here: OpenCode also reads the compatible paths **`.claude/skills/` and `.agents/skills/`**. Whatever copy you made for Claude Code (`.claude/skills/`) or for Codex (`.agents/skills/`, see below), OpenCode reuses it from there, and it needs no copy of its own. If OpenCode is your only tool, put the skills in its own path:
  ```
  mkdir -p .opencode/skills && cp -R skills/. .opencode/skills/
  ```
  - How they are called: OpenCode shows the agent the list of skills with their `description` through the built-in `skill` tool and calls the matching one by description; a skill triggers by task, not through `/` (slash commands `/name` in OpenCode are a separate mechanism, Commands, not skills).
  - `name` and `description` in the frontmatter are mandatory; our skills already have them.
- **Codex**: native skills, but a **different** path: Codex looks for them in `.agents/skills/` (not `.claude/skills` and not `.codex/skills`). Copy them at repository level:
  ```
  mkdir -p .agents/skills && cp -R skills/. .agents/skills/
  ```
  - How they are called: Codex picks a skill by matching the task against `description`, and the `/skills` slash command lists them for a manual choice.
  - `name` and `description` in the frontmatter are mandatory; they are already there.

For the academic overlay in OpenCode or Codex, copy `tracks/academic/skills/.` into the same skills folder you used above.

The overlay's rules addendum, `tracks/academic/AGENTS.academic.md`, is not copied to the repository root; it is imported in place. In Claude Code, add the line `@tracks/academic/AGENTS.academic.md` to `CLAUDE.md`. In OpenCode and Codex, add to `AGENTS.md` a line telling the agent to read `tracks/academic/AGENTS.academic.md` for academic work.

**User-invoked skills.** Some skills carry `disable-model-invocation: true` in their frontmatter, marked "user-invoked" in the table below. Only Claude Code honours that flag and runs such a skill solely when the user calls it. OpenCode and Codex ignore it and may still start the skill on their own; tell the user so, and in those tools run a user-invoked skill only on an explicit request.

**If nothing gets picked up.** Tool versions differ, and an old build may not pick skills up automatically. Then degrade gracefully: the list of skills with their triggers is in the table below; open the needed `skills/<name>/SKILL.md` and follow its steps by hand. That is the fallback, not the main path.

### Step 4. Connect the agent roles and the guards

The role files in `agents/` describe focused subagents (a reader, a reviewer, an editor, a research analyst, engineering specialists). Their `tools:` and `model:` frontmatter fields are Claude Code mechanics and can be ignored elsewhere. The guards in `hooks/` block edits to secret and protected files (`.env*`, `.git/`, `secrets/`, credential and token files), destructive git commands, recursive forced deletes, a commit that skips CI while it touches code, and API keys pasted into a prompt. In Claude Code, and through the bridge in OpenCode, they also stop the Read and Grep tools from opening `.env*` files (except `.env.example` and `.env.sample`) or the Claude credential store; the Bash guard refuses any shell command that names the credential store, but a shell read such as `cat .env` is not guarded. The Bash guard reads the words of a command as written: it does not expand command substitution or aliases, so a command such as `$(which rm)` goes past it.

Three refinements matter in daily work. A heredoc body counts as data only when it feeds an allowlisted sink: `git commit` or `git tag` reading the message with `-F -`, or `cat` inside a quoted `"$( )"` message argument of `git` or `gh`. So a commit message that describes a dangerous command gets past the per-word pass, while any other heredoc body is scanned as commands; the checks for `--no-verify`, `sudo` and the credential store still read every word. `git reset --help`, spelled out exactly, is allowed. The read guard splits a Grep glob list the way Claude Code does, on whitespace and then on commas, checks every part, and refuses a part that starts with `!`; it also refuses a Grep with no glob whose root is the home directory or a parent of it, because Claude Code's Grep always searches hidden files and would reach the credential store.

- **Claude Code**
  - Agent roles:
    ```
    mkdir -p .claude/agents && cp agents/*.md .claude/agents/
    ```
  - Guards: they ship in `.claude/settings.json`, which wires every hook as `bash "$CLAUDE_PROJECT_DIR/hooks/<name>.sh"` and denies edits to `.env` files and `.ssh/`. Nothing to copy. Prove they work:
    ```
    bash hooks/hooks-selftest.sh
    ```
  - Known gap, tell the user: Claude Code blocks a call only when a guard exits with code 2. A guard that times out, is killed or exits with any other code is treated as non-blocking, so a hung guard fails open in Claude Code.
- **OpenCode**
  - Agent roles: sync them into `.opencode/agent/` of this project (the script never touches your home folder):
    ```
    python3 hooks/opencode-agents-sync.py --apply
    ```
  - Guards: install the bridge plugin, which runs the same guard scripts, wired in `.claude/settings.json` (and `.claude/settings.local.json` if present), before OpenCode's bash, edit, write, read and grep tools and before `multiedit`, `patch` and `apply_patch`, checking every path a patch names. For bash and the editing tools it fails closed: no guard wired, a guard that cannot start (exit 126 or 127), or one that does not finish (killed by a signal, an exit status of 128 or more, or still running after 60 seconds) refuses the call; for read and grep the same problems are logged and the call proceeds:
    ```
    mkdir -p .opencode/plugins && cp hooks/opencode-guard-bridge.js .opencode/plugins/
    ```
    Prove it works:
    ```
    node hooks/opencode-guard-bridge.test.mjs
    ```
  - Known gaps, tell the user: OpenCode has no pasted-key guard, because the bridge only sees tool calls and never the prompt, so a key pasted into the chat is not caught. OpenCode also does not apply the `permissions.deny` list of `.claude/settings.json`; keep secrets out of the project folder.
- **Codex**
  - Agent roles: Codex has no subagent files; when a task calls for a role, read `agents/<role>.md` as a persona file and follow it.
  - Guards: this starter does not wire Codex hooks yet; the rules apply as AGENTS.md prose. Tell the user that in Codex nothing mechanically stops a destructive command, so the approval prompts of Codex itself are the last line of defence.

The details of every guard, its known limits, and what to do when one blocks you, are in `contexts/hooks-overview.md`. CI runs the same tests: `.github/workflows/selftest.yml` runs the hooks self-test, the bridge test and an agents-sync smoke run on every pull request, so if you change a guard, run `bash hooks/hooks-selftest.sh` before you open one.

### Step 5. Set up memory

Check that `memory/MEMORY.md` exists. It is the index of facts that should survive restarts: how the project is built, where things are, which decisions are already made, and the corrections the user gave. Do not add anything yet; you will write the first note after `hello.md`. The note format and an example note (`memory/feedback_example.md`) are linked from the index.

### Step 6. Explain to the human what you did

Briefly and without jargon, tell the user roughly the following (in your own words):
- which tool you detected;
- that the rules now live in `AGENTS.md` (and, for Claude Code, are connected through `CLAUDE.md`);
- that N skills are available, naming the three or four most useful for them, and which ones are user-invoked;
- which agent roles and guards are connected, and the gaps of their tool (OpenCode: no pasted-key guard, and the `permissions.deny` list of `.claude/settings.json` is not applied; Codex: this starter does not wire Codex hooks yet, so the rules apply as AGENTS.md prose);
- that memory is set up in `memory/MEMORY.md`;
- in one sentence: **"you are now inside the harness"**: the agent knows the rules, has the skills, delegates to roles and remembers facts.

### Step 7. Offer to run hello.md

Ask whether to run the first exercise from `hello.md`; in a minute it checks that the rules and skills are really connected.

---

## Skills in the starter

"User-invoked" means the skill runs only when the user calls it, and only Claude Code honours that; OpenCode and Codex may still start it on their own.

| Skill | What for | How to call |
|---|---|---|
| `canvas-design` | Posters, art and other static visual pieces in .png or .pdf, from a design philosophy | "design a poster about…" / `/canvas-design` |
| `claude-automation-recommender` | Recommends Claude Code automations (hooks, subagents, skills, MCP servers) for a codebase; user-invoked | `/claude-automation-recommender` |
| `code-documenter` | Docstrings, OpenAPI specs, JSDoc and user guides | "document this module" / `/code-documenter` |
| `diagnose` | Disciplined debugging of hard bugs and performance regressions | "diagnose this bug" / `/diagnose` |
| `digest` | A source-anchored digest of a paper (PDF, docx, md, txt) with a reference entry | "make a digest of this PDF" / `/digest` |
| `doc-coauthoring` | A structured workflow for co-writing documentation, proposals and specs | "let's write a design doc" / `/doc-coauthoring` |
| `explain` | A structured explanation of code, a function or a concept | "explain this code" / `/explain` |
| `fill-form` | Fills a web form from a memo or structured data, with read-back checks and a human gate before submitting; needs the agent-browser CLI and a Chrome started with `--remote-debugging-port=9222` | "fill in this form" / `/fill-form` |
| `find-skills` | Finds and installs published agent skills | "is there a skill for…" / `/find-skills` |
| `git-clean-gone` | Deletes local branches whose upstream is gone, and their worktrees | "clean up gone branches" / `/git-clean-gone` |
| `git-finalize` | Commit, push, create or reuse a pull request, one CI check, stop before merge | "finalize this branch" / `/git-finalize` |
| `git-worktree-status` | A read-only survey of worktrees and branches with a CI column | "show worktree status" / `/git-worktree-status` |
| `grill-me` | An interview about a plan or design until you share an understanding | "grill me on this plan" / `/grill-me` |
| `grill-with-docs` | The same grilling, checked against CONTEXT.md and ADRs, updating them inline | "grill this against the docs" / `/grill-with-docs` |
| `handoff` | A compact handoff document so the next session can pick up the work; user-invoked | `/handoff` |
| `improve-codebase-architecture` | Finds deepening and refactoring opportunities in a codebase | "how could this architecture improve" / `/improve-codebase-architecture` |
| `init-architecture` | A wizard that writes a first CLAUDE.md, ADR-001 and path-scoped rules for a new project; user-invoked | `/init-architecture` |
| `lit-search` | Systematic literature search and a short review with verifiable quotes | "find literature on…" / `/lit-search` |
| `mck-summary` | A pyramid executive summary of finished material; user-invoked | `/mck-summary` |
| `mckinsey` | Issue trees, market sizing and push-back on hypotheses in the Big-3 manner | "structure this problem" / `/mckinsey` |
| `pickup` | Resumes work from the latest (or a named) handoff document; user-invoked | `/pickup` |
| `retro` | A retrospective of a session that proposes cheap durable fixes; experimental, user-invoked | `/retro` |
| `review` | Two-axis review of a branch or diff: standards and spec; user-invoked | `/review` |
| `ru-text` | Checks and edits Russian text: typography, info-style, editing (in Russian) | "check this Russian text" / `/ru-text` |
| `safe-reader` | A read-only mode for exploring code without changing it | "explore this safely" / `/safe-reader` |
| `skill-creator` | Creates, improves and evaluates your own skills | "create a skill that…" / `/skill-creator` |
| `style-extract` | Extracts an author's style profile from text samples into `memory/style-profiles/` | "extract the style of these texts" / `/style-extract` |
| `tdd` | Spec-driven Red-Green-Refactor with pytest | "let's do this with TDD" / `/tdd` |
| `test` | Generates pytest tests for a Python module or function | "write tests" / `/test` |
| `to-questionnaire` | Turns open questions into a questionnaire for one recipient, in the recipient's language; user-invoked | `/to-questionnaire` |
| `triage-issue` | Finds the root cause of a bug and files an issue with a TDD fix plan | "triage this bug" / `/triage-issue` |
| `wayfinder` | Maps work too big for one session as decision tickets under `plans/wayfinder/`; user-invoked | `/wayfinder` |
| `web-parse` | Structured capture from an already signed-in web session, with an ethics checklist | "collect the posts from this page" / `/web-parse` |
| `wizard` | Writes an interactive bash wizard for steps only the user may perform, such as entering credentials; user-invoked | `/wizard` |
| `write-from-digests` | Writes a memo only from finished digests, every claim anchored and verified | "write a memo from these digests" / `/write-from-digests` |
| `writing-fragments` | Explores a piece of writing before it has a structure; experimental, user-invoked | `/writing-fragments` |
| `writing-guru` | Chooses a narrative strategy before writing and checks tone along the way | "pick a narrative" / `/writing-guru` |
| `zoom-out` | A broader, higher-level view of a section of code; user-invoked | `/zoom-out` |

Every skill is a folder `skills/<name>/` with a `SKILL.md` inside. Open any `SKILL.md` to see what exactly the skill does and which triggers start it.

## Where next

- `runbooks.md`: recipes for frequent operations (reading a web resource with a browser, rolling back an edit safely, adding your own skill).
- `materials/`: put your PDFs and files here; `digest`, `lit-search` and `write-from-digests` take their material from this folder.
- `contexts/`: the rules read on demand; `AGENTS.md` has a table of when to read which.
- `tracks/academic/`: the academic overlay on top of the base: source discipline, large research skills, MCP servers for paper search and Zotero. Installation is in its `README.md`.
