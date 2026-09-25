// OpenCode plugin: run this project's Claude Code PreToolUse guards, unchanged,
// in OpenCode.
//
// One source of truth, and it is not this file. The guard *logic* stays in
// hooks/*.sh and the *wiring* stays in .claude/settings.json of the project
// OpenCode is working in (plus .claude/settings.local.json when it exists, whose
// hooks are merged in, as Claude Code does); this bridge only translates between
// the two tools' vocabularies and hands the scripts the JSON they already read.
// Add a guard by editing .claude/settings.json, as you would for Claude Code.
// Nothing here needs to change.
//
// Install it per project, by copying or symlinking it into the project's plugin
// directory (see INSTALL.md):
//   mkdir -p .opencode/plugins
//   cp hooks/opencode-guard-bridge.js .opencode/plugins/
// The project root is taken from OpenCode's plugin context (worktree, then
// directory, then the current directory), never from where this file lives, so
// a copy and a symlink behave the same. OpenCode reports the worktree as "/"
// for a project outside git, so that value is skipped. Settings in your home
// directory are never read.
//
// The contract each script already implements, and which this file relies on:
//   * it reads one JSON object on stdin;
//   * it looks at .tool_name and .tool_input.{command,file_path,path};
//   * exit 2 means BLOCK and the reason is on stderr;
//   * exit 0 means allow.
//
// Failing closed. For the tools that can change something (bash, edit, write,
// patch, apply_patch, multiedit), a missing guard is not permission: if
// .claude/settings.json cannot be read, the call is refused with "guard not
// installed"; if the settings wire no PreToolUse guard for the tool, with "no
// guard wired for <Tool>"; if a wired guard cannot be started (exit 126 or 127,
// or a spawn error) or does not finish (killed by a signal, an exit status of
// 128 or more, which is how a shell reports a child killed by a signal, or
// still running after 60 seconds), with "guard not installed" or "guard did
// not finish". For
// read-only tools the same problems are logged and the call proceeds. Any other
// non-zero exit is logged and does not block; only exit 2 is a verdict.
//
// Patch-style tools name their files inside the patch text, not in an argument.
// The bridge reads every path from the "*** Add File:", "*** Update File:",
// "*** Delete File:" and "*** Move to:" lines and runs the Edit guards once per
// path; a patch that is missing, unparseable or names no path is refused.

import { spawnSync } from "node:child_process"
import { existsSync, readFileSync } from "node:fs"
import { join } from "node:path"

// OpenCode names its tools in lower case; the matchers in settings.json use
// Claude Code's names. Anything not in this table is passed through under its
// own name and logged, so a new OpenCode tool is unmatched rather than silently
// mapped, and the warning says so.
const TOOL_NAMES = {
  bash: "Bash",
  edit: "Edit",
  write: "Write",
  patch: "Edit",
  apply_patch: "Edit",
  multiedit: "Edit",
  read: "Read",
  grep: "Grep",
  glob: "Glob",
  webfetch: "WebFetch",
}

// The tools for which a missing guard blocks instead of warning.
const FAIL_CLOSED = new Set(["bash", "edit", "write", "patch", "apply_patch", "multiedit"])

// The tools whose files are named inside args.patchText.
const PATCH_TOOLS = new Set(["patch", "apply_patch"])

// The guards read snake_case; OpenCode passes camelCase. Its grep names the glob `include`.
const ARG_NAMES = { filePath: "file_path", oldString: "old_string", newString: "new_string", include: "glob" }

// A guard that runs longer than this is killed and counts as not having run.
const GUARD_TIMEOUT_MS = 60000

function settingsPath(root) {
  return join(root, ".claude", "settings.json")
}

function preToolUse(file) {
  const entries = JSON.parse(readFileSync(file, "utf8"))?.hooks?.PreToolUse ?? []
  if (!Array.isArray(entries)) throw new Error("hooks.PreToolUse is not a list")
  return entries
}

// The PreToolUse entries of settings.json, followed by those of
// settings.local.json when that file exists. Returns an error string instead
// when either file cannot be read: the caller decides, never a silent allow for
// write tools.
function loadHooks(root) {
  const main = settingsPath(root)
  const local = join(root, ".claude", "settings.local.json")
  let entries
  try {
    entries = preToolUse(main)
  } catch (e) {
    return { error: `guard not installed: cannot read ${main}: ${e.message}` }
  }
  if (existsSync(local)) {
    try {
      entries = entries.concat(preToolUse(local))
    } catch (e) {
      return { error: `guard not installed: cannot read ${local}: ${e.message}` }
    }
  }
  return { entries }
}

function matches(matcher, toolName) {
  if (!matcher || matcher === "*") return true
  try {
    return new RegExp(`^(?:${matcher})$`).test(toolName)
  } catch {
    return matcher === toolName
  }
}

function toolInput(args) {
  const out = {}
  for (const [k, v] of Object.entries(args ?? {})) out[ARG_NAMES[k] ?? k] = v
  return out
}

// Every path a patch touches, or an error string when there is nothing to check.
function patchPaths(patchText) {
  if (typeof patchText !== "string" || patchText.trim() === "") return { error: "patchText is missing" }
  if (!/^\*\*\* Begin Patch\s*$/m.test(patchText)) return { error: "patchText is unparseable: no \"*** Begin Patch\" line" }
  const paths = []
  for (const m of patchText.matchAll(/^\*\*\* (?:Add File|Update File|Delete File|Move to): (.+)$/gm)) {
    const p = m[1].trim()
    if (p) paths.push(p)
  }
  if (paths.length === 0) return { error: "patchText names no file" }
  return { paths }
}

// Reachable from a test without starting OpenCode, because a guard that has
// never been seen to block is a comment. `opts.timeoutMs` exists so the test
// can see a hung guard refused without waiting a minute.
function checkToolCall(tool, args, root = process.cwd(), opts = {}) {
  const closed = FAIL_CLOSED.has(tool)
  const known = Object.hasOwn(TOOL_NAMES, tool)
  const toolName = known ? TOOL_NAMES[tool] : tool
  const problems = known ? [] : [`unmapped tool ${tool}: passed to the guards under its own name`]

  const loaded = loadHooks(root)
  if (loaded.error) return closed ? { blocked: true, reason: loaded.error } : { blocked: false, error: loaded.error, problems }

  const wired = loaded.entries.filter((e) => matches(e?.matcher, toolName) && (e.hooks ?? []).some((h) => h?.command))
  if (wired.length === 0) {
    const why = `no guard wired for ${toolName}`
    if (closed) return { blocked: true, reason: why }
  }

  // One tool_input per file to check: a patch yields one per path it names.
  let inputs = [toolInput(args)]
  if (PATCH_TOOLS.has(tool)) {
    const parsed = patchPaths(args?.patchText)
    if (parsed.error) return { blocked: true, reason: `${tool}: ${parsed.error}` }
    inputs = parsed.paths.map((p) => ({ ...inputs[0], file_path: p }))
  }

  const env = { ...process.env, CLAUDE_PROJECT_DIR: root }
  const timeout = opts.timeoutMs ?? GUARD_TIMEOUT_MS

  for (const input of inputs) {
    const payload = JSON.stringify({
      session_id: "opencode",
      hook_event_name: "PreToolUse",
      cwd: root,
      tool_name: toolName,
      tool_input: input,
    })
    for (const entry of wired) {
      for (const h of entry.hooks ?? []) {
        if (!h?.command) continue
        const r = spawnSync(h.command, { shell: true, input: payload, encoding: "utf8", cwd: root, env, timeout })
        if (r.error || r.status === null || r.signal || r.status === 126 || r.status === 127 || r.status >= 128) {
          const finished = !r.signal && r.status !== null && r.status < 128 && r.error?.code !== "ETIMEDOUT"
          const detail = r.error ? r.error.message : r.signal ? `killed by ${r.signal}` : `exit ${r.status}`
          const why = `${finished ? "guard not installed" : "guard did not finish"}: ${h.command}: ${detail}`
          if (closed) return { blocked: true, reason: why }
          problems.push(why)
          continue
        }
        if (r.status === 2) {
          const why = (r.stderr || "").trim() || `blocked by ${h.command}`
          return { blocked: true, reason: why }
        }
        if (r.status !== 0) problems.push(`${h.command}: exit ${r.status}`)
      }
    }
  }
  return { blocked: false, problems }
}

// OpenCode's loader walks every export of this module and refuses the plugin if
// one is neither a function nor an object with a function "server" key. So the
// plugin is the only export, and the test reaches the check through a property
// on it.
export const ClaudeGuardBridge = async ({ client, directory, worktree }) => {
  const root = worktree && worktree !== "/" ? worktree : (directory ?? process.cwd())
  const log = async (level, message) => {
    try {
      await client?.app?.log({ body: { service: "claude-guard-bridge", level, message } })
    } catch {
      /* the log is a courtesy; losing it must not change the verdict */
    }
  }

  return {
    "tool.execute.before": async (input, output) => {
      const verdict = checkToolCall(input.tool, output.args, root)
      if (verdict.error) await log("warn", `claude-guard-bridge: ${verdict.error}`)
      for (const p of verdict.problems ?? []) await log("warn", `claude-guard-bridge: ${p}`)
      if (verdict.blocked) throw new Error(verdict.reason)
    },
  }
}

ClaudeGuardBridge.testing = { checkToolCall, GUARD_TIMEOUT_MS }
