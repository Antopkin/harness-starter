# CREDITS: attribution and licences

This repository combines original material with a number of third-party skills and
agents. The original parts are covered by the MIT licence in `LICENSE`. Third-party
items keep their own licences and authorship: their licence files and author notes stay
inside each item as they are, and the full licence texts of the upstream projects are
collected in `licenses/`. Do not remove them, and when you copy skills into
`.claude/skills/` or `.agents/skills/` (or agents into `.claude/agents/`), copy them
along with the item.

Every third-party item below was **modified** for this kit (for example trimmed,
restructured, or linked to other files of this repository), so it differs from its
upstream. The upstream remains the source of the ideas and of the original wording.

## Third-party agents

### VoltAgent/awesome-claude-code-subagents (MIT)

Upstream: <https://github.com/VoltAgent/awesome-claude-code-subagents>. Licence: MIT,
full text in `licenses/VoltAgent-MIT.txt`. Each agent below is modified for this kit.

- `agent-organizer` (`agents/agent-organizer.md`)
- `backend-developer` (`agents/backend-developer.md`)
- `code-reviewer` (`agents/code-reviewer.md`)
- `data-engineer` (`agents/data-engineer.md`)
- `docker-expert` (`agents/docker-expert.md`)
- `documentation-engineer` (`agents/documentation-engineer.md`)
- `frontend-developer` (`agents/frontend-developer.md`)
- `postgres-pro` (`agents/postgres-pro.md`)
- `prompt-engineer` (`agents/prompt-engineer.md`)
- `python-pro` (`agents/python-pro.md`)
- `research-analyst` (`agents/research-analyst.md`)
- `security-engineer` (`agents/security-engineer.md`)
- `ui-designer` (`agents/ui-designer.md`)
- `ux-researcher` (`agents/ux-researcher.md`)

### affaan-m/everything-claude-code (MIT)

Upstream: <https://github.com/affaan-m/everything-claude-code>. Licence: MIT, full text
in `licenses/everything-claude-code-MIT.txt`. Each agent below is modified for this kit.

- `architect` (`agents/architect.md`)
- `silent-failure-hunter` (`agents/silent-failure-hunter.md`): everything-claude-code's
  version condenses the silent-failure-hunter agent of the pr-review-toolkit plugin in
  anthropics/claude-plugins-official (<https://github.com/anthropics/claude-plugins-official>),
  Apache-2.0, full text in `licenses/Apache-2.0.txt`.

## Third-party skills

### mattpocock/skills (MIT)

Upstream: <https://github.com/mattpocock/skills>. Licence: MIT, full text in
`licenses/mattpocock-MIT.txt`. Each item below is adapted from that collection and
modified for this kit.

- `diagnose` (`skills/diagnose/`): adapted from `engineering/diagnosing-bugs`; modified.
- `tdd` (`skills/tdd/`): adapted from `engineering/tdd`; modified.
- `grill-me` (`skills/grill-me/`): modified.
- `grill-with-docs` (`skills/grill-with-docs/`): modified.
- `improve-codebase-architecture` (`skills/improve-codebase-architecture/`): modified
  (plans are written to `plans/`).
- `zoom-out` (`skills/zoom-out/`): modified.
- `handoff` (`skills/handoff/`): modified.
- `triage-issue` (`skills/triage-issue/`): modified.
- `review` (`skills/review/`): modified.
- `wizard` (`skills/wizard/`): modified.
- `retro` (`skills/retro/`): modified.
- `to-questionnaire` (`skills/to-questionnaire/`): modified.
- `writing-fragments` (`skills/writing-fragments/`): modified.
- `wayfinder` (`skills/wayfinder/`): modified.
- `git-finalize` (`skills/git-finalize/`): modified. Its pull request shape reproduces
  Dex Horthy's show-me skill from humanlayer/humanlayer
  (<https://github.com/humanlayer/humanlayer>), as the upstream itself credits.
- `git-workflow` (`contexts/git-workflow.md`, the pull request shape): modified.
- `writing-for-agents` (`skills/skill-creator/references/writing-for-agents.md`):
  modified.
- `bash-guard.sh` (`hooks/bash-guard.sh`): the per-segment git rules (`git clean`
  without a dry-run flag, whole-tree `git checkout` and `git restore`) follow the
  upstream `git-guardrails-claude-code` skill; rewritten, not copied. The rest of the
  guard is original.

### vercel-labs/skills (MIT)

- `find-skills` (`skills/find-skills/`): upstream <https://github.com/vercel-labs/skills>.
  Licence: MIT, full text in `licenses/vercel-labs-MIT.txt`. Modified.

### Jeffallan/claude-skills (MIT)

- `code-documenter` (`skills/code-documenter/`): upstream
  <https://github.com/Jeffallan/claude-skills>, author noted in the skill's metadata.
  Licence: MIT, full text in `licenses/Jeffallan-MIT.txt`. Modified.

### Anthropic: anthropics/skills and anthropics/claude-plugins-official (Apache 2.0)

Licence: Apache License 2.0, full text in `licenses/Apache-2.0.txt`.

- `skill-creator` (`skills/skill-creator/`): from anthropics/skills
  (<https://github.com/anthropics/skills>), a skill for creating, improving and
  evaluating skills. The licence text also ships inside the skill as
  `skills/skill-creator/LICENSE.txt`. Modified.
- `canvas-design` (`skills/canvas-design/`): from anthropics/skills; the licence text
  ships inside the skill as `skills/canvas-design/LICENSE.txt`. The fonts in
  `skills/canvas-design/canvas-fonts/` are under the SIL Open Font License (OFL), per the
  licence files next to them. Modified.
- `doc-coauthoring` (`skills/doc-coauthoring/`): from anthropics/skills. The skill has no
  licence file of its own; the anthropics/skills README states that its non-document
  skills are released under Apache 2.0. Modified.
- `claude-automation-recommender` (`skills/claude-automation-recommender/`): from
  anthropics/claude-plugins-official (<https://github.com/anthropics/claude-plugins-official>),
  Apache-2.0. Modified (frontmatter `tools:` became `allowed-tools:`).

### `ru-text` by Arseniy Kamyshev (MIT)

"Independent Russian text quality reference by Arseniy Kamyshev"
(`skills/ru-text/SKILL.md`, homepage: <https://ru-text.org>). Upstream:
<https://github.com/talkstream/ru-text>. Licence: MIT, full text in
`licenses/ru-text-MIT.txt`. The wording in the skill is the author's own. The list of works that inspired it, with acknowledgements
(A. Gorbunov, M. Ilyakhov, A. E. Milchin and L. K. Cheltsova, I. Birman, Nora Gal,
D. E. Rosenthal and others), is kept as it is in `skills/ru-text/references/sources.md`.
The authors and publishers listed there have not reviewed or endorsed the skill; the
references are given as attribution of inspiration and as recommended reading.

### Academic track: Imbad0202/academic-research-skills by Cheng-I Wu (CC BY-NC 4.0)

`academic-paper`, `academic-paper-reviewer`, `academic-pipeline` and `deep-research`
(in `tracks/academic/skills/`) form one family of academic skills (writing a paper,
simulated peer review, pipeline orchestration, in-depth research) that cross-reference
each other as a single pipeline. Upstream:
<https://github.com/Imbad0202/academic-research-skills>, maintained by **Cheng-I Wu**, as
the skills' own version metadata states. Licence: Creative Commons
Attribution-NonCommercial 4.0 International (CC BY-NC 4.0), full text in
`licenses/CC-BY-NC-4.0.txt`. The non-commercial condition applies to these four skills:
do not use them commercially. The authors' versions and changelogs are kept inside the
skills. Modified. The shared `handoff_schemas.md` (`tracks/academic/skills/shared/`)
belongs to the same family and carries the same licence.

### `latex-proofread`: LimHyungTae/awesome-claudecode-paper-proofreading (MIT)

`tracks/academic/skills/latex-proofread/` is based on the open repository
**LimHyungTae/awesome-claudecode-paper-proofreading**
(<https://github.com/LimHyungTae/awesome-claudecode-paper-proofreading>; the source is
also named in the skill's `metadata.source` field and in its description). Licence: MIT,
full text in `licenses/LimHyungTae-MIT.txt`. The attribution and version are kept
inside `SKILL.md`. Modified.

### `paper-audit` and `latex-paper-en`: bahayonghang/academic-writing-skills

`tracks/academic/skills/paper-audit/` and `tracks/academic/skills/latex-paper-en/` come
from <https://github.com/bahayonghang/academic-writing-skills>. The upstream has no
licence file; its README says "Academic Use Only". They are kept here with attribution,
for academic use. Modified.

### `latex-document`: ndpvt-web/latex-document-skill

`tracks/academic/skills/latex-document/` comes from
<https://github.com/ndpvt-web/latex-document-skill>. The upstream README says MIT; the
upstream has no licence file. Modified. The PDF form-filling scripts of the upstream
skill are not published in this kit, because they reproduce code from Anthropic's
proprietary pdf skill.

## Original parts (MIT, © 2026 Oleg Antopkin)

- The rule set `AGENTS.md` and the addendum `tracks/academic/AGENTS.academic.md`.
- `README.md`, `INSTALL.md`, `hello.md`, `runbooks.md`, `memory/`, and the README and
  runbooks of the academic track.
- Base skills: `explain`, `test`, `writing-guru`, `style-extract`, `lit-search`.
- Track skills: `transcript-verbatim`, `transcript-polish`, `latex-fix` (rewritten in the
  kit's own words) and the shared file `tracks/academic/skills/shared/transcript-io.md`.
- MCP configuration: `tracks/academic/mcp/README.md` and `.mcp.json.example`
  (placeholders only, no keys).

Everything else in the repository that is not listed above as a third-party item is
original work under the same MIT licence.

## External dependencies (not included in the repository)

The academic track connects two open MCP servers, the Python packages
`paper-search-mcp` and `zotero-mcp`. They are not distributed with this repository: you
install them yourself with `uvx` or `pip`, and this repository only holds a
configuration template with placeholders. The packages have their own authors and
licences; see the packages' own pages.

## Rule for extending the kit

When you add a third-party skill or agent, keep its LICENSE and author notes inside the
item's folder, put the upstream licence text into `licenses/`, and add its source and
licence here.
