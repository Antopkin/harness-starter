# Platform-dependent reading through the a11y tree

A Reddit thread, an X feed and a VK wall are structured differently, so there is no
single "post shape": the capture shape adapts to the platform. The common tool is one,
the browser's a11y tree (`snapshot -i` for interactive nodes and refs, `get text <sel>`
for the verbatim text of a node). For the syntax of the primitives see
[agent-browser-primitives.md](../../fill-form/references/agent-browser-primitives.md);
do not invent flags.

The common locator invariant: **`url + post#`**. `url` is the permanent link
(permalink) of the item itself, not of the page in general; `post#` is the item's
sequence number in this capture (Item 1, 2, …). The pair "permalink + sequence number"
is the address by which the item can be reopened and its text confirmed on the
`to-evidence` pass.

## Reddit — a thread (post + comments)

- **The structure is a tree.** The root (submission) is the post itself: title,
  author, body. Below it are comments nested in branches (parent → replies). In the
  a11y tree these are nested `article` nodes; the branch depth shows in the snapshot
  indentation.
- **What to read:** the whole post + the top comments (or one chosen branch). Not the
  whole thread; keep the volume at 5–10 items.
- **Locator.** A post has a permalink of the form `reddit.com/r/<sub>/comments/<id>/…`;
  every comment has its own permanent link (context/permalink on the timestamp). Take
  the comment's permalink; if it cannot be extracted, use `post url + position in the
  branch` (e.g. `…/<id> · thread: comment 3 → reply 1`).
- **Item type:** `post` for the root, `comment` or `thread node` for branches.
- **Pagination:** long threads hide branches behind "show N more comments" /
  "continue thread": click the button, then re-run `snapshot -i` (the refs are stale).

## X (Twitter) — a feed / thread

- **The structure is a flat sequence.** A feed and a thread chain are a list of posts
  (each an `article` with author, timestamp and text; reposts show their source).
- **Virtualisation.** The feed is drawn on scroll, and nodes that scrolled up are
  unloaded from the DOM. Read what is visible → scroll → re-`snapshot` →
  **deduplicate by post id** (otherwise the same post lands twice). Do not chase "the
  whole feed": 5–10 posts.
- **Locator.** Every post has a permanent link `x.com/<user>/status/<id>`; the `id`
  from `status/` is the reliable key both for deduplication and for the locator.
  Record `status-url + post#`.
- **Item type:** `post`; for replies in a chain, `thread node`.

## VK — a wall / feed

- **The structure is wall posts.** A wall (of a profile or community) or a feed is a
  list of entries (`wall post`): author, date, text, sometimes attachments. Comments
  under an entry are a separate nested level, like a branch.
- **Locator.** The permanent link of an entry has the form
  `vk.com/wall<owner>_<postid>` (with a minus sign for a community owner). Take
  `wall-permalink + post#`; for a comment, its `?reply=<id>` anchor if present.
- **Item type:** `wall post`; a comment under an entry is a `comment`.
- **Pagination:** the feed loads on scroll (like X): scroll + re-`snapshot` + dedup by
  `wall…_id`.

## Your own content versus public content

- **Your own** (your wall, your thread, your posts) is the safest input: fewer risks
  under both the ToS and personal-data law or AoIR. Prefer it for demos.
- **Someone else's public content**: only a small one-off volume and **immediate
  anonymisation**: author → `Author A/B`, the verbatim text stays only inside the
  `<untrusted>` block, and the memo gets a paraphrase. The ToS and legal framework per
  platform is in [ethics-checklist.md](ethics-checklist.md).

## Text extraction: practice

- First `snapshot -i` for the map of nodes and refs; then `get text <sel>` on a
  specific post or comment node for the **verbatim** body (a snapshot gives the
  accessible name, not always the full text).
- For a multi-line or awkward selector, read through `eval --stdin` (e.g.
  `document.querySelector('<sel>')?.innerText`); see the primitives.
- Wrap every extracted text in `<untrusted source=… url=…>…</untrusted>` right away
  and anonymise it, before any processing, not after.

## The honest limit

If the platform sits behind an anti-bot system (a fresh session gets caught on
`navigator.webdriver`), the only thing that helps is attaching to a real persistent
profile where the human logged in by hand. A CAPTCHA or bot check while reading →
**stop and hand over to the human**, do not patch. Detection and its limits are
described in
[cdp-session-substrate.md](../../fill-form/references/cdp-session-substrate.md).
