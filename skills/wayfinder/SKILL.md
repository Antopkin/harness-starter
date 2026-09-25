---
name: wayfinder
description: Chart work too big for one session as a map of decision tickets under plans/wayfinder, then resolve one ticket per session until the way to the destination is clear. "/wayfinder" with a loose idea charts a new map; with an effort name it works an existing one.
argument-hint: "<idea> | <effort>"
disable-model-invocation: true
---

# Wayfinder

A loose idea has arrived, too big for one agent session and wrapped in fog: the way from here to the **destination** is not visible yet. Wayfinding finds that way instead of charging at the destination. This skill charts it as a **map** of **decision tickets** (questions whose resolution is a decision, not slices of a build) and works them one at a time until the route is clear. Answer the user in the language of the user's request; section headings and frontmatter keys stay in English, as in the templates.

This skill is user-invoked: you start it yourself with `/wayfinder`. The `disable-model-invocation` flag that stops the agent from starting it on its own is honoured only by Claude Code; OpenCode and Codex may still invoke it automatically.

## Plan, don't do

Wayfinder is planning. Each ticket resolves a decision, and the map is done when nothing is left to decide before someone goes and does the thing. The pull to just do the work usually means you have reached the edge of the map and it is time to hand off. An effort may override this in its Notes and carry execution into the map; absent that, produce decisions, not deliverables.

## Where the map lives

Each effort is one directory, `plans/wayfinder/<effort>/` at the root of the repository, where `<effort>` is a short kebab-case slug. It holds `MAP.md` (from `templates/MAP.md`) and one file per ticket, `T-NN-<slug>.md` (from `templates/ticket.md`). Charting refuses a directory that already exists: say so, and suggest the user either work it with `/wayfinder <effort>` or pick another name. Never overwrite a map.

The map is nothing but plain files, so edit one effort from one machine at a time. Two machines working the same effort would fight over the same files, and a claim made on one machine is not seen on the other until the files are copied or pulled across. If you switch machines, bring the map over before the next session starts.

**The map is an index, not a store.** MAP.md holds the sections Destination, Notes, Decisions so far, Not yet specified and Out of scope. Decisions so far lists one line per closed ticket and points at it; a decision lives in exactly one place, its ticket, and the map only gists it. Open tickets are not listed on the map: they are found with `frontier.py`.

**Refer by name.** In everything the user reads, name a ticket by its title, with the id in parentheses if useful: "Pick the queue backend (T-04)", never a bare wall of `T-04, T-05, T-06`.

## Tickets

A ticket is a question sized to one session. Its frontmatter carries `id`, `title`, `type` (research, grill, spike or task), `mode` (afk or hitl), `status` (open, claimed, closed or out-of-scope), `blocked_by` and `claimed_by`. `blocked_by` takes a flow list `[T-01, T-02]`, a block list of `- T-01` lines, a single id, or nothing. The body is `## Question`, and `## Answer` is added when the ticket closes; assets made while resolving it (a spike, a checklist result) are linked from the answer, not pasted in.

A session **claims** a ticket first, before any work: it sets `status: claimed` and fills `claimed_by`, so a concurrent session skips it. A ticket is unblocked when every id in its `blocked_by` is closed or out-of-scope, and the **frontier** is the open, unblocked tickets.

Run the skill's own `scripts/frontier.py <effort_dir>` (standard library only) whenever you need the frontier, and after every change to the tickets:

| Exit | Meaning | Output |
|---|---|---|
| 0 | the frontier is not empty | the frontier ids, sorted, one per line |
| 0 | nothing on stdout: no open or claimed ticket remains | "done" on stderr |
| 2 | the directory has no `MAP.md` or no `T-*.md` at all (most likely a wrong directory, never a finished effort); or a `T-*.md` without valid frontmatter, an unknown `blocked_by` id, a duplicate id, a value outside its enum, or a cycle | the problem, and any cycle by name, on stderr |
| 3 | the frontier is empty while open or claimed tickets remain | "stuck" |

`--tree` prints the dependency tree, each ticket under the tickets that block it. On exit 2, fix the tickets before anything else. On exit 3, show the user the claimed tickets; a claim left by a session that died is released only with the user's word.

## Ticket types

Every ticket is **hitl** (worked with the user, who speaks for themselves) or **afk** (driven by the agent alone). A hitl ticket resolves only through that live exchange; an agent that answers its own questions has broken it.

- **research** (afk): a fact outside the working directory that a decision waits on, from documentation, a third-party API or a knowledge base. Claim it as you fire it, with `status: claimed` and `claimed_by: background research <date> <machine>`, so a new session does not see it on the frontier and fire it twice. Fire it as a background agent per `contexts/orchestration-matrix.md`, agent type `reader` for local sources or `web-reader` for the web, with the ticket's question and the Destination line as its prompt. Output language English, Length cap 800 words, Return shape {answer, sources[], confidence}. When the result arrives, write the answer and its sources into the ticket's `## Answer`, close it and add its pointer; a low-confidence answer stays open with a note on what is missing.
- **grill** (hitl): the default. Run the grill-me rounds inline with the user, following the round format in `../grill-me/SKILL.md`: one round of questions, each with your recommended answer, then the next round from the frontier of what is still open.
- **spike** (hitl): raise the fidelity of the discussion with a cheap, rough artefact to react to, when the key question is how something should look or behave. Build it as a throwaway in `$TMPDIR` or in a git worktree, never in the user's working tree. `$TMPDIR` does not last, so the answer records what the spike showed, not only its path.
- **task** (afk or hitl): work that must happen before a decision can be made, such as signing up for a service so its API can be judged or moving data so its shape can be seen. The agent does it when it can; otherwise it hands the user a precise checklist. For user-only steps (accounts, tokens, keys, payments) tell the user to run `/wizard <step>`, and never ask for or accept a secret in chat. The answer records what was done and the facts later tickets need, such as where a credential is stored, never its value.

## Fog of war

The map is deliberately incomplete. Beyond the live tickets lies the fog: decisions you can tell are coming but cannot yet pin down because they hang on open questions. Not yet specified is where that dim view is written, as loosely or as fully as the view allows. The test for fog or ticket is whether you can state the question precisely now, not whether you can answer it now: a sharp question becomes a ticket even when it is blocked, and a vague one stays fog. Do not pre-slice fog into ticket-sized pieces; one patch may graduate into several tickets, or none.

## Out of scope

The destination fixes the scope, so work beyond it is not fog. When a ticket turns out to sit past the destination, set its status to `out-of-scope` and add one line to Out of scope with the gist and the reason. It stays out of Decisions so far, which records the route actually walked, and it never graduates: it returns only if the destination is redrawn, as a fresh effort.

## Chart a map: `/wayfinder <idea>`

1. **Name the destination.** Run a grill round with the user to pin down what this map finds its way to: a spec, a decision or a change. Settle the effort slug with it, and stop if the directory already exists.
2. **Map the frontier.** Grill again, breadth-first: fan out across the whole space rather than deep on one thread, surfacing the open decisions and the first steps takeable now. If this surfaces no fog, stop and say the work "fits one plan"; suggest plan mode and create nothing.
3. **Create the map** from `templates/MAP.md`: Destination and Notes filled in, Decisions so far empty, the fog sketched into Not yet specified.
4. **Create the tickets** you can specify now, T-01 upward, all with `blocked_by` empty. Then wire `blocked_by` in a second pass, once every id exists, and run `frontier.py` until it exits 0.
5. **Fire the research tickets** in the background, claiming each as you fire it, as described under Ticket types.
6. **Stop.** Charting resolves nothing by hand. Before the handoff, wait until every background answer is written into its ticket; if you cannot wait, release each research claim you made (back to `status: open`, `claimed_by` emptied) so the next session can fire it again. Then hand off with the line "/wayfinder <effort>".

## Work the map: `/wayfinder <effort>`

1. **Load MAP.md only**, the low-resolution view, not every ticket body. Run `frontier.py`.
2. **Choose and claim.** If the user named a ticket, use it; otherwise take the first frontier id. Claim it before any work.
3. **Resolve it** by its type. Zoom as needed: read the full body of any related or closed ticket on demand, and consult whatever the Notes section names.
4. **Record.** Write `## Answer`, set `status: closed`, and add one line to Decisions so far: `- <title> (T-NN): <gist>`.
5. **Update the map.** Add newly surfaced tickets (create, then wire). Graduate fog the answer has made specifiable, deleting each graduated patch from Not yet specified so it lives only as its ticket. Rule out of scope what now sits past the destination, and update or retire tickets the decision has invalidated. Run `frontier.py` again.

Resolve one ticket per session. The exception is research: frontier research tickets may be fired in the background alongside the ticket you work, each claimed as it is fired. Before the session hands off, wait until their answers are written, or release the claims of those still out, as in step 6 of charting. The user may run several sessions on unblocked tickets in parallel on this machine, so re-read a ticket before writing to it.

## Exit and handoff

When `frontier.py` reports no open or claimed tickets and Not yet specified is empty, the way is clear: enter plan mode and write the plan with MAP.md listed under Context to load. Until then, every handoff says "/wayfinder <effort>" and never gives the path to MAP.md, so the next session loads the map through this skill. Facts about the effort stay in its map and tickets; only facts that matter across efforts go to memory in `memory/`.

Adapted from mattpocock/skills@c55ee46 engineering/wayfinder (MIT).
