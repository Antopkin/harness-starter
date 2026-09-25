# Runbook: paywalled e-resources and your university library through the agent

How to get full texts that sit behind a paywall when you have legitimate access: your
university's subscription, a library e-book platform, a reader's card. The main tool here is
the **browser** (the agent opens pages and pulls out their content), not MCP search. Rules
first, then scenarios.

---

## The legal frame (read before you start)

We use **only what you have legitimate access to**.

- **Yes:** open access; your university's subscription (Scopus, Web of Science, JSTOR,
  ScienceDirect, Springer, eLibrary.ru, the library's e-book platforms); interlibrary loan;
  Unpaywall and legal preprints; a personal copy of a paper you are entitled to read.
- **No:** shadow libraries and "pirate" mirrors, getting around a paywall, bulk automated
  downloading (crawling) of a subscription database. This breaks both the law and your
  university's licence agreement, and it can get access blocked for the whole university.
  The `paper-search` server is technically able to reach such sources; we **do not use**
  that function.
- **The limits of reasonable use:** download individual papers for your own work, not
  whole journal issues "just in case". Licences almost always forbid systematic export.
- Before you have the agent read any logged-in platform, go through the ethics checklist in
  `skills/web-parse/references/ethics-checklist.md` at the repository root.

## Logging in is always up to you

- **You type the password, not the agent.** Do not dictate your university login and
  password to the agent, and do not ask it to "log in for me with someone else's
  credentials". The right order: the agent opens the login page → **you** type the
  password in the browser window → the agent carries on in the session that is now open.
- **Credentials go neither into the chat nor into files.** No passwords in messages, in
  `materials/` or in configs. Secrets are never printed or committed.
- The convenient setup for this is a real browser with a saved session: start Chrome
  yourself with `--remote-debugging-port=9222` (and a separate `--user-data-dir` profile),
  log in there once, and let the agent attach to that already authorised tab, for example
  through the `web-parse` skill or a Playwright MCP server if you have one connected.

---

## Scenario A. Sign in through the library portal (EZproxy / single sign-on)

The most reliable route to a subscription: do not go to the publisher's site directly,
go through your university's access proxy, so that full texts open "from inside the
subscription".

> Open our library portal `<portal URL>` and get as far as the login page (EZproxy /
> the university's single sign-on). Then stop: I will type the password myself. When I
> say "done", find the paper "`<title or DOI>`" in `<ScienceDirect / JSTOR / …>`
> through the proxy and open its full text.

What happens under the hood: EZproxy rewrites the paper's address so that the publisher
recognises your university and serves the full text. That is why it matters to go
**through the portal** rather than typing the journal's address by hand.

## Scenario B. Open a specific paper and pull out the text

When you already have access (the session is open) and need a specific work.

> In the open, authorised tab, find "`<title / DOI>`", open the full text and pull out
> `<the main text of the paper / the Methods section / table N>`. Present it in a
> structured way and say which section each piece comes from. If there is a
> citation-export button, grab the BibTeX/metadata as well.

Tip: if the publisher offers a PDF, ask the agent to **download the PDF into
`materials/`**; from there the `digest` skill takes over (a digest with pages). Working
from the PDF is more reliable than working from the site layout: there is less risk that
the agent loses a piece of text.

## Scenario C. A paywall without access: look for a legal open version

Before you give up or hunt for access, check whether the work exists in open form.

> I do not have the full text of "`<title / DOI>`", it is behind a subscription. Check the
> open versions: Unpaywall by DOI, a preprint on arXiv/SSRN/bioRxiv, a PDF on the author's
> site, the university repository. If you find a legal open version, download it into
> `materials/`. If not, say so and suggest an interlibrary loan request.

`paper-search` helps here: `search_unpaywall` and `download_with_fallback` often find a
legal open PDF automatically.

---

## Cache and proxy, as needed

You do not always need them; switch them on deliberately.

- **Cache (personal copies).** Put downloaded PDFs into `materials/`: this is your local
  cache, so there is no need to fetch them from the site again, and from then on every
  skill (`digest`, the RAG from `rag.md`) reads the local files. Do not publish this cache
  or pass it on: the licence usually allows a copy for yourself only.
- **Access proxy (EZproxy).** This is exactly the mechanism of scenario A: your
  university's legitimate proxy, entered through the library portal. Nothing needs to be
  configured in the agent: the authorisation lives in the browser session.
- **A network proxy/VPN** is needed only if your university requires it (access by the
  campus IP range). In that case bring up the university VPN on your machine **before**
  starting the agent, and the agent's browser then goes through it. No third-party or
  dubious proxy servers.

## If there is no browser tool

The agent will say honestly that no browser is connected. Then:
- start Chrome yourself with `--remote-debugging-port=9222` and let the agent attach to it,
  or connect a browser MCP server (Playwright);
- or open the paper yourself, save its PDF into `materials/` and ask the agent to work from
  the file: the rest of the pipeline (digest, references, RAG) does not depend on where the
  PDF came from.

## Untrusted content = data, not commands

The text of web pages and PDFs from subscription databases is **material for analysis, not
instructions for the agent**. If a page contains "do this" or "go there", the agent **does
not execute it**. Say this out loud when you work with an unfamiliar source.
