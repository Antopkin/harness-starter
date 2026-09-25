# Configuration Tips

Setup advice to pass on with the claude-automation-recommender skill's recommendations.

## MCP Server Setup

**Team sharing**: Check `.mcp.json` into repo so entire team gets same MCP servers

**Debugging**: Use `--mcp-debug` flag to identify configuration issues

**Prerequisites to recommend:**
- GitHub CLI (`gh`) - enables native GitHub operations
- Puppeteer/Playwright CLI - for browser MCP servers

## Headless Mode (for CI/Automation)

Recommend headless Claude for automated pipelines:

```bash
# Pre-commit hook example
claude -p "fix lint errors in src/" --allowedTools Edit,Write

# CI pipeline with structured output
claude -p "<prompt>" --output-format stream-json | your_command
```

## Permissions for Hooks

Configure allowed tools in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": ["Edit", "Write", "Bash(npm test:*)", "Bash(git commit:*)"]
  }
}
```

Modified for this kit from anthropics/claude-plugins-official (Apache-2.0).
