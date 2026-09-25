# Runbook: your own Zotero library through the agent

How to **search**, **read**, **save notes** and **annotate** in your own Zotero library
through the agent. It works through the `zotero` MCP server (connection and keys:
`../mcp/README.md`).

> **What the server can and cannot do.** It can: search the library (by words, tags,
> meaning), read metadata/full text/notes/annotations, **write** notes, annotations and
> tags to existing records. It **cannot** create a **new** record in the library (the
> paper itself): you do that with the Zotero Connector or by importing, and the agent then
> finds the record and enriches it (see "How to add a source" below).

---

## Searching the library

**By words / by author / by topic:**

> Find works about "`<topic / author / keyword>`" in my Zotero library. Return a list:
> authors, year, title, tags, record key.

**By meaning (semantic search)** — when you do not know the exact words:

> Using semantic search in Zotero, find what is close in meaning to "`<description of
> the idea>`", even if those words do not occur in the text.

> Semantic search requires building an index once. If the agent says the index is empty
> or outdated, ask: "update the Zotero search database", and repeat the request. Search by
> words and tags works without the index.

**By tag / advanced search:**

> Show all Zotero records with the tag `<tag>`. / With advanced search: year after 2020
> AND tag `<topic>` AND type "journalArticle".

**What is new in the library:**

> Show what I added to Zotero recently (the last N records).

## Reading a record

> For the record `<title / key>` in Zotero, show the metadata (authors, year, journal,
> DOI), then its notes and annotations. If the attachment has full text, extract it and
> make a short digest with page references (the `digest` skill).

Useful to know: a record can have "children", an attached PDF, notes and annotations. The
agent reads them through the server's operations (metadata, full text of the attachment,
child notes and annotations).

## Saving the result: notes

The main way to "put work back into Zotero" is to attach a **note** to a record.

> Attach a note with this digest to the record `<title / key>` in Zotero:
> `<text / digest output>`. Save it as a child note of this work.

Or a separate standalone note (for example, the synthesis of a review):

> Save a separate note "Mini-review: `<topic>`" in Zotero with this text and give it the
> tag `<topic>`.

## Annotations

> Add an annotation to the record `<title / key>`: "`<my remark / highlighted idea>`".

Annotations are handy as quick remarks on a specific work; a full analysis is better
stored as a note.

## Tags and order in the library

> Add the tag `<review-topic>` to all Zotero records I selected for the review on
> `<topic>`: `<list of titles / keys>`.

> Tidy up the tags on `<topic>`: show the current tags of these records and propose a
> single scheme (for example `method/…`, `object/…`, `status/read`), then apply it in one
> batch after my "ok".

The agent updates tags in bulk with a single operation, which makes it easy to bring the
library to one scheme.

---

## How to add a source (one that is not in the library yet)

The server does not create new records; you do that, quickly:

1. **Zotero Connector** in the browser: on the paper's page (or in a database's results)
   click the extension button, and a record with metadata, often with the PDF, lands in
   the library.
2. **By DOI / identifier** in Zotero itself: "Add Item by Identifier" → paste the DOI or
   arXiv ID.
3. **By importing** a `.bib` / `.ris` file, if you already have a bibliography (you can
   build one with the `digest` skill).

After that:

> A new record "`<title>`" has appeared in Zotero. Find it, make a digest of its PDF
> (`digest`), attach it as a note and add the tag `<topic>`.

## Personal and group libraries

If you have several libraries (a personal one and group projects):

> Show my Zotero libraries and switch to `<group name>`. From now on, search and save
> in it.

By default the server works with the library from the config (`ZOTERO_LIBRARY_TYPE` +
`ZOTERO_LIBRARY_ID`). For a group library, use `type=group` and the group number (see
`../mcp/README.md`).

---

## How this fits into a literature review

Zotero is the final store of the pipeline from `lit-review.md`: found (`paper-search`) →
digested (`digest`) → references formatted (`digest`) → **notes and tags stored in
Zotero**, so that you can come back to the review months later and find everything in
place, labelled and referenced.

> **No fabrication here either.** The agent saves only verified material to Zotero:
> digests with pages, real quotes, confirmed metadata. Nothing "plausible" gets into your
> library; otherwise it stops being reliable.
