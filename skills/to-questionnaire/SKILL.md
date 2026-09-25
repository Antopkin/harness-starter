---
name: to-questionnaire
description: Turn open questions the user cannot answer alone into a Markdown questionnaire for one recipient to fill in, written in the recipient's language.
disable-model-invocation: true
argument-hint: "[topic or open questions]"
---

# To questionnaire

Turn something the user cannot answer alone into a **questionnaire**: a Markdown document they hand to one recipient to fill in asynchronously, or to go through together in a meeting. The recipient holds knowledge the user lacks; the questionnaire draws it out.

Talk with the user in the language of the user's request. Write the questionnaire itself in the recipient's language, which may differ; if you cannot tell what it is, ask in step 1.

This skill is user-invoked: you start it yourself with `/to-questionnaire`. The `disable-model-invocation` flag that stops the agent from starting it on its own is honoured only by Claude Code; OpenCode and Codex may still invoke it automatically.

**Grill the send, not the subject.** Interview the user only about the *send*, which they can always answer: who it goes to, and what they need back. The questions in the document then aim at the **gap** between what the recipient knows and what the user needs.

## Steps

1. **Who is it going to?** In one exchange, ask for the recipient's role, expertise, relationship to the user and language. This fixes the tone, the language and how much context the document must carry. Done when you know who the recipient is and what they know that the user does not.

2. **What do you need back?** In one exchange, ask for the specific decisions or facts the user cannot settle alone and needs from this person. Done when you have a concrete list of what the user must walk away able to do or decide.

3. **Write the questionnaire.** Draft questions aimed at the gap from steps 1 and 2, following the structure below. Write it to `to-questionnaire-<slug>.md` in the current directory (slug from the topic), or to the path the user gives, and report the path. Done when the file exists and every item from step 2 is covered by a question.

## Document structure

Frame the document as a **discovery questionnaire**: the user lacks context, the recipient holds it. Order the questions most important first, because an asynchronous send may get only one pass, and group them under `##` headings by theme once there are more than a handful. Translate the template's headings and labels into the recipient's language along with everything else.

<questionnaire-template>

# <Questionnaire title>

**Purpose:** why this questionnaire exists and the decision riding on it.

**From:** <the user>, **To:** <the recipient>, **How your answers will be used:** <where they go>

## Context

One paragraph orienting a recipient who was not in the user's head. Enough to answer well, not a page.

## How to answer

Deadline and rough effort. Partial answers and "I don't know" are useful: flag anything you are unsure of rather than skipping it.

## <Theme heading>

One `##` section per theme. Under each, its questions, most important first. Every question carries one idea, never a compound, with an answer stub directly beneath, and a one-line *why this matters* only where the question could be misread or invite a throwaway answer.

<question-example>
### What load is the system expected to handle at launch?

_Why this matters: it decides whether we provision for burst traffic now or defer it._

>
</question-example>

## Anything else?

A closing catch-all: anything we did not ask that we should know?

</questionnaire-template>

Adapted from mattpocock/skills@c55ee46 productivity/to-questionnaire (MIT).
