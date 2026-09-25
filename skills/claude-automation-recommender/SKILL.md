---
name: claude-automation-recommender
description: Analyze a codebase and recommend Claude Code automations (hooks, subagents, skills, plugins, MCP servers). Use when user asks for automation recommendations, wants to optimize their Claude Code setup, mentions improving Claude Code workflows, asks how to first set up Claude Code for a project, or wants to know what Claude Code features they should use.
disable-model-invocation: true
allowed-tools: Read Glob Grep Bash
---

# Claude Automation Recommender

Analyze codebase patterns to recommend tailored Claude Code automations across all extensibility options.

**This skill is read-only.** It analyzes the codebase and outputs recommendations. It does NOT create or modify any files. Users implement the recommendations themselves or ask Claude separately to help build them.

The skill is user-invoked (`disable-model-invocation: true`). Only Claude Code honours that flag; OpenCode and Codex may still invoke the skill on their own.

## Output Guidelines

- **Recommend 1-2 of each type**: Don't overwhelm - surface the top 1-2 most valuable automations per category
- **If user asks for a specific type**: Focus only on that type and provide more options (3-5 recommendations)
- **Go beyond the reference lists**: The reference files contain common patterns, but use web search to find recommendations specific to the codebase's tools, frameworks, and libraries
- **Tell users they can ask for more**: End by noting they can request more recommendations for any specific category

## Automation Types Overview

| Type | Best For |
|------|----------|
| **Hooks** | Automatic actions on tool events (format on save, lint, block edits) |
| **Subagents** | Specialized reviewers/analyzers that run in parallel |
| **Skills** | Packaged expertise, workflows, and repeatable tasks (invoked by Claude or user via `/skill-name`) |
| **Plugins** | Collections of skills that can be installed |
| **MCP Servers** | External tool integrations (databases, APIs, browsers, docs) |

## Workflow

### Phase 1: Codebase Analysis

Gather project context with the detection commands, and capture the Key Indicators, listed in [the codebase analysis checklist](references/codebase-analysis.md).

**Output language:** the language of the user's request, which the Phase 3 report follows too. **Length cap:** at most 150 words. **Return shape:** the Codebase Profile fields — Type, Framework, Key Libraries — plus the rows of the Key Indicators table that actually matched.

### Phase 2: Generate Recommendations

Based on analysis, generate recommendations across all categories. The codebase signal that points to each recommendation, per category, is mapped in [the signal map](references/signal-map.md).

#### A. MCP Server Recommendations

See [references/mcp-servers.md](references/mcp-servers.md) for detailed patterns.

#### B. Skills Recommendations

See [references/skills-reference.md](references/skills-reference.md) for details.

#### C. Hooks Recommendations

See [references/hooks-patterns.md](references/hooks-patterns.md) for configurations.

#### D. Subagent Recommendations

See [references/subagent-templates.md](references/subagent-templates.md) for templates.

#### E. Plugin Recommendations

See [references/plugins-reference.md](references/plugins-reference.md) for available plugins.

**Output language:** the language of the user's request, which the Phase 3 report follows too. **Length cap:** at most 400 words. **Return shape:** one entry per recommendation, each with a name, a Why line tied to a detected signal, and its install or create location (Install, Create or Where), plus an Invocation line for skills; this contract governs subsections A through E.

### Phase 3: Output Recommendations Report

Format recommendations clearly. **Only include 1-2 recommendations per category** - the most valuable ones for this specific codebase. Skip categories that aren't relevant.

```markdown
## Claude Code Automation Recommendations

I've analyzed your codebase and identified the top automations for each category. Here are my top 1-2 recommendations per type:

### Codebase Profile
- **Type**: [detected language/runtime]
- **Framework**: [detected framework]
- **Key Libraries**: [relevant libraries detected]

---

### 🔌 MCP Servers

#### context7
**Why**: [specific reason based on detected libraries]
**Install**: `claude mcp add context7`

---

### 🎯 Skills

#### [skill name]
**Why**: [specific reason]
**Create**: `.claude/skills/[name]/SKILL.md`
**Invocation**: User-only / Both / Claude-only
**Also available in**: [plugin-name] plugin (if applicable)
```yaml
---
name: [skill-name]
description: [what it does]
disable-model-invocation: true  # for user-only
---
```

---

### ⚡ Hooks

#### [hook name]
**Why**: [specific reason based on detected config]
**Where**: `.claude/settings.json`

---

### 🤖 Subagents

#### [agent name]
**Why**: [specific reason based on codebase patterns]
**Where**: `.claude/agents/[name].md`

---

**Want more?** Ask for additional recommendations for any specific category (e.g., "show me more MCP server options" or "what other hooks would help?").

**Want help implementing any of these?** Just ask and I can help you set up any of the recommendations above.
```

**Output language:** the language of the user's request; the template above fixes the report's structure, not its language. **Length cap:** at most 800 words. **Return shape:** the inline report template in this section — Codebase Profile, then 1-2 entries per relevant category, then the two closing "Want more?" and "Want help implementing" lines.

## Decision Framework

When each automation type (MCP servers, skills and their invocation control, hooks, subagents, plugins) is the right recommendation is set out in [the decision framework](references/decision-framework.md).

---

## Configuration Tips

MCP server setup, headless mode for CI and automation, and permissions for hooks are covered in [the configuration tips](references/configuration-tips.md).

Modified for this kit from anthropics/claude-plugins-official (Apache-2.0).
