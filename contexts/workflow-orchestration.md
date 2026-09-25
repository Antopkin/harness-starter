# Workflow orchestration

Read this file when a session enters plan mode, writes or audits a plan, picks up a plan file, or closes an autonomous or overnight run.

Plans live in the project's `plans/` folder (the starter's Claude Code settings point `plansDirectory` there), and a wayfinder map lives in `plans/wayfinder/<effort>/`.

## Plan execute pickup

When the first message of a session gives the path of a file in `plans/` together with a verb such as "execute" or "continue", it is an instruction to run a finished plan. Work through these steps in order.

1. Read the named file end to end.
2. Compare its last line with the integrity sentinel `_End of plan v<N>._`. If they differ, stop and say the plan is damaged or was never finalised.
3. Load everything listed under Context to load, together with the memory files named in Critical files. If any path is missing, stop: the plan leans on something this session will not have.
4. Follow Recommended approach and Subagent strategy as written and launch the waves they describe. Do not re-plan.
5. If Open questions is not empty, put those questions to the user before the first wave.

In Claude Code the usual route here is the approval menu after ExitPlanMode, where the user picks the option that clears the context and keeps the plan, so execution starts fresh. Pasting the path into a new session is the fallback, and it is the only route in tools without a plan mode.

## Plans for a cleared session

This is the writing counterpart of the section above. A cleared session keeps only the always-on instruction file (`AGENTS.md`), the memory index `memory/MEMORY.md`, the plan itself and the retained files. The planning conversation, the tool results, the research, the on-demand context files and the bodies of memory notes are all gone.

Give a size cap only where a measurement supports it, and write the measurement next to the number. A cap invented to look rigorous — a character count on an instruction file, a line count on a context — is enforced by nothing, drifts out of date silently, and is then quoted back by a later plan as a live constraint it must satisfy first. If the number came from a token budget, an injection measurement or a listing limit, say which; if it came from nowhere, do not write it.

So write every plan for an agent that does not remember the conversation. Standing rules come back on their own and need no restating; everything else the plan depends on belongs in a Context to load section, with full paths to the memory and context files needed and the key facts and numbers typed out in place instead of referred to as "see above". The executor reads all of it before the first wave and stops when a path is missing rather than proceeding on partial context.

## Plan-audit rule

Plan mode covers verification as well as construction, and a precise plan upfront costs less than the ambiguity it removes. A plan that touches three or more code files under `src/**` (tests and documentation in the same change do not count) or settles two or more architectural decisions goes through an independent review wave before it is finalised. A documentation-only change skips the wave; self-review carries it.

The gate is the rule, the cast is a recommendation. Run the reviewers read-only and in parallel in a single block. For a technical plan take three to seven of these: `architect` for structural coherence, layering and missing seams; `silent-failure-hunter` for failure modes, races, swallowed errors and verification gates that go green while proving nothing; `code-reviewer` for simplicity, empty steps and dead branches, asking whether the plan can be smaller; `prompt-engineer` for the verification recipe, meaning binary gates, exact commands and reproducibility; a recipe executor, who does not read the gates but runs them against the current tree and reports which are unrunnable, which pass vacuously and which cannot go red — reading a gate is how broken gates get past a whole panel of reviewers, and this is the seat that catches them; a spec checker (`general-purpose` in Claude Code) whenever the plan has a Spec section, confirming that every requirement has a task, every task a requirement, and that nothing extra crept in; and a clean-room reader, always present. In Claude Code the clean-room reader runs as the built-in `Plan` agent type precisely because that agent does not inherit the always-on instruction file and therefore reads the plan the way an uninformed session would — is it executable from the file alone, is everything it references reachable, are the facts typed out. In another tool, give a fresh agent the plan and nothing else. For a plan longer than 200 lines add a devil's advocate who reads hostilely and asks what happens when an assumption breaks.

For an academic or written plan leave the technical roster alone: run `/academic-paper-reviewer` for argument structure, methodology and citations, `/paper-audit` for integrity and unsourced claims (both from the academic track), `research-analyst` for fact-checking, counter-perspective and missing literature, and a devil's advocate on weak premises. Plain reading or short prose with no plan artifact needs no wave.

Give every reviewer the same four constraints: work read-only, writing nothing beyond its own report; stay under 1 500 words; return a verdict of `SHIP`, `SHIP-WITH-CHANGES` or `KILL` with findings that cite a checked file and line in the plan, then blockers, then nice-to-have items; and write that report to the path the orchestrator assigns under `plans/`, by convention `plans/<plan-slug>-agent-<id>.md`, which the orchestrator copies to the plan's named artifact if needed.

Wait for all of them, read them, then integrate. A `KILL` stops the work and goes to the user as a question — do not cut it silently. Each blocker behind a `SHIP-WITH-CHANGES` is fixed in the plan itself, with a line in the Audit log naming the reviewer and the finding. Remaining findings go into the Audit log as opportunities for a later version.

A finalised plan carries these sections: Context, plus Context to load whenever it leans on anything that is not always-on; a `## Spec` section inside the plan and never in a separate file when there are behavioural requirements, holding user stories in given/when/then form, functional requirements numbered `FR-NNN`, success criteria numbered `SC-NNN`, and an explicit clarification marker on anything unsettled; Recommended approach, with exact paths and expected output and no "we will work it out as we go"; Subagent strategy; Critical files, split into what is edited, what is only read and what stays untouched; a Verification recipe of binary gates and exact commands; Open questions; a Negative list; an Audit log holding the reviewer table, how each verdict was integrated and the paths to the review artifacts; and the sentinel `_End of plan v<N>._` as the last line.

Write the plan's version number once, in that sentinel, and nowhere else. A version repeated in the title, the header and the audit log goes stale in two of the three places on the first revision, and the reader cannot tell which one the executor believed.

A plan that defers work to a successor writes that successor as its own file rather than as an appendix. An appendix is read as commentary on the plan it sits in, so its facts are never re-measured when the successor is finally picked up — and by then they have aged. The follow-up plan gets a path, and the parent links to it.

## Gate hygiene

These rules exist because it is easy to ship a plan whose gates are mostly unrunnable or false-passing after many reviewers have read the recipe and none of them has executed it.

**Run every gate red before you trust it.** A gate that has never failed is not a gate, it is a sentence. Break the thing it measures on purpose — restore the deny rule, corrupt the frontmatter, add the forbidden pattern — and confirm it prints FAIL, then restore and confirm PASS. Do this in the same session that writes the gate, not later. A copy of the tree in a scratch directory is enough, and the gate should be parameterised by its root so that copy is usable.

**Split the recipe in two.** Runnable gates go in one script that executes unattended, prints exactly `SC-NNN PASS` or `SC-NNN FAIL` per gate and nothing else on stdout, takes every baseline from a snapshot file written at preflight rather than from a number typed into the plan, and exits non-zero when a blocking gate fails. Everything a human has to look at goes in a separate user-verified list and is reported, never counted. Mixing them produces a recipe that neither runs nor gets read.

**Do not gate on what the loop cannot fix.** A remote host, a commit trailer the harness injects, a model's behaviour: report them, keep them out of the red count that drives a retry loop. Four rounds against an unreachable machine is not verification.

Three traps are worth naming, because each is easy to hit. Measure a rename with whole-tree `git status --porcelain`, never a narrowed pathspec, which shows the deletion and hides the addition. Never build a needle by command substitution without asserting it non-empty, and never let a derived needle list be empty — an empty needle makes a gate pass over nothing. And in a shell battery, remember `grep -c` exits 1 on a zero count, so guard every count with `|| true` and compare numerically, or `set -e` aborts the run halfway and the silence reads as success.

**Exempt the artifact that is about the retired thing.** A scan for dead references will find them in the audit record that documents the retirement, in the plan that ordered it and in the memory note that explains it. Exempt those by path, in the scan, with the reason written next to the exemption. Do not soften the pattern.

Close the plan session with ExitPlanMode once the plan is on disk, printing the plan's path and the fallback trigger phrase "execute plan plans/<slug>.md".

## Subagent task template

Each task in Subagent strategy states three things: the files it owns, disjoint from every other task; its interfaces, what it consumes and what it produces, so tasks exchange contracts instead of sharing files; and the requirement and success-criterion ids it closes. One path has exactly one owner in exactly one wave, and the plan says which. Where two requirements touch the same file — an audit and a split of the same skill, say — one agent does both jobs for that file; splitting them by requirement instead of by path puts the same path in two ownership classes, and the second writer silently overwrites the first. Print the partition before launching a wave and check it, rather than trusting that it was disjoint when it was written. Constraints that bind the whole plan go into a `## Global Constraints` section at the top. Placeholders are banned in task text: no `TBD`, no `TODO`, no "similar to the task above", no "add validation" or "add error handling" without naming what is validated or handled. Every prompt tells its agent four things — the goal, the boundaries of what it may not touch, the artifact it must produce, and how the orchestrator will collect the result.

Where that artifact is text a later agent or the user will read, those four are completed by a dispatch contract: the output language, a length cap in words or characters, and the return shape. A plan writes all three into the task itself rather than leaving them to the session that executes it, for the same reason a plan types its facts out instead of referring to them — the executing session has the plan in front of it and no memory of the conversation that produced it, so a convention that was obvious to the author reaches the executor as nothing at all. The rule, and the measurement behind it, are in `orchestration-matrix.md` next to this file.

The orchestrator coordinates and does not implement, with two exceptions. A small connected edit, meaning at most two files and about forty lines with the context already loaded in the main session, is faster done directly than delegated. And when the inputs are already confirmed and the user is hurrying or has rejected a wave of agents, produce the deliverable yourself: direct edits and a run, artifact first, with documentation and commits afterwards and on request. That second exception does not extend to research or discovery, where delegation stays the default.

A wave prompt says in as many words that instruction files are written with Write and Edit; why, and what goes wrong when it does not, is in `hooks-overview.md` next to this file, under "Before an Edit or a Write".

Three more lines go into every agent's task. The first is the agent-type rule: each dispatch (in Claude Code, each Workflow `agent()` call with its `agentType`) names a lean type or a restricted role, and uses Explore, Plan, the default type or `general-purpose` only as a named exception with its reason in a script comment; the list of types and what each one carries is in `orchestration-matrix.md`. The second is the call budget, sized to the task — "your budget is about <2 x files you must edit + 10, at most 150> tool calls, and past it you stop with a partial report" — with an iteration ceiling added for an open-ended coding agent. The third is the phase model, set explicitly rather than inherited: a reading or mechanical phase runs on a cheap model such as sonnet, a verdict, a synthesis or an instruction-file edit on the strongest one, such as opus.

Before a bulk wave over many similar items, ask what can be settled deterministically: a missing required marker makes an item an automatic negative, an exact match an automatic decision. Filter those out in code, prove the filter loses nothing already known to be positive, and send only the ambiguous remainder to the fewest agents that still return complete output. They return compact verdicts, not the texts they read.

Wave widths, bulk batch sizes and the model each phase runs on are decided in `orchestration-matrix.md`; the only counts settled here are the reviewers above.

## Autonomous and overnight runs

An unattended run ends on an explicit stop condition written into the prompt: a binary gate from the plan's Verification recipe plus a turn limit — stop when these gates pass, or after this many turns — rather than "keep going until it is done". A recurring loop, such as Claude Code's `/loop`, carries the same stop condition.

Finish the run with a section titled "What the user must do", giving each open item a proposal or saying plainly that nothing is needed, so the user's role is clear after a silent night.

In the morning, check what is still running (in Claude Code, `claude agents`), check the run against its stop condition, and re-arm any monitors: they die silently on resume and must be started again.

## Session-mode policy

A session that both ingests untrusted content and is able to merge or deploy runs in `default` or `plan` permission mode, and not with permissions skipped. With skipping on, the deny rules and the allow-list are inert; only the pre-tool hooks and the tool grants of subagents still hold. Ordinary work runs in whatever permission mode you have configured, such as `auto`.
