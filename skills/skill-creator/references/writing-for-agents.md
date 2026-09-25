# Writing for agents

Read this when you write or revise anything an agent consumes: a skill's description or body, a reference file behind a pointer, a line in `CLAUDE.md` or `AGENTS.md`. The packaging differs, but the writing does not. The same levers make each of them predictable, because the goal is for the agent to take the same _process_ on every run, not to produce the same output.

The examples below come from this kit's own `AGENTS.md`, whose "When to read what" table maps a situation to a context file. Its rows look like this:

| When you are… | Read |
| --- | --- |
| in plan mode, writing or auditing a plan, picking up a plan file, or closing a long autonomous run | `contexts/workflow-orchestration.md` |
| choosing subagents, sizing a wave, assigning models to phases, or opening a bug investigation | `contexts/orchestration-matrix.md` |
| about to commit, branch, open or merge a pull request, or work in a worktree | `contexts/git-workflow.md` |
| editing `.claude/settings.json` or the OpenCode guard plugin, debugging a guard, or blocked by one | `contexts/hooks-overview.md` |
| searching the web, reading URLs or papers, or looking up library docs | `contexts/research-routing.md` |
| writing a deliverable in English or Russian, or checking the quality of a text | `contexts/writing-quality.md` |

The last section, "Skill mechanics", covers what changes when the document is a skill: frontmatter, the invocation choice, and router skills.

## Context pointers

A **context pointer** is a reference held in the agent's context that names some material outside it and encodes the condition for reaching it. A skill's description is one. Every row of the table above is another: the left cell is the condition, the right cell names the material. The pointer's _wording_, not its target, decides when the agent reaches the material and how reliably. A must-have target behind a weakly worded pointer is a variance bug. Sharpen the wording first, and inline the material only if sharpening fails.

A pointer does two jobs. It says what the material is, and it lists the **branches** that should trigger reaching it (a branch is a distinct case the document handles, so different runs take different paths through it). Every word of an always-loaded pointer is paid for on every turn, so it earns even harder pruning than the body:

- **Put the leading word first.** The pointer is where it does its triggering work. The hooks row opens on _editing `.claude/settings.json`_ and names _guard_ right after; an agent that is about to touch the guards meets its own word.
- **One trigger per branch.** Synonyms that rename one branch are that branch written twice, so collapse them and keep only the branches that really differ. The hooks row has three: editing the configuration, debugging a guard, being blocked by one. Adding "changing guard config" or "guard troubleshooting" would repeat branches it already has.
- **Cut identity the body already carries.** The row does not explain what a guard is; the context file does.

## The two loads

Every document and pointer you add spends one of two budgets.

**Context load** is what always-loaded material costs the agent's window: a `CLAUDE.md` line, a skill description, anything that sits in context every turn and spends tokens and attention whether or not it fires. Every row of the table is context load; the files it names are not.

**Cognitive load** is the cost to the human: knowing which documents exist and when to reach for each. The human is the index. This is not a cost to drive to zero, because it is the price of human agency. Spend it where human judgement matters and remove it where it does not.

Material reached only through a pointer escapes context load at the price of the pointer's own line. Material with no pointer at all rides entirely on cognitive load: a context file you consult only a few times a month, such as the orchestration matrix, stays useful only because its row exists, and without the row only your memory would ever open it.

## Information hierarchy

A document is built from two kinds of content: **steps** (the ordered actions the agent performs) and **reference** (definitions, rules and facts consulted on demand). They mix freely. A recipe is all steps, a review's rulebook is all reference, and most skills have both. The core decision is where each piece sits on the **information hierarchy**, a ladder ranked by how immediately the agent needs the material:

1. An **in-file step** is the primary tier: what the agent does, in order.
2. **In-file reference** is consulted on demand. It is often a legitimately flat set of peers (every rule of a review on one rung), and that is a fine arrangement, not a smell.
3. **Disclosed reference** sits in a separate file, reached by a context pointer and loaded only when the pointer fires. It ranges from a sibling file in the same folder to external reference that lives anywhere and that any document can point at. The table is a whole column of disclosed reference: `contexts/git-workflow.md` loads only when a commit, branch, PR or worktree is on the table.

Push too little down and the top bloats. Push too much and you hide material the agent actually needs. That tension is the whole decision.

**Progressive disclosure** is the move down the ladder, out of the main file and behind a pointer, so the top stays legible. It is not mainly a token saving; it is how the hierarchy is protected. Branching is the cleanest test: inline what every branch needs, and put behind a pointer what only some branches reach. Git rules are needed only on the branch where a commit happens, so they live in their own file, while the guardrails every session needs stay in `AGENTS.md` itself. When a document has steps, in-file reference that should have been disclosed buries them, and whether the agent attends to a step becomes a coin flip. Disclosure is a variance lever, not just a legibility one.

**Co-location** is the companion inside a file. The ladder decides _how far down_ a piece sits; co-location decides _what sits beside it_. Keep a concept's definition, rules and caveats under one heading instead of scattering them, so that reading one part brings its neighbours along. The test: the document should read like documentation written for the agent. (This is different from duplication, which repeats one meaning in two places; scattering breaks one meaning into many.)

**Sprawl** is the failure mode here: a document that is simply too long, even when every line is live and unique. Attention thins across the excess, and every extra line is one more to keep relevant. The cure is the ladder: disclose reference behind pointers, and split by branch or sequence so each path carries only what it needs. In this skill, SKILL.md stays under about 150 lines and the procedures live in `references/`.

## Steps and completion criteria

Every step ends on a **completion criterion**, the condition that tells the agent the work is done. Two properties make it a lever.

**Clarity** asks whether the agent can tell done from not done. A vague bound ("understanding reached") invites **premature completion**: ending the step before it is really done, because attention slips toward _being done_. The visible steps still ahead (the **post-completion steps**) supply the pull, and the criterion's clarity is the resistance. Defend in order. Sharpen the bound first, since that is local and cheap. Only if the bound is irreducibly fuzzy _and_ you observe the rush, hide the later steps by splitting the sequence. Hiding works only across a real context boundary, such as a hand-off or a subagent dispatch; an inline call leaves the later steps in context and clears nothing.

**Demand** is how much the criterion requires. "Every modified model accounted for" forces thorough work where "produce a change list" does not. Demand drives **legwork**, the digging the agent does inside the work, which lives in the wording rather than as a step of its own. It is not tied to steps either: "every rule applied" binds a body of flat reference just as "every step done" binds a sequence, which is how an all-reference document still carries a bar for exhaustiveness.

The strongest criteria are both checkable and exhaustive.

## When to split

Splitting one document into two spends one of the two loads, so split only when the cut earns it.

- **By sequence.** Split a run of steps when the post-completion steps tempt the agent to rush the one in front of it. Keeping them out of view drives more legwork on the current task. The reverse also holds: merging sequences exposes each step to the ones that follow and invites premature completion.
- **By invocation**, for skills only. See "Splitting by invocation" under Skill mechanics.
- **By branch**, as the table does: each row is a branch, and each file carries only what its branch needs. The writing-quality file costs nothing in a session that never writes a deliverable.

## Leading words

A **leading word** is a compact concept already present in the model's pretraining, which the agent thinks with while it runs the document (_lesson_, _fog of war_, _tracer bullets_). Repeated as a token, never as a sentence, it accumulates a distributed definition and anchors a whole region of behaviour in the fewest tokens, because it recruits priors the model already holds. Coining your own word works if you define it clearly, but a made-up word recruits no priors, so you pay in definition tokens for what a pretrained word gives free. Reach for an existing word first.

It anchors twice. In the body it anchors _execution_: the agent reaches for the same behaviour every time the word appears, and inside flat reference it focuses attention on a class of thing to look for. In a pointer it anchors _invocation_: when the same word lives in your prompts, your docs and your codebase, the agent links that shared language to the material and reaches it more reliably. The table leans on this. _Commit_, _worktree_, _plan mode_ and _subagents_ are the words you actually type, so the rows fire on them.

Hunt for chances to refactor with leading words: a triad spelled out at three sites, or a pointer spending a sentence to gesture at one idea. Each is a passage waiting to collapse into a single token.

- "fast, deterministic, low-overhead" becomes _tight_ (a _tight_ loop).
- "a loop you believe in" becomes _red_, which turns a fuzzy gate into a binary observable state: the loop goes _red_ on the bug, or it doesn't.

You win twice: fewer tokens, and a sharper hook for the agent to hang its thinking on. Assume every document carries restatements that leading words can retire, and go find them.

**Negation** is the failure mode beside this lever. Steering by prohibition drags the forbidden behaviour into context and makes it _more_ available, not less. Tell someone not to think of an elephant and the elephant is all there is: the negation is a weak modifier that the strongly activated concept overruns, so the ban half reads as an instruction to do the thing. Prompt the **positive** instead, and state the target behaviour ("write one-line comments") so the banned one is never spoken. A prohibition earns its place only as a hard guardrail you cannot phrase positively, and even then pair it with the positive target so attention lands on what to do.

## Pruning

Keep each meaning in a **single source of truth**, one authoritative place, so that changing the behaviour is a one-place edit. **Duplication** (the same meaning in more than one place) costs maintenance and tokens, and it inflates a meaning's prominence on the ladder beyond its real rank. It is the accidental inverse of a leading word, which repeats a token on purpose but never the meaning. If the git rules appeared both in `AGENTS.md` and in `contexts/git-workflow.md`, one copy would drift.

The **environment** is a source of truth too: `package.json` scripts, config files, the directory layout, `--help` output. A document that restates it is a **cache**, a copy of a lookup that earns its load only when the lookup is expensive. Cache what the agent cannot find by looking: the unwritten convention, the reason behind a choice, the gotcha no config confesses. Leave one-file, one-command lookups to the environment, where they cannot go stale. `contexts/hooks-overview.md` earns its place by explaining why the guards exist and how to get unblocked; a copy of the hook list from `settings.json` would only be a cache waiting to go stale.

Check every line for **relevance**: does it still bear on what the document does? A line loses relevance either because it never bore on the task (mere exposition, or a branch that should have been disclosed) or because it went stale as the behaviour or the world changed. Shorter documents are easier to keep relevant. Without a pruning discipline the default fate is **sediment**: stale layers that settle because adding feels safe and removing feels risky, until you have to core down through them to find what is still live. A table row whose file has been deleted or renamed is sediment of the most expensive kind, because it costs context load on every turn and fires into nothing.

Hunt **no-ops** sentence by sentence. An instruction the model already follows by default pays load to say nothing. The test (does it change behaviour compared with the default?) is relative to the model, not to the reader: two people who disagree about a no-op disagree about the default, and they settle it by running the document, not by debate. When a sentence fails, delete the whole sentence instead of trimming words from it. The test also grades leading words: a word too weak to beat the default (_be thorough_ when the agent is already fairly thorough) is a no-op, and the fix is a stronger word (_relentless_), not a different technique.

## Skill mechanics

This is the skill-specific branch. Everything above applies to a skill unchanged; this section adds the frontmatter, the invocation choice and router skills. `scripts/quick_validate.py` accepts the frontmatter keys `name`, `description`, `license`, `allowed-tools`, `metadata`, `compatibility`, `argument-hint` and `disable-model-invocation`.

### Invocation

There are two choices, and they trade the two loads.

A **model-invoked** skill keeps a `description`, so the agent can fire it on its own and other skills can reach it. The owner can still type its name: model invocation always _includes_ the user's reach, and a description only ever adds discovery by the agent, never removes the human's. The description is the skill's top-level context pointer, and it stays loaded at all times, so it is permanent context load paid for discoverability. A model-invoked skill whose content is all reference is also a home for shared reference: other skills can invoke it, so reference that several skills need lives in one place. Mechanics: leave `disable-model-invocation` out, and write a model-facing description that carries the trigger branches. The pointer rules above apply in full: one trigger per branch, the leading word first, synonyms cut.

A **user-invoked** skill takes the description out of the agent's reach: only the human typing its name can invoke it, and no other skill can. It costs no context load, but it spends cognitive load, because the owner is the index that has to remember it exists. Mechanics: set `disable-model-invocation: true`, and write the `description` for a human, as a one-line summary without trigger lists. Only Claude Code honours this key; OpenCode and Codex ignore it and may still invoke the skill on their own, so on those tools the description is still read by the model. `argument-hint` shows the owner what to type after the name. Because nothing but the owner can start a user-invoked skill, other skills and documents may tell the owner to run it, never the model.

Choose model invocation only when the agent has to reach the skill on its own, or another skill has to. If it only ever fires by hand, make it user-invoked and pay no context load.

Shared reference that two user-invoked skills both need can live in neither of them: without a model-facing description, neither can fire the other. Put it in a plain file outside the skill system, as external reference any skill can point at. The table's context files are exactly that kind of file.

### Splitting by invocation

This is the invocation cut of splitting; the sequence cut is in "When to split" above. Split off a model-invoked skill when a distinct leading word should trigger it on its own (a word you actually use in your prompts), or when another skill has to reach it. You pay context load for the new always-loaded description, so that independent reach has to be worth it.

### Router skills

When user-invoked skills pile up past what the owner can remember, the cure for that cognitive load is a **router skill**: one user-invoked skill that names the others and says when to reach for each, so the owner has one name to remember instead of many. It can only suggest which one to run, never fire them, because user-invoked skills carry a description the model does not act on, and nothing but the owner can reach them. The "When to read what" table plays the same role for context files, with one difference: its rows are always loaded, so the agent can follow them itself.

Adapted from mattpocock/skills@c55ee46 productivity/writing-for-agents (MIT).
