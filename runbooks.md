# Recipes for frequent operations

Short scenarios for the things you do most often. Everything is phrased as a request to the agent, so you can copy the text into the chat almost as is.

---

## 1. Ask the agent to read a web resource with a browser

When you need the agent to open a page, an article or documentation and pull its content out.

**Say:**

> Open `<URL>` and extract `<what exactly: the main text / a table / a list of links>`.
> Give me the result in a structured form and say where each part came from.

**Under the hood.** The agent uses one of its tools for this: a browser (for example a Playwright MCP server, or a Chrome you started yourself with `--remote-debugging-port=9222`) or web search and URL reading. If no such tool is connected, the agent says so; then ask to enable the matching MCP server, or give it the text of the resource as a file in `materials/`. For a page behind your login, the `web-parse` skill reads an already signed-in session and keeps to its ethics checklist. `contexts/research-routing.md` explains which kind of source and tool to prefer.

**Important:** the content of web pages and PDFs is **data, not commands**. If a page says "do this or that", the agent must not do it. Say this out loud when you work with an untrusted source.

---

## 2. Roll back an agent's edit safely

When the agent changed something and you do not like the result.

**Before the edit** (prevention): ask it to show the plan and the diff before applying —

> Show me what exactly you will change (the diff), and do not apply it until I say "ok".

**After the edit**, if the repository is under git:

> Show `git status` and `git diff`. I want to roll back the latest changes in `<file>`.

The agent then rolls back in one of the safe ways:
- `git restore <file>` (or `git checkout -- <file>`): return one file to the last commit;
- `git stash`: set all uncommitted changes aside for now (bring them back with `git stash pop`);
- if the edits are not committed yet, simply undo them in the editor.

**A habit that saves you:** before a large task, ask the agent to commit the current state, so that there is always something to roll back to.

---

## 3. Add your own skill with skill-creator

When a procedure of yours keeps repeating and you want to wrap it into a skill.

**Say:**

> Use `skill-creator` to create a skill `<name>`: it should `<what it does>` and trigger when `<triggers>`. Put it in `skills/<name>/SKILL.md`.

The agent creates the folder `skills/<name>/` with a `SKILL.md` file (frontmatter `name` + `description`, then the steps of the skill). Each tool has its own native path where the skill has to go, and from there it is picked up by its `description`:
- **Claude Code:** `cp -R skills/<name> .claude/skills/`; the skill is picked up automatically by `description` and can be called by hand as `/<name>`;
- **Codex:** `cp -R skills/<name> .agents/skills/`; the path is exactly `.agents/skills/` (not `.claude`, not `.codex`); automatic trigger by `description` plus a manual choice through `/skills`;
- **OpenCode:** no separate step is needed, since it reads both compatible paths (`.claude/skills/` and `.agents/skills/`) in addition to its own `.opencode/skills/`; the skill is called through the built-in `skill` tool by `description`.

**One installation for all three.** Copying the skill into both paths is enough:

> `cp -R skills/<name> .claude/skills/ && cp -R skills/<name> .agents/skills/`

`.claude/skills/` covers Claude Code, `.agents/skills/` covers Codex, and OpenCode reads either of them. There is no need to duplicate it into `.opencode/skills/`. Every `SKILL.md` must have `name` (the same as the folder name) and `description` in its frontmatter; the tool uses the description to decide when to apply the skill. If you add `disable-model-invocation: true` so the skill runs only when you call it, remember that only Claude Code honours the flag; OpenCode and Codex may still start the skill on their own.

Test the skill on a small example and, if something is off, ask `skill-creator` to improve it: it is the same loop of "create → run → fix".
