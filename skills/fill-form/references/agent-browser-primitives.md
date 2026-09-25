# agent-browser — primitives for filling a form (grounded in the CLI help)

The source of truth is the installed CLI, **v0.26.0**. The syntax below is copied
from `agent-browser --help` and the subcommand help (`agent-browser <cmd> --help`).
If your version answers differently, trust the help of your version and
`agent-browser skills get core --full`, not this file.

**Invariant:** `--cdp 9222` on EVERY command (attach to the running Chrome) and a
hard timeout around every call:

```bash
timeout 15 agent-browser --cdp 9222 snapshot -i
```

## Discrepancy with an older handoff (important)

An early handoff claimed that the CLI has NO `get value`, `wait` and `type`
commands and that they must not be used. **According to the v0.26.0 help, all three
exist.** The ground truth is the CLI help, so this skill uses them. Their real
syntax is below. The false bans are lifted; only the substantive caution around
read-back is kept (see `get value` below and `failure-modes.md`).

## Discovering fields

| Task | Command | Note |
|---|---|---|
| A11y tree with `@eN` refs | `snapshot -i` | `-i` means interactive only; each field shows its role and accessible name |
| The same, compact / by depth | `snapshot -i -c`, `snapshot -i -d <n>` | drop empty nodes / limit the depth |
| Snapshot of part of the page | `snapshot -i -s "<css>"` | scope by CSS if the form is a fragment |
| Screenshot (for the human gate) | `screenshot [path]`; `screenshot --annotate` | `--annotate` draws `[N]` labels = `@eN` refs |

The `@eN` refs from a snapshot are valid **as long as the page has not changed**.
Any input, click, navigation or tab switch → the refs are stale → run `snapshot -i`
again before the next step.

An iframe (a common case: an embedded Google Form, a payment frame) is **inlined
automatically** into the snapshot: refs to fields inside it work transparently. For
deep nesting or focus, `frame @eN` switches the context and `frame main` returns. A
cross-origin iframe closed to the a11y tree is silently skipped; then use `eval` in
its origin, or stop.

## Matching by role and accessible name (not by CSS)

`find` locates an element by a semantic locator and acts on it at once; this is
role-and-name mapping natively, without CSS selectors:

```bash
agent-browser --cdp 9222 find label "E-mail" fill "user@example.com"    # text by label: reliable
agent-browser --cdp 9222 fill @e5 "user@example.com"                    # text by a ref from the snapshot
agent-browser --cdp 9222 find role button click --name "Submit"         # button by its text: reliable
```

- Locators: `label`, `role <role>` (+ `--name <accessible-name>`, `--exact`),
  `placeholder`, `alt`, `title`, `testid`, `first/last/nth`.
- Actions: `click` (the default), `fill`, `type`, `hover`, `focus`, `check`,
  `uncheck`. `find` has NO `select` action; a drop-down is handled only by the
  `select <sel> "<value>"` command.
- The advantage of `find` over `@eN`: it re-resolves the element on every call, so
  it is more robust against stale refs. `@eN` is faster for a chain of actions on one
  snapshot, but needs a re-snapshot after every change.

> **Empirical (tested on v0.26.0 + Chrome 151, live browser).** For text fields, go
> by `find label "<label>"` or by an `@eN` ref from the snapshot; both are reliable.
> In practice `find role textbox --name "<name>"` does NOT find inputs whose
> accessible name comes from `<label>`/`aria-label` (it returns "Element not found"),
> even though the snapshot shows them as `textbox "<name>"`. For buttons,
> `find role button --name "<text>"` works (the name comes from the text). Checkbox:
> `find label "<name>" check` or `check @eN`. Drop-down: the `select <sel> "<value>"`
> command.

Roles you meet in forms: `textbox`, `checkbox`, `radio`, `combobox`, `listbox`,
`button`, `spinbutton` (numeric input), `searchbox`.

## Entering values

| Field type | Command | When |
|---|---|---|
| Text (clear and enter) | `fill <sel> "<text>"` | the main path for input/textarea; **clears** the field before typing |
| Text with real key presses | `type <sel> "<text>"` | types WITHOUT clearing (appends); autocomplete, masks, suggestions that need character-by-character input |
| By focus, real keystrokes | `focus <sel>` + `keyboard type "<text>"` | when a component intercepts events: real key presses |
| By focus, without key events | `focus <sel>` + `keyboard inserttext "<text>"` | inserting text while bypassing key events |
| Checkbox | `check <sel>` / `uncheck <sel>` | idempotent: a no-op if already in the desired state |
| Drop-down | `select <sel> "<value>" [<value>...]` | by the value of the `<option>` |
| File upload | `upload <sel> <file> [<file>...]` | file input |
| Press a key | `press <key>` | e.g. `Enter`, `Tab`, `Control+a` |

`<sel>` is a CSS selector, an XPath or an `@eN` ref. The ladder for React fields
where `fill` does not "stick": `fill` → `type` → `eval` with dispatchEvent
(`failure-modes.md`).

## Read-back verify (re-reading the value)

| Task | Command | Limit |
|---|---|---|
| Value of a native field | `get value <sel>` | the live DOM value of input/textarea/select; **the main read-back** |
| Attribute / state | `get attr <sel> <name>` | e.g. `aria-checked`, `checked` |
| Checkbox state | `is checked <sel>` | true/false |
| Element text | `get text <sel>` | for non-inputs (labels, nearby contenteditable) |
| Custom/React, where `.value` lies | `eval '<js>'` | **mandatory fallback**: `eval "document.querySelector('...')?.value"` or `.textContent` |
| What changed after input | `diff snapshot` | compares the current snapshot with the previous one: shows whether the value landed and whether the rest of the form shifted |

Why `get value` alone (or a re-snapshot alone) is not enough on custom fields:
`get value` reads the DOM `.value` property. For a native input that is the truth.
But for a React-controlled or contenteditable widget, `.value` may be empty or out of
sync with what will actually go out on submit, and a re-snapshot shows only the
accessible name. So for custom fields the read-back must go through `eval` on the
specific property or state of the widget. Relying on a SINGLE weak read = a false
green.

`eval` can read stdin and base64, which is handy for multi-line JS without escaping:

```bash
echo "document.querySelector('#bio')?.value" | agent-browser --cdp 9222 eval --stdin
```

## Waiting (wait exists, so no snapshot loop is needed)

```bash
timeout 20 agent-browser --cdp 9222 wait "@e5"                 # an element appears
timeout 20 agent-browser --cdp 9222 wait --text "Thank you"    # text on the page (substring)
timeout 20 agent-browser --cdp 9222 wait --load networkidle    # the network goes quiet
timeout 20 agent-browser --cdp 9222 wait --url "**/success"    # the URL changes to a pattern
timeout 5  agent-browser --cdp 9222 wait 2000                  # a fixed pause, ms
```

Wrap `wait` in a shell `timeout` as a hard ceiling: `wait` waits for the condition,
and `timeout` keeps it from hanging forever. A fallback if `wait` on a selector
misbehaves: a short loop of repeated `snapshot -i` calls that checks whether the
element has appeared.

## Navigation, tabs, state

| Task | Command |
|---|---|
| Open a URL | `open <url>` (aliases `goto`, `navigate`) |
| Current URL / title | `get url` / `get title` |
| Reload / back / forward | `reload` / `back` / `forward` |
| Tabs (shared login) | `tab new --label <label> <url>`, `tab <label>`, `tab list`, `tab close <id>` |
| Console / page errors | `console`, `errors` |

Several tabs in one Chrome go through `tab` (shared cookies and login), NOT through
`--session` (in v0.26 that is a separate isolated browser). Only one tab is active;
refs belong to the tab captured at snapshot time, so after `tab <...>` run
`snapshot -i` again.

## What to really avoid

- `--session <name> connect 9222` is a bug: `connect` creates an empty
  `about:blank` tab instead of attaching to the existing ones (tested on v0.22.3,
  same behaviour in v0.26). Connect only with `--cdp 9222` on every command.
- A bare `open <url>` without `--cdp` launches a separate, detectable Chromium with
  no logins.
