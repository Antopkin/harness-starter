// Tests hooks/opencode-guard-bridge.js against the real guard scripts in hooks/
// and the real wiring in .claude/settings.json of this repo.
//
// Run from the repo root:
//   node hooks/opencode-guard-bridge.test.mjs
//
// Dangerous commands are assembled from fragments so this file holds no
// contiguous destructive command.

import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { dirname, join, resolve } from "node:path"
import { fileURLToPath } from "node:url"
import * as bridge from "./opencode-guard-bridge.js"

const { ClaudeGuardBridge } = bridge
const { checkToolCall, GUARD_TIMEOUT_MS } = ClaudeGuardBridge.testing
const root = resolve(dirname(fileURLToPath(import.meta.url)), "..")

const RM = "r" + "m -" + "rf"
const RESET = "re" + "set --" + "hard"
const FORCE = "--" + "force"
const NOVERIFY = "--no-" + "verify"
const CLEAN = "cle" + "an -fd"
const CHECKOUT_ALL = "check" + "out ."
const CJ = ".claude" + ".json"
const ENV = ".e" + "nv"

const fileGuard = `bash "${join(root, "hooks", "file-guard.sh")}"`
const temps = []

// A throwaway project whose .claude/ holds the given settings files.
function project(prefix, files) {
  const dir = mkdtempSync(join(tmpdir(), `bridge-${prefix}-`))
  temps.push(dir)
  if (files) {
    mkdirSync(join(dir, ".claude"))
    for (const [name, body] of Object.entries(files)) {
      writeFileSync(join(dir, ".claude", name), typeof body === "string" ? body : JSON.stringify(body))
    }
  }
  return dir
}
const pre = (...entries) => ({ hooks: { PreToolUse: entries } })
const wire = (matcher, command) => ({ matcher, hooks: [{ type: "command", command }] })

// A patch in OpenCode's apply_patch format touching the given file lines.
const patch = (...lines) => ["*** Begin Patch", ...lines, "*** End Patch"].join("\n")

// A project with no .claude/settings.json at all.
const bare = project("bare")
// A project whose settings wire a guard script that does not exist (exit 127).
const missing = 'bash "$CLAUDE_PROJECT_DIR/hooks/missing-guard.sh"'
const broken = project("broken", { "settings.json": pre(wire("Bash", missing), wire("Read|Grep", missing)) })
// Settings that parse but wire nothing for the write tools, or nothing at all.
const bashOnly = project("bashonly", { "settings.json": pre(wire("Bash", "true")) })
const noHooks = project("nohooks", { "settings.json": {} })
// Settings that are not JSON.
const corrupt = project("corrupt", { "settings.json": "{ not json" })
// The file guard is wired only in settings.local.json, which must be merged in.
const local = project("local", {
  "settings.json": pre(wire("Bash", "true")),
  "settings.local.json": pre(wire("Edit|Write", fileGuard)),
})
// A corrupt settings.local.json fails closed like a corrupt settings.json.
const badLocal = project("badlocal", { "settings.json": pre(wire("Bash|Edit|Write", "true")), "settings.local.json": "[" })
// A guard that is killed by a signal, and one that never finishes.
const killed = project("killed", { "settings.json": pre(wire("Bash|Read", "kill -9 $$")) })
const hung = project("hung", { "settings.json": pre(wire("Bash|Read", "sleep 3")) })
// A guard whose shell reports a killed child as exit 128 + signal (here 137);
// the trailing exit keeps the shell from exec-ing the child and dying itself.
const shellKilled = project("shellkilled", { "settings.json": pre(wire("Bash|Read", "bash -c 'kill -9 $$'; exit $?")) })
const exit130 = project("exit130", { "settings.json": pre(wire("Bash|Read", "exit 130")) })

const cases = [
  // [tool, args, project root, expect blocked, label, options]
  ["bash",  { command: "ls -la /tmp" },                          root,   false, "safe listing"],
  ["bash",  { command: "git status" },                           root,   false, "safe git"],
  ["bash",  { command: `${RM} /tmp/whatever` },                  root,   true,  "recursive force delete"],
  ["bash",  { command: `git -C /repo ${RESET} HEAD~1` },         root,   true,  "hard reset with args between"],
  ["bash",  { command: `git push origin main ${FORCE}` },        root,   true,  "force push with args between"],
  ["bash",  { command: `git commit ${NOVERIFY} -m x` },          root,   true,  "skipping commit hooks"],
  ["bash",  { command: "sudo systemctl restart nginx" },         root,   true,  "sudo"],
  ["bash",  { command: `git ${CLEAN}` },                         root,   true,  "clean without dry run"],
  ["bash",  { command: `git ${CHECKOUT_ALL}` },                  root,   true,  "whole-tree checkout"],
  ["bash",  { command: `cat /tmp/x/${CJ}` },                     root,   true,  "credential store via bash"],
  ["write", { filePath: join(root, ENV) },                       root,   true,  "write to .env"],
  ["edit",  { filePath: join(root, ".git", "config") },          root,   true,  "edit under .git/"],
  ["write", { filePath: join(root, `${ENV}.example`) },          root,   false, "write to .env.example"],
  ["edit",  { filePath: join(root, "src", "app.py") },           root,   false, "ordinary source edit"],
  ["read",  { filePath: join(root, "README.md") },               root,   false, "ordinary read"],
  ["read",  { filePath: join("/tmp", "fakehome", CJ) },          root,   true,  "read the credential store"],
  ["grep",  { pattern: "x", path: join("/tmp", "fakehome", CJ) }, root,  true,  "grep the credential store"],

  // Patch-style tools: every path named in the patch goes through the Edit guards.
  ["apply_patch", { patchText: patch(`*** Add File: ${ENV}`, "+K=v") },              root, true,  "apply_patch adds .env"],
  ["apply_patch", { patchText: patch("*** Update File: src/app.py", "@@", "-a", "+b") }, root, false, "apply_patch updates a source file"],
  ["apply_patch", { patchText: patch("*** Update File: src/app.py", "@@", "-a", "+b", `*** Delete File: ${ENV}`) },
                                                                                      root, true,  "apply_patch: second path is .env"],
  ["apply_patch", { patchText: patch("*** Update File: src/app.py", "*** Move to: .git/config", "@@", "-a", "+b") },
                                                                                      root, true,  "apply_patch moves a file into .git/"],
  ["apply_patch", { patchText: patch(`*** Delete File: ${join(root, ENV)}`) },        root, true,  "apply_patch deletes .env by absolute path"],
  ["apply_patch", {},                                                                 root, true,  "apply_patch without patchText"],
  ["apply_patch", { patchText: "--- a/x\n+++ b/x\n" },                                root, true,  "apply_patch with unparseable patchText"],
  ["apply_patch", { patchText: patch() },                                             root, true,  "apply_patch naming no file"],
  ["patch",       { patchText: patch(`*** Update File: ${ENV}`, "@@", "-a", "+b") },  root, true,  "patch updates .env"],
  ["patch",       { patchText: patch("*** Update File: notes.md", "@@", "-a", "+b") }, root, false, "patch updates a note"],
  ["multiedit",   { filePath: join(root, ENV), edits: [] },                           root, true,  "multiedit on .env"],
  ["multiedit",   { filePath: join(root, "src", "app.py"), edits: [] },               root, false, "multiedit on a source file"],
  ["todowrite",   { todos: [] },                                                      root, false, "unmapped tool proceeds with a warning"],

  // No settings file: the write tools fail closed, reads proceed.
  ["bash",  { command: "ls -la" },                               bare,   true,  "no settings: bash fails closed"],
  ["write", { filePath: join(bare, "notes.md") },                bare,   true,  "no settings: write fails closed"],
  ["edit",  { filePath: join(bare, "notes.md") },                bare,   true,  "no settings: edit fails closed"],
  ["patch", { patchText: "x" },                                  bare,   true,  "no settings: patch fails closed"],
  ["apply_patch", { patchText: patch("*** Update File: a.md") }, bare,   true,  "no settings: apply_patch fails closed"],
  ["multiedit", { filePath: join(bare, "notes.md") },            bare,   true,  "no settings: multiedit fails closed"],
  ["read",  { filePath: join(bare, "notes.md") },                bare,   false, "no settings: read proceeds"],
  ["bash",  { command: "ls -la" },                               corrupt, true, "corrupt settings: bash fails closed"],
  ["read",  { filePath: join(corrupt, "notes.md") },             corrupt, false, "corrupt settings: read proceeds"],

  // A wired guard that cannot start.
  ["bash",  { command: "ls -la" },                               broken, true,  "guard exits 127: bash fails closed"],
  ["read",  { filePath: join(broken, "notes.md") },              broken, false, "guard exits 127: read proceeds"],

  // Settings that parse but wire no guard for the tool.
  ["bash",  { command: "ls -la" },                               bashOnly, false, "Bash wired: bash proceeds"],
  ["write", { filePath: join(bashOnly, "notes.md") },            bashOnly, true,  "nothing wired for Write: write fails closed"],
  ["edit",  { filePath: join(bashOnly, "notes.md") },            bashOnly, true,  "nothing wired for Edit: edit fails closed"],
  ["read",  { filePath: join(bashOnly, "notes.md") },            bashOnly, false, "nothing wired for Read: read proceeds"],
  ["bash",  { command: "ls -la" },                               noHooks, true,  "no hooks at all: bash fails closed"],

  // settings.local.json is merged in.
  ["write", { filePath: join(local, ENV) },                      local,  true,  "guard wired in settings.local.json blocks .env"],
  ["write", { filePath: join(local, "notes.md") },               local,  false, "guard wired in settings.local.json allows a note"],
  ["bash",  { command: "ls -la" },                               local,  false, "settings.json still wires Bash"],
  ["write", { filePath: join(badLocal, "notes.md") },            badLocal, true, "corrupt settings.local.json: write fails closed"],

  // A guard that does not finish counts as a guard that did not run.
  ["bash",  { command: "ls -la" },                               killed, true,  "guard killed by a signal: bash fails closed"],
  ["read",  { filePath: join(killed, "notes.md") },              killed, false, "guard killed by a signal: read proceeds"],
  ["bash",  { command: "ls -la" },                               hung,   true,  "guard times out: bash fails closed", { timeoutMs: 300 }],
  ["read",  { filePath: join(hung, "notes.md") },                hung,   false, "guard times out: read proceeds", { timeoutMs: 300 }],
  ["bash",  { command: "ls -la" },                               shellKilled, true,  "guard exits 137: bash fails closed"],
  ["read",  { filePath: join(shellKilled, "notes.md") },         shellKilled, false, "guard exits 137: read proceeds"],
  ["bash",  { command: "ls -la" },                               exit130, true,  "guard exits 130: bash fails closed"],
  ["read",  { filePath: join(exit130, "notes.md") },             exit130, false, "guard exits 130: read proceeds"],

  // The file guard covers the gitfile of a worktree and lets tokenizer.json through.
  ["multiedit", { filePath: join(root, ".git") },                root,   true,  "multiedit on a worktree .git file"],
  ["write", { filePath: join(root, "models", "tokenizer.json") }, root,  false, "write to tokenizer.json"],
]

// Reasons a case must carry, beyond its verdict.
const reasons = {
  "nothing wired for Write: write fails closed": /no guard wired for Write/,
  "guard wired in settings.local.json blocks .env": /protected file/,
  "guard killed by a signal: bash fails closed": /guard did not finish/,
  "guard times out: bash fails closed": /guard did not finish/,
  "guard exits 137: bash fails closed": /guard did not finish/,
  "guard exits 130: bash fails closed": /guard did not finish/,
  "apply_patch without patchText": /patchText is missing/,
  "apply_patch naming no file": /names no file/,
}

let pass = 0, fail = 0
function report(ok, line, detail = "") {
  ok ? pass++ : fail++
  console.log(`${ok ? "ok  " : "FAIL"}  ${line}${detail}`)
}

for (const [tool, args, at, expectBlocked, label, opts] of cases) {
  const v = checkToolCall(tool, args, at, opts)
  const reasonOk = !reasons[label] || reasons[label].test(v.reason ?? "")
  const want = expectBlocked ? "BLOCK" : "ALLOW"
  const got = v.blocked ? "BLOCK" : "ALLOW"
  report(v.blocked === expectBlocked && reasonOk, `${want}/${got}  ${tool.padEnd(11)} ${label}`,
         v.blocked ? "  <- " + v.reason.split("\n")[0].slice(0, 70) : "")
  if (v.problems?.length) console.log("        problems:", v.problems.join("; "))
}

// The unmapped tool is logged, not silently passed.
const unmapped = checkToolCall("todowrite", {}, root)
report((unmapped.problems ?? []).some((p) => /unmapped tool todowrite/.test(p)), "unmapped tool is reported as a problem")

report(GUARD_TIMEOUT_MS === 60000, "guards are killed after 60 seconds")

// OpenCode's loader rule: every export is a plugin, i.e. a function or an
// object whose "server" is a function; anything else aborts the load.
const badExports = Object.entries(bridge)
  .filter(([, v]) => !(typeof v === "function" || (v && typeof v === "object" && typeof v.server === "function")))
  .map(([k]) => k)
report(badExports.length === 0, "every export passes OpenCode's plugin loader", badExports.length ? `  <- ${badExports.join(", ")}` : "")

// The plugin itself, as OpenCode calls it. A project outside git gets worktree
// "/", which must fall back to the directory rather than read /.claude/.
const warnings = []
const client = { app: { log: async ({ body }) => { warnings.push(body.message) } } }
for (const [label, ctx] of [
  ["worktree is the project", { worktree: root, directory: join(root, "hooks") }],
  ['worktree "/" falls back to directory', { worktree: "/", directory: root }],
  ["no worktree falls back to directory", { directory: root }],
]) {
  const hooks = await ClaudeGuardBridge({ client, ...ctx })
  const out = []
  for (const [tool, args] of [["bash", { command: `${RM} /tmp/bridge-x` }], ["write", { filePath: join(root, ENV) }], ["bash", { command: "ls -la" }]]) {
    try {
      await hooks["tool.execute.before"]({ tool, sessionID: "s", callID: "c" }, { args })
      out.push("ALLOW")
    } catch {
      out.push("BLOCK")
    }
  }
  report(out.join(",") === "BLOCK,BLOCK,ALLOW", `plugin: ${label}`, `  <- ${out.join(",")}`)
}
{
  warnings.length = 0
  const hooks = await ClaudeGuardBridge({ client, worktree: root, directory: root })
  await hooks["tool.execute.before"]({ tool: "todowrite", sessionID: "s", callID: "c" }, { args: {} })
  report(warnings.some((w) => /unmapped tool todowrite/.test(w)), "plugin: unmapped tool is logged as a warning")
}

for (const dir of temps) rmSync(dir, { recursive: true, force: true })
console.log(`\npass=${pass} fail=${fail}`)
process.exit(fail ? 1 : 0)
