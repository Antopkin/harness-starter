# Project memory: index

This is where the agent keeps facts that must survive session restarts: how the project is built, where things are, which decisions are already made, which pitfalls were already hit, and every correction the user gave. The agent re-reads this index at session start and follows its links to the notes that bear on the task, so it does not ask the same questions twice.

## Notes

- [[feedback_example]]: an example feedback note; copy its shape for your own corrections.

## How to keep memory

- **One note = one fact, in its own file.** Put it in `memory/<name>.md` and add one line with a `[[name]]` link and a short hook to the Notes list above. The index stays a list of links; the content lives in the notes.
- **Write a note after every correction.** When the user says "no, not like that, do it this way", write a `feedback` note straight away, so the mistake does not come back next session.
- **Re-read at session start.** The agent reads this index first and opens the notes that match the task, feedback notes above all.
- **Link notes to each other** with `[[name]]` where one fact depends on another, instead of repeating the fact.
- **Update or delete** a note that turned out to be wrong; a stale note is worse than none.
- **Never store secrets**, tokens or passwords here, only facts about the project.
- Style profiles made by `style-extract` live in `memory/style-profiles/`.

## The format of a note

Each note starts with frontmatter:

- `name`: the file name without `.md`; it is what `[[name]]` links point to.
- `description`: one line saying what the note is about, so the agent can decide from the index whether to open it.
- `type` (under `metadata`): one of `user` (who the user is and how they like to work), `feedback` (a correction or a confirmed way of working), `project` (a fact about this project) or `reference` (where to find something outside the project).

The body states the rule or fact first, then two lines:

- **Why:** the reason, often the incident that produced the note. It lets the agent judge edge cases instead of following the rule blindly.
- **How to apply:** when and where the rule kicks in.

A template:

```markdown
---
name: feedback_short_topic
description: One line on what this note covers
metadata:
  type: feedback
---

The rule or fact, in one or two sentences.

**Why:** what happened, or why it matters.

**How to apply:** when and where to use it.
```
