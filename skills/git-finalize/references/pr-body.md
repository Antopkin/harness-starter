# PR body: template and guide

Step 5 of `git-finalize` writes this body with the Write tool to
`$TMPDIR/pr-body-<branch>.md` and hands the file to the host: gh reads it with
`--body-file`, tea receives it as `--description "$(cat <file>)"`. Skip preambles,
keep the prose short, and use the project's own domain terms (from `CONTEXT.md` when
the repository has one).

```markdown
## What changed

<the smallest visual that makes the change clear, next to one or two lines of text>

## Evidence

- **Before:** <failing test run, output or screenshot>
  **After:** <passing test run, output or screenshot>
- **Test output:** <the command that ran and its result>
- **Test plan:**
  - [ ] <a step a reviewer can repeat>

## Merge risk

**Reversible:** <yes, a two-way door | no, a one-way door>, <why, in one line>
**Blast radius:** <one word>, <who or what could be affected>
**Watch after merge:** <the signal, log line, dashboard or user path to check>
```

## What changed

Pick the smallest view that shows the point, and draw it yourself from what the
change does; do not paste hunks from the diff. One visual is usual, two is
sometimes right, and more than that buries the reader.

- **Pseudocode** for logic or an algorithm: the few lines of control flow that
  changed, stripped of syntax.
- **A call tree** for runtime flow: the calls that matter, indented by depth.
- **A shallow file tree** for a refactor or a new module: each entry with a short
  comment on what it now owns.
- **A diff sketch** when the surrounding shape already exists and the point is what
  moved: `+` and `-` lines over a call tree, a file tree, a component tree or a
  state flow, not over the literal source.
- **Mermaid** (a sequence or flow diagram) when the point is how parts talk to each
  other or how data moves between them.

Show a whole block only when most of it is new, or when leaving out the context
would hide who owns what or in which order things run. Keep only the calls, files,
states and boundaries a reviewer needs to judge the change.

## Evidence

Show that the change works, as a before and after. A screenshot is the strongest
evidence for a visual change when the environment can take one. For everything
else, execution is the evidence: the test that failed before and passes now, or
the console output that changed. Then list the test plan as a checklist a reviewer
can repeat.

## Merge risk

A two-way door can be walked back: a revert undoes it cheaply. A one-way door
cannot: a data migration, a deletion, a published interface or any other
hard-to-reverse decision. Say which one this is and why.

The blast radius is everything the change could reach if it is wrong: consumers of
an API, stored data, layout on other screens, other platforms. Name it in one word,
then say what to watch once it is merged so a problem shows up early.

Adapted from mattpocock/skills@c55ee46 in-progress/pr (MIT). Upstream credits the
"shape of the change" guidance to Dex Horthy's show-me skill from humanlayer/humanlayer.
