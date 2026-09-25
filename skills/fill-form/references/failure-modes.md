# Failure modes when filling a form

agent-browser does NOT fix these situations by itself out of the box; below is how
to recognise them and what to do. The general principle: do not move on from an
unconfirmed state, and do not guess where the cost of a mistake is a corrupted or
duplicated submission.

## 1. A stale `@eN` ref

**Symptom:** `Ref not found` / `Element not found: @eN`, or the action goes into the
wrong field.

**Cause:** refs are reassigned on every `snapshot` and go stale the moment the page
changes in any way: input, a click with navigation, submit, a dynamic re-render, a
dialog opening, a tab switch.

**What to do:** re-run `snapshot -i` before every step and work with fresh refs.
`find role/label ... <action>` is more robust against staleness: it re-resolves the
element on every call, so it never holds an outdated ref.

## 2. The field is in the DOM but not in the snapshot

**Symptom:** you know the field exists, but `snapshot -i` does not show it.

**Cause:** the field is outside the viewport or not rendered yet.

**What to do:** `scroll down <px>` and re-run `snapshot -i`; or `wait --text "<anchor>"`
/ `wait @eN` until it appears, then snapshot.

## 3. The value did not "stick" in the framework state (a rare case)

**The norm, not the exception:** under the hood `fill` (Playwright) already
dispatches a realistic `input` event. In a live test (Chrome + CDP + agent-browser
0.26.0, a form with a field whose JS state is updated only on `input`), a plain
`fill` was enough: `.value`, the internal state variable and the visible mirror were
all updated. **By default `fill` triggers onChange correctly**; do not reach for eval
in advance and do not scare anyone with it.

**Symptom (rare):** the read-back shows a mismatch: visually the text is entered,
but the value did not settle in the framework state (validation complains about an
empty field, or the old value goes out on submit). This happens with particular
frameworks, fields with `change`-on-blur and custom event handling; it is an EDGE
case.

**Diagnosis and remediation (run ONLY on a read-back mismatch):**
1. `fill @eN "<value>"`: the basic path, usually enough.
2. **read-back** (`get value @eN` for a native field; `eval` on the property for a
   custom one): it matches → done, do not dig further.
3. Mismatch → `focus @eN` + `type @eN "<value>"` or `keyboard type
   "<value>"`: real keystroke events. Read back again.
4. Still not → `focus @eN` + `keyboard inserttext "<value>"`. Read back again.
5. The last resort (an escape hatch, NOT the first choice) → `eval` with an explicit
   `dispatchEvent`:

   ```bash
   cat <<'EOF' | agent-browser --cdp 9222 eval --stdin
   const el = document.querySelector('#bio');
   const setter = Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype, 'value').set;
   setter.call(el, 'VALUE');
   el.dispatchEvent(new Event('input', { bubbles: true }));
   el.dispatchEvent(new Event('change', { bubbles: true }));
   EOF
   ```

A read-back after input is ALWAYS mandatory; it is exactly what catches this rare
case. Steps 3–5 of the ladder apply only when the read-back shows the value did not
settle. Do not move on to the next field until the value is confirmed.

## 4. Duplicate accessible names (repeated labels)

**Symptom:** two or more fields with the same accessible name (for example, two
"Phone" fields or empty labels), or `find role --name` matches the wrong field.

**Cause:** the form does not distinguish the fields by label; mapping by name is
ambiguous.

**What to do:** **human gate: ask the human** which field is which (by order, by a
neighbouring label, by placeholder); do NOT guess. This is a rule of the mapping
contract (`mapping-contract.md`): the human resolves ambiguity, not a heuristic.

## 5. A false-green read-back

**Symptom:** you consider the field filled, but the confirmation is weak: a
successful `fill` or a single re-snapshot.

**Cause:** a successful `fill` only means the command did not fail. A re-snapshot may
not show the value of a custom widget at all, and `get value` on a React-controlled
field may return a DOM `.value` that is out of sync with what will go out on submit.

**What to do:** read-back = a live read, not trust in the return code of `fill`.
Native input/textarea/select → `get value @eN`. Custom/React/contenteditable →
`eval` on the specific property or state of the widget (`.value`, `.textContent`,
`aria-checked`) is **mandatory**. A re-snapshot as the ONLY source = a false green.
`diff snapshot` helps you see what really changed after input.

## 6. An overlay intercepts the click

**Symptom:** `click` seems to go through, but nothing happens.

**Cause:** a modal window, a cookie banner or a tooltip over the form swallows the
click.

**What to do:** `snapshot -i`, find the close or accept button of the banner, click
it, re-run `snapshot -i`, continue.

## 7. CAPTCHA or anti-bot on submit

**Symptom:** before or at submission: a CAPTCHA, "confirm that you are human", a
Cloudflare/DataDome challenge.

**What to do:** **STOP and hand over to the human.** We do not bypass a CAPTCHA and
do not try to. A CDP session stays detectable by design (see
`cdp-session-substrate.md`); that is not fixed by a patch, only by stopping. The
human passes the check by hand in the same Chrome window and then lets you continue.

## Fallback when things break live: manual mode

If the loop does not work (the browser does not attach, fields are not found, time
is short), switch to **manual mode**: the human fills the form themselves, and the
agent prompts field by field with the role, the accessible name and exactly what to
enter (from the input mapping). The agent is the prompter here, not the executor.
Diagnose the chain (port, attach, stale daemons) with the checks in
`cdp-session-substrate.md`: make sure you started Chrome with
`--remote-debugging-port=9222` yourself, then run
`curl -s http://localhost:9222/json/version` and `agent-browser doctor`.
