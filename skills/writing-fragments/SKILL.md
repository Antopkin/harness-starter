---
name: writing-fragments
description: Experimental. Explore a piece of writing before it has a structure. A grilling session that mines raw fragments and coined terms and appends them to one unstructured file.
disable-model-invocation: true
argument-hint: "[topic] [path to the fragments file]"
---

# Writing fragments

**Experimental.** This skill is new and its workflow may still change; judge the fragments it collects yourself before you build on them.

This skill is user-invoked: you start it yourself with `/writing-fragments`. The `disable-model-invocation` flag that stops the agent from starting it on its own is honoured only by Claude Code; OpenCode and Codex may still invoke it automatically.

This is pure **explore**: widen the space of what could be written without committing to a structure. Committing (outlines, sections, an argument's order) is *exploit*, and it is out of scope here. Run a grilling session that produces fragments: interview the user relentlessly about whatever they want to write, and keep every piece of good writing that surfaces.

Capture fragments from the very first thing the user says, including the opening prompt, and from both sides of the conversation.

## The file

Append everything to one Markdown file: the path the user gives, or else `<topic>-fragments.md` in the current directory, with a short slug of the topic. Say once where it lives, then keep using it for the rest of the session.

On the first write, put a single H1 with a working title at the top (it may change later) and nothing else: no metadata, no table of contents, no date.

Write fragments in the language of the text. If the user writes the piece in one language and talks about it in another, the fragments follow the piece, whatever language the conversation drifts into; a quoted line stays in the language it was said in.

## What a fragment is

A fragment is any piece of text that might survive into the final piece. It must be readable by the author, who can tell what it means, but it need not define its terms or make sense to a cold reader. The bar is "is this a piece of good writing?", not "is this a self-contained argument?"

Fragments are deliberately mixed:

- a sharp sentence you would want to use somewhere, not yet knowing where;
- a claim with a one-line justification;
- a vignette: something that happened, a code snippet, a scenario, an analogy;
- a half-thought: "something about how X feels like Y, work this out later";
- a quote, a piece of dialogue, an overheard line;
- a cluster of observations that hang together by feel;
- a complaint, a confession, a punchline;
- a **coined term**: a compact metaphor or coinage the whole piece can hang on, one term that names the idea the way *tracer bullets* or *fog of war* names a whole pattern.

The coined term is the most valuable fragment to land. It is load-bearing: find the right one while exploring and it shapes the structure, the transitions and the title later. When the conversation circles a recurring idea, push to coin a word for it, and record it as its own fragment.

The novelist's diary is the model: years of unstructured noticings, mined later for raw material. Fragments are noticings.

## Format

Separate fragments with a horizontal rule on its own line (`---`). No headings inside the body, no tags, no order beyond the order they were added. A fragment takes whatever shape it naturally has: several paragraphs, a list, code, a quote with a reaction under it.

```markdown
# Working title

A first fragment lives here.

It can run to several paragraphs.

---

> A quoted line worth keeping around.

A reaction to it.

---

- A cluster of related observations
- that hang together by feel
```

## Rhythm

Append without asking permission for each fragment. Mention what you added in passing ("adding that"), but do not interrupt the conversation with save dialogues.

Before every write, re-read the file from disk: the user may have edited, reordered or deleted fragments between turns, and their changes stand. Never overwrite the file; only append, or edit one specific fragment in place when the user asks.

The user can say "cut the last one", "rewrite that one sharper" or "merge those two" at any time. Treat those as first-class instructions.

Adapted from mattpocock/skills@c55ee46 in-progress/writing-fragments (MIT).
