# MCP Routing for the Research Pipeline

Moved out of `SKILL.md` and translated from Russian on 2026-09-03. The MCP tool identifiers are literals and are reproduced unchanged. Routing to the `yandex-search` server was removed in the same pass: that server is no longer in the MCP configuration, so those routes were dead at runtime.

---

## MCP-Aware Research Routing

When running the research pipeline, agents must use MCP servers for search and content extraction. Detailed instructions live in each agent's own file.

### General routing rules

| Task | Primary MCP | Fallback |
|---|---|---|
| Academic / semantic search | `mcp__exa__web_search_advanced_exa` | `mcp__paper-search__*` |
| URL content extraction | `mcp__jina__read_url` | `mcp__playwright__*`; login/paywall/anti-bot → a generic Chrome attached over CDP, or the web tools |
| Paper search (arXiv) | `mcp__jina__parallel_search_arxiv` | `mcp__paper-search__search_arxiv` |
| Paper search (PubMed, bioRxiv) | `mcp__paper-search__*` | `mcp__exa__web_search_exa` |
| Paper search (SSRN) | `mcp__jina__parallel_search_ssrn` | `mcp__exa__web_search_exa` |
| BibTeX records | `mcp__jina__search_bibtex` | — |
| DOI verification | `mcp__jina__read_url` (resolve URL) | `mcp__exa__web_search_exa` |
| Publication date check | `mcp__jina__guess_datetime_url` | — |
| Result reranking | `mcp__jina__sort_by_relevance` | — |
| Company research | `mcp__exa__company_research_exa` | — |

### Usage rules
- Exa free tier: 1000 requests per month — batch the queries, do not duplicate them

### Agents with MCP routing
- `bibliography_agent` — Exa > Paper Search (literature search)
- `source_verification_agent` — Jina DOI resolve + Exa retraction check
- `monitoring_agent` — Exa date-filtered search + Paper Search
