# Decision Framework

When each automation type is the right recommendation for the claude-automation-recommender skill.

## When to Recommend MCP Servers
- External service integration needed (databases, APIs)
- Documentation lookup for libraries/SDKs
- Browser automation or testing
- Team tool integration (GitHub, Linear, Slack)
- Cloud infrastructure management

## When to Recommend Skills

- Document generation (docx, xlsx, pptx, pdf — also in plugins)
- Frequently repeated prompts or workflows
- Project-specific tasks with arguments
- Applying templates or scripts to tasks (skills can bundle supporting files)
- Quick actions invoked with `/skill-name`
- Workflows that should run in isolation (`context: fork`)

**Invocation control:**
- `disable-model-invocation: true` — User-only (for side effects: deploy, commit, send)
- `user-invocable: false` — Claude-only (for background knowledge)
- Default (omit both) — Both can invoke

## When to Recommend Hooks
- Repetitive post-edit actions (formatting, linting)
- Protection rules (block sensitive file edits)
- Validation checks (tests, type checks)

## When to Recommend Subagents
- Specialized expertise needed (security, performance)
- Parallel review workflows
- Background quality checks

## When to Recommend Plugins
- Need multiple related skills
- Want pre-packaged automation bundles
- Team-wide standardization

Modified for this kit from anthropics/claude-plugins-official (Apache-2.0).
