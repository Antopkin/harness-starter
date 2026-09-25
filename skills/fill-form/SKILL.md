---
name: fill-form
description: >
  Fills an arbitrary web form with data from a memo or structured input
  (JSON/YAML) through the agent-browser CLI on top of an already running browser.
  Fields are matched by role and accessible name (not CSS selectors); every field
  gets a read-back verify from the live DOM instead of trusting a successful fill;
  before submitting there is a mandatory human gate (summary of all values plus a
  screenshot, STOP until an explicit yes); submission is idempotent (a log is kept,
  no blind repeat submit). The human starts the browser and logs in during
  pre-flight; the skill only attaches over CDP and NEVER receives the password.
  Triggers: "fill in the form", "fill out the questionnaire", "enter the data into
  the form", "fill the Google Form", "fill form". NOT: extracting or scraping data
  from a form; NOT: starting the browser or logging in for the human; NOT:
  automatic submission without human confirmation.
---

# fill-form — filling a web form from a memo through agent-browser

A runner that fills ANY web form with data from its input: it matches the input to
the fields by **role and accessible name**, reads every field back from the live
DOM, shows the human a summary and a screenshot, and submits only after an explicit
"yes". It is built for non-technical users: the agent does the work, the human leads
and gives the go-ahead to submit.

The skill is an INSTRUCTION to the agent; it does NOT start a browser itself. The
human starts Chrome with `--remote-debugging-port=9222` themselves during pre-flight
and logs in; the agent merely attaches over `--cdp 9222` to the ready, logged-in
tab. The substrate is a Chrome session attached over CDP; how to launch it, the
liveness check and the honest limit on anti-bot detection are in
`references/cdp-session-substrate.md`.

Portable, with no Python and no scripts: the whole tool is the `agent-browser` CLI
plus the agent's reasoning. The syntax of the primitives is grounded in the help of
the installed CLI (v0.26.0) in `references/agent-browser-primitives.md`; that file
is the source of truth, so read it before the first command.

## What must be in place before you start (pre-flight: check it, do not do it for the human)

1. Chrome is running with `--remote-debugging-port=9222` and `--user-data-dir` (the
   flag is mandatory), and the human is logged in if the form sits behind a login.
   Liveness check: `curl -s http://localhost:9222/json/version` returned the
   browser's JSON.
2. `agent-browser` is installed; the attach is checked with a single command:
   `timeout 15 agent-browser --cdp 9222 snapshot -i` returned a tree with `@eN` refs.
3. The input is at hand: a memo (prose) OR structured JSON/YAML with
   "field name → value" pairs. A demo form for a memo is chosen so that its fields
   follow from the memo (title/abstract/keywords/sources); see the Appendix B rule
   in `references/mapping-contract.md`.

If any item is not met, stop and tell the human what to start; do not start the
browser and do not log in on their behalf.

## Invariant: `--cdp 9222` on EVERY command

Without `--cdp 9222`, an `agent-browser` command launches **a separate, detectable
Chromium with no logins**, not our logged-in tab. The flag is mandatory on every
command. Wrap every command in a hard timeout so that a hung request does not block
the work: `timeout 15 agent-browser --cdp 9222 <cmd>`.

## The working loop

The form is filled field by field in the loop **snapshot → mapping → input →
re-snapshot/read-back → (after all fields) human gate → submit → submission log**.
The key property of the loop: `@eN` refs go stale after any change to the page, and
a successful `fill` does NOT mean the value really landed, so the snapshot is taken
again before every step and the value is re-read from the live DOM.

**0. Open the form.** `agent-browser --cdp 9222 open <url>` in the tab that is
already logged in. Wait until it is ready: `wait <anchor selector>` or
`wait --load networkidle` (see the primitives), wrapped in `timeout`.

**1. Discover: the field map.** `snapshot -i` returns the a11y tree: every field
shows its role (`textbox`, `checkbox`, `radio`, `combobox`…) and its accessible name
(usually its label). These are the field addresses, by role and name, not by CSS.

**2. Map the input onto the fields.** Match the input keys to the fields by the
contract in `references/mapping-contract.md`: accessible name → normalisation (trim,
lowercase) → exact match with the input key. From a prose memo the agent extracts
the values itself (LLM mapping). **Ambiguity or duplicate accessible names → human
gate** (ask the human which field is meant); do NOT guess.

**3. Input by field type.** Match by role and name natively, without resolving to
CSS by hand:
- text: `find label "<Name>" fill "<value>"` (by label) or `fill @eN "<value>"`
  (by a ref from the snapshot). Both paths were tested on a live browser. Do NOT use
  `find role textbox --name "<Name>"` for text fields: an input takes its accessible
  name from `<label>`/`aria-label`, and in practice this locator does not find it
  ("Element not found"), even though the snapshot shows the field as
  `textbox "<Name>"`; `find label` and `@eN` are the reliable ones;
- checkbox: `find label "<Name>" check` / `check @eN` (idempotent); radio: `click @eN`;
- drop-down: `select @eN "<value>"` or `select "<css>" "<value>"`, using the
  `select` command and NOT `find` (`find` has no `select` action);
- button: `find role button click --name "<text>"` (a button takes its name from its
  text, so this works);
- a custom/React field where a plain `fill` does not "stick": the ladder
  `fill` → `type` (real key presses) → `eval` with dispatchEvent; details in
  `references/failure-modes.md`.

**4. Read-back verify: re-read from the live DOM.** A successful `fill` is NOT
proof. Re-run `snapshot -i` (which refreshes the `@eN` refs) and read the value:
- native `input`/`textarea`/`select`: `get value @eN`, the live DOM value;
- React/custom/contenteditable, where `.value` is empty or lies: `eval` is
  **mandatory** (for example `eval 'document.querySelector(...)?.value'`, or reading
  `.textContent`/`aria-checked`). A re-snapshot as the ONLY source is a false green;
  the eval fallback for custom fields is mandatory.

If the value does not match what was intended, fix it with the input ladder from
step 3 and read it again; do not move on to the next field with an unconfirmed one.

**5. Multi-step forms: a checkpoint after every step.** After every page or step,
record what has been filled. Wait for the next step with `wait`. On failure, retry
**from the last checkpoint**, not from scratch.

**6. Human gate BEFORE submit (mandatory).** Collect a summary of the values of all
fields (field → what was entered, taken from the read-back of step 4) plus a
`screenshot`, show it to the human and **STOP**. Submit only after an explicit
"yes". Silence, "probably", "ok I think" are not a "yes"; ask again. A CAPTCHA at
this step → stop and hand over to the human (`references/failure-modes.md`).

**7. Submit + submission log (idempotency).** After the "yes", click the submit
button once (`find role button --name "<Submit>" click`). Immediately write the fact
of submission to the log (form URL, time, submitted values). Check the confirmation
of receipt with `get url` or `wait --text "<thank-you text>"`. On any retry, **do
not click submit again blindly**; check the log, and repeat only if the log and the
page both show unambiguously that the submission did not go through.

## Failure modes

agent-browser does not fix these out of the box; their handling is described in
`references/failure-modes.md`: a stale `@eN`; React onChange not triggered by a plain
`fill`; duplicate accessible names; a false-green read-back; CAPTCHA and anti-bot on
submit → stop and hand over to the human. **Fallback when things break live:**
manual mode, in which the human fills the form themselves and the agent prompts
field by field (role + name + what to enter), plus the diagnostic checks for the
CDP session.

## Honest limits

- An arbitrary university course syllabus does NOT map field-to-field from an
  argumentative memo automatically; this is a limitation, not a bug (Appendix B,
  `references/mapping-contract.md`).
- A real Chrome profile removes some identity signals, but CDP leaves detectable
  traces (`Runtime.enable`, `cdc_`); Cloudflare and DataDome see them. Do not patch,
  stop (`references/cdp-session-substrate.md`).

## Reply in the language of the user's request

Write summaries, questions to the human and explanations in the language of the
user's request. Enter values into the fields exactly as they appear in the input
(names, numbers, links as they are).
