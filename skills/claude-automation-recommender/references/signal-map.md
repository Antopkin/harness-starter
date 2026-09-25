# Codebase Signal Map

Phase 2 of the claude-automation-recommender workflow: the codebase signal that points to each recommendation, by category. The detailed patterns for each category live in the sibling reference files linked from SKILL.md.

## A. MCP Server Recommendations

| Codebase Signal | Recommended MCP Server |
|-----------------|------------------------|
| Uses popular libraries (React, Express, etc.) | **context7** - Live documentation lookup |
| Frontend with UI testing needs | **Playwright** - Browser automation/testing |
| Uses Supabase | **Supabase MCP** - Direct database operations |
| PostgreSQL/MySQL database | **Database MCP** - Query and schema tools |
| GitHub repository | **GitHub MCP** - Issues, PRs, actions |
| Uses Linear for issues | **Linear MCP** - Issue management |
| AWS infrastructure | **AWS MCP** - Cloud resource management |
| Slack workspace | **Slack MCP** - Team notifications |
| Memory/context persistence | **Memory MCP** - Cross-session memory |
| Sentry error tracking | **Sentry MCP** - Error investigation |
| Docker containers | **Docker MCP** - Container management |

## B. Skills Recommendations

Create skills in `.claude/skills/<name>/SKILL.md`. Some are also available via plugins:

| Codebase Signal | Skill | Plugin |
|-----------------|-------|--------|
| Building plugins | skill-development | plugin-dev |
| Git commits | commit | commit-commands |
| React/Vue/Angular | frontend-design | frontend-design |
| Automation rules | writing-rules | hookify |
| Feature planning | feature-dev | feature-dev |

**Custom skills to create** (with templates, scripts, examples):

| Codebase Signal | Skill to Create | Invocation |
|-----------------|-----------------|------------|
| API routes | **api-doc** (with OpenAPI template) | Both |
| Database project | **create-migration** (with validation script) | User-only |
| Test suite | **gen-test** (with example tests) | User-only |
| Component library | **new-component** (with templates) | User-only |
| PR workflow | **pr-check** (with checklist) | User-only |
| Releases | **release-notes** (with git context) | User-only |
| Code style | **project-conventions** | Claude-only |
| Onboarding | **setup-dev** (with prereq script) | User-only |

## C. Hooks Recommendations

| Codebase Signal | Recommended Hook |
|-----------------|------------------|
| Prettier configured | PostToolUse: auto-format on edit |
| ESLint/Ruff configured | PostToolUse: auto-lint on edit |
| TypeScript project | PostToolUse: type-check on edit |
| Tests directory exists | PostToolUse: run related tests |
| `.env` files present | PreToolUse: block `.env` edits |
| Lock files present | PreToolUse: block lock file edits |
| Security-sensitive code | PreToolUse: require confirmation |

## D. Subagent Recommendations

| Codebase Signal | Recommended Subagent |
|-----------------|---------------------|
| Large codebase (>500 files) | **code-reviewer** - Parallel code review |
| Auth/payments code | **security-reviewer** - Security audits |
| API project | **api-documenter** - OpenAPI generation |
| Performance critical | **performance-analyzer** - Bottleneck detection |
| Frontend heavy | **ui-reviewer** - Accessibility review |
| Needs more tests | **test-writer** - Test generation |

## E. Plugin Recommendations

| Codebase Signal | Recommended Plugin |
|-----------------|-------------------|
| General productivity | **anthropic-agent-skills** - Core skills bundle |
| Document workflows | Install docx, xlsx, pdf skills |
| Frontend development | **frontend-design** plugin |
| Building AI tools | **mcp-builder** for MCP development |

Modified for this kit from anthropics/claude-plugins-official (Apache-2.0).
