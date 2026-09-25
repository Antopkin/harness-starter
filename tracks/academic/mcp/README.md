# MCP for the academic overlay: two servers

This folder connects two external tools ("MCP servers") to your agent. Once they are
connected, the agent can **search for research papers across dozens of databases** and
**work with your personal Zotero library**, without leaving the chat.

Everything is written for anyone who works with academic sources, not for a particular
person: it installs out of the box, the keys are your own, and the example has placeholders
instead of them.

> **MCP in plain words.** MCP (Model Context Protocol) is a standard "adapter" through which
> the agent gains new abilities. One server = one set of abilities. We connect two: paper
> search and Zotero.

---

## What the two servers give you

### 1. `paper-search` — searching and downloading research papers

It gives the agent direct access to academic databases, bypassing manual web search:

- **Preprints and open access:** arXiv, bioRxiv, medRxiv, SSRN, HAL, IACR, Zenodo,
  DOAJ, BASE, CORE, OpenAlex, OpenAIRE.
- **Medicine and biology:** PubMed, PMC, Europe PMC.
- **Metadata and links:** CrossRef (by DOI), Semantic Scholar, DBLP (CS), Google
  Scholar, Unpaywall (the open version of a paywalled paper).
- **Operations on each database:** `search_*` finds by query; `read_*_paper` reads the
  full text; `download_*` downloads the PDF. There is also `download_with_fallback`, which
  tries to fetch the PDF from several sources in turn.

Why: in one pass the agent searches several databases, filters out what is irrelevant,
extracts the metadata (authors, year, DOI) and puts the PDFs into your `materials/`, with
no copying and pasting of links by hand.

> **The legal frame.** The server is technically able to pull texts from shadow libraries
> too. We **do not do that**: we use open access, Unpaywall, your university's
> subscription and interlibrary loan. More in `runbooks/eresources.md`.

### 2. `zotero` — your personal library

It connects **your** Zotero library (a reference manager) to the agent:

- **Searching your library:** by words, by tags, advanced search and semantic search (by
  meaning rather than by exact word).
- **Reading:** a record's metadata, the full text of an attachment, child notes and
  annotations, recently added items.
- **Writing:** create a note on a source, add an annotation, add or update tags in bulk.

Why: the agent answers questions about the sources you have already collected, puts
digests and syntheses back into Zotero as notes, and tidies the library with tags.

> **What the Zotero server does NOT do:** it does not add **new** records (the paper
> itself) to the library. You put a new source into Zotero yourself, with the Zotero
> Connector button in the browser or by importing; the agent then finds that record,
> digests it and annotates it. Details: `runbooks/zotero.md`.

---

## How to connect (step by step)

### Step 1. Install what runs the servers

Both servers are written in Python and are easiest to run through **`uv`** (a fast
installer; the `uvx` command downloads and runs a package in one call).

- Install `uv` following the official instructions: <https://docs.astral.sh/uv/> (the
  short install command is on the front page).
- Check: `uvx --version` in the terminal should print something.

If you would rather not use `uv`, plain `pip install paper-search-mcp` /
`pip install zotero-mcp` works too; in that case put the direct launch command in the
config instead of `uvx` (see below). Check the exact launch module in the server's own
README: package names change from time to time.

### Step 2. Copy the config and put in your keys

Next to this file is `.mcp.json.example`, a ready template for both servers with
placeholders.

1. Copy it to the root of your working folder (the repository root, where the base is
   installed) under the name `.mcp.json`:
   ```
   cp tracks/academic/mcp/.mcp.json.example .mcp.json
   ```
2. Open `.mcp.json` and replace every `YOUR_..._KEY` / `YOUR_..._ID` with your own values
   (where to get them is below). You can delete the lines with keys you do not need.
3. Claude Code picks up `.mcp.json` in the project root automatically the next time it
   starts in this folder. For OpenCode / Codex, see their MCP documentation; the format is
   the same (`command` + `args` + `env`).

> **Do not commit secrets.** A `.mcp.json` with real keys must never get into git. Check
> that `.mcp.json` and `*token*`/`*secret*` are in `.gitignore` (this kit already lists
> them). Only `.mcp.json.example` with placeholders goes into the repository.

### Step 3. Check that the agent sees the servers

Open the agent in this folder and ask:

> Show which MCP servers are connected and which tools are available.

`paper-search` and `zotero` should appear in the list. If a server is missing, the agent
usually states the reason (package not found, wrong key); fix it according to the message
and restart.

---

## Where to get the keys

### Zotero (needed for the `zotero` server)

Two fields from the config, `ZOTERO_API_KEY` and `ZOTERO_LIBRARY_ID`:

1. Sign in to your Zotero account and open the keys page:
   **<https://www.zotero.org/settings/keys>**.
2. **`ZOTERO_LIBRARY_ID`** is your numeric **userID**; it is shown right on that page
   ("Your userID for use in API calls is …").
3. **`ZOTERO_API_KEY`**: click **Create new private key**
   (<https://www.zotero.org/settings/keys/new>), give it read access (and, to save notes and
   tags, write access to the library as well), and save. The key is shown only once, so
   copy it right away.
4. **`ZOTERO_LIBRARY_TYPE`**: leave `user` for a personal library; for a group library set
   `group` and put the group number into `ZOTERO_LIBRARY_ID`.

The official Zotero Web API documentation: **<https://www.zotero.org/support/dev/web_api/v3/start>**.

**A keyless alternative: local mode.** If Zotero is installed on the same computer, the
server can talk to it directly, without a web key. In that case, instead of the three
fields above, put a single one into `env`:
```json
"env": { "ZOTERO_LOCAL": "true" }
```
and in Zotero itself enable local access: **Settings → Advanced → "Allow other
applications on this computer to communicate with Zotero"**; the desktop app must be
running. Web mode (with a key) works without the app running and from a phone or a
server too; choose whichever suits the situation.

> **Semantic search across the library** (searching by meaning) requires building an
> index once; the agent does this by calling the search-database update. For good
> embeddings the server may use an external model; if it asks for a provider key, that is
> a separate `YOUR_..._KEY`, set up the same way. Basic search by words and tags works
> without it.

### paper-search

Most databases (arXiv, PubMed, CrossRef, OpenAlex, bioRxiv, medRxiv, DOAJ, Europe PMC and
others) work **without a key**; you can remove the `env` block altogether.

Accelerator keys (optional, they raise limits or quality):

- **`SEMANTIC_SCHOLAR_API_KEY`**: a free Semantic Scholar key raises the request limit.
  Request a key at **<https://www.semanticscholar.org/product/api>**.
- **`CORE_API_KEY`**: for the CORE database (an open-access aggregator). Registration:
  **<https://core.ac.uk/services/api>**.

No key needed? Delete the corresponding line from `env`. Never write a real key into
`.mcp.json.example` and never commit it.

---

## How this fits with the skills

The runbooks in `runbooks/` rely on the base skills `lit-search` (search) and `digest`
(a PDF digest that also formats the references). The MCP servers are **accelerators** for
them: with the servers, search and download are faster and cover more databases. The skills
are written so that the basic loop works without MCP as well, on ordinary web search and
file reading. No skills at hand? The runbooks still apply: just describe the steps to the
agent in the words of the runbook.

## Runbooks

- `runbooks/lit-review.md` — the full literature-review pipeline: question → search →
  screening → PDF → digest → synthesis → references → saving to Zotero.
- `runbooks/eresources.md` — access to paywalled resources and your university library
  through the browser, carefully and within the legal frame.
- `runbooks/rag.md` — questions to your own PDF folder (`materials/`), answered with page
  references.
- `runbooks/zotero.md` — search, save and annotate in your own library through the agent.
