# Writing quality and factual integrity

Read this when writing a report, an analysis, documentation or an academic text, when reviewing someone's style, or when checking a draft for AI slop. The rules apply in whatever language the deliverable is written in. The cliché lexicon below covers English and Russian; the Russian entries are kept in Russian because they are samples of that language.

## Style infrastructure

Load the matching profile from `memory/style-profiles/` before writing a report or an analysis; the `/style-extract` skill builds a profile from samples of your own writing. The reference samples inside a profile are the primary guidance on style: match them rather than drifting into a creative interpretation of them. In Claude Code, an output style in `.claude/output-styles/` shifts the tone of an entire session and suits long writing sessions. The `writing-guru` skill picks the narrative strategy before the writing starts, and the `ru-text` skill edits finished Russian text for typography, information style and the usual anti-patterns; invoke it when the user asks, not on every Russian answer. For consulting work build the argument on the Pyramid Principle with branches that are mutually exclusive and collectively exhaustive; for academic work use the topic, evidence, explanation and link pattern with hedged claims.

## Register: live prose, not telegraphese

Write instructions, long answers and deliverables in live but dense prose, in full sentences with verbs. Avoid the telegraphic register: arrows and slashes standing in for punctuation, verbless fragments, and nominalised bureaucratic phrasing ("Finalization: plan must have…" where "When you finalize, check that…" is meant). The register of the text you write leaks into everything the session writes afterwards, so this is not cosmetics. Leave technical terms alone — sticky, lazy, subagent, fan-out, file-disjoint stay as they are; what gets repaired is the connecting prose, not the vocabulary. Use a dash for ranges (3–5), and never put a non-breaking space into a configuration file, where it silently breaks grep.

## Detecting AI slop

Semantic flags, which grep cannot catch and you have to judge by meaning:

- No position and a flat tone: text about everything and nothing, with no thesis, no "I would", no admitted mistake.
- Nothing concrete and nothing verifiable: no account of what broke and where, no dates, versions, names, numbers or primary sources.
- Fake confidence with weak causality: "always do X" without a context, or "because it matters" in place of an explicit chain of cause and effect.
- Logic that is too clean: perfect coherence with no "but", "although" or "however", where a live author hesitates and sometimes contradicts themselves.
- Filler: many words carrying few facts, volume for its own sake.
- Template structure: every section opens, bullets and concludes; listicles whose items are interchangeable; pseudo-metaphors and decorative terminology.

Cliché lexicon, to delete or rephrase:

- English: "it is important to note", "in today's fast-paced world", "delve into", "holistic", "navigate the landscape", "essentially", "at the end of the day", "a myriad of", "unlock the potential", "game-changer", "deep dive", "leverage", "synergy".
- Russian: «в конечном итоге», «стоит отметить», «на самом деле» (overused), «важно понимать», «ключевой момент», «безусловно», «не лишним будет», «нельзя не отметить», «это позволяет», «данный подход».
- Structural tics: uniform sentence length, where alternating long and short reads better and one or two short sentences in a row strengthen the long one after them; and closings of the "in conclusion, use best practices" kind.

Verdict: count the flags, semantic and lexical together. Three or more mean the draft probably reads as AI slop and should be rewritten with specifics, a stated position, honest qualifications and sources. Do not assign a numeric score; this is a qualitative checklist. An expert summary written without "I" but full of real detail and numbers is not slop.

## Factual integrity

Never present an unverified statement as a fact. Every quantitative claim — a figure, a percentage, a date — carries a source. When no source turns up, mark the claim `[UNVERIFIED]` or drop it. Peer-reviewed work outranks official reports, which outrank media, which outrank blogs, which outrank social posts. When sources disagree, say so in the text instead of silently averaging them. The routing that finds those sources, and the same hierarchy applied at search time, live in `research-routing.md` next to this file.

## Before you send

1. Does every number carry a source?
2. Fewer than three slop flags, and no cliché from the lexicon?
3. Does the style match the reference samples of the loaded profile?
4. Would the claims survive an adversarial review?
