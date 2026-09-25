#!/usr/bin/env python3
"""Regenerate OpenCode's project agent directory from agents/.

One source of truth, one direction. `agents/*.md` in the current directory is
authoritative; `.opencode/agent/` next to it is derived and must never be
hand-edited. A symlink would have been simpler and does not work: the two tools
disagree about frontmatter. Claude Code writes `tools:` and `model:`; OpenCode
reads `mode:` and a `permission:` object and knows neither of the other two.

Why regenerate instead of copying once: hand-made copies drift. Agents you
retire keep being registered, bodies you rewrote keep their old text, and
nothing tells you. Run this after every change to agents/.

Usage, from the repo root (everything is relative to the current directory;
nothing outside it is read or written):
    python3 hooks/opencode-agents-sync.py            # show the plan
    python3 hooks/opencode-agents-sync.py --apply    # write it

Nothing is deleted. A generated file that no longer has a source is moved to
`.opencode/agent-retired/`, because a file this script did not create is not
this script's to destroy.

`tools:` and `disallowedTools:` are read as a comma list, a `[a, b]` flow list
or a block list of `- a` lines. A role whose restriction cannot be translated
(an empty `tools:`, or a disallowed tool with no OpenCode mapping below) is
never emitted as an unrestricted agent: it is reported on stderr, any earlier
generated copy is retired, and the script exits 1.
"""

from __future__ import annotations

import re
import shutil
import sys
from pathlib import Path

SRC = Path("agents")
DEST = Path(".opencode") / "agent"
# A SIBLING of DEST, never a child: OpenCode walks the agent directory
# recursively, and a dot-prefixed subdirectory is not a hiding place, so
# retired agents parked inside DEST would still be registered.
RETIRED = DEST.parent / "agent-retired"

BANNER = (
    "<!-- generated from agents/ by hooks/opencode-agents-sync.py — do not edit -->"
)

# Tools that let an agent change something. An agent whose Claude Code `tools:`
# list omits them is read-only by design, and the generated file says so in
# OpenCode's own vocabulary. The mapping only ever takes permission away: a
# tool absent from this table is left at OpenCode's default.
WRITE_TOOLS = {"Write": "write", "Edit": "edit", "Bash": "bash", "NotebookEdit": "edit"}


class ToolsError(ValueError):
    """A role's tool restriction this script cannot translate faithfully."""


def split_frontmatter(text: str) -> tuple[dict[str, str], dict[str, list[str]], str]:
    """Top-level `key: value` pairs, plus the items of any YAML block list
    (indented or bare `- x` lines under a key with an empty value)."""
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if not m:
        raise ValueError("no frontmatter")
    keys: dict[str, str] = {}
    lists: dict[str, list[str]] = {}
    last = None
    for line in m.group(1).split("\n"):
        item = re.match(r"^\s*-\s*(.*?)\s*$", line)
        if item and last is not None:
            lists.setdefault(last, []).append(item.group(1).strip("'\""))
            continue
        if ":" in line and not line.startswith((" ", "\t", "-")):
            k, _, v = line.partition(":")
            last = k.strip()
            keys[last] = v.strip()
        elif not line.startswith((" ", "\t")):
            last = None
    return keys, lists, m.group(2)


def tool_set(
    keys: dict[str, str], lists: dict[str, list[str]], key: str
) -> set[str] | None:
    """The tools named under `key` as a set, None when the key is absent.
    Reads `a, b`, a flow list `[a, b]` and a block list of `- a` lines."""
    if key not in keys:
        return None
    raw = keys[key]
    if raw.startswith("[") and raw.endswith("]"):
        raw = raw[1:-1]
    names = [t.strip().strip("'\"") for t in raw.split(",")] + lists.get(key, [])
    names = [t for t in names if t]
    if not names:
        # `tools:` with nothing under it cannot be told apart from a list this
        # parser failed to read; emitting an unrestricted agent would be wrong.
        raise ToolsError(f"{key}: is empty or in a form this script cannot read")
    return set(names)


def translate(keys: dict[str, str], lists: dict[str, list[str]], body: str) -> str:
    out = [
        "---",
        f"name: {keys.get('name', '')}",
        f"description: {keys.get('description', '')}",
    ]
    out.append("mode: subagent")

    granted = tool_set(keys, lists, "tools") or set()
    disallowed = tool_set(keys, lists, "disallowedTools") or set()
    # A disallowed tool the table cannot express in OpenCode's vocabulary would
    # silently stay allowed there, so such a role is refused rather than widened.
    unmapped = sorted(t for t in disallowed if t not in WRITE_TOOLS)
    if unmapped:
        raise ToolsError(
            f"disallowedTools: names {', '.join(unmapped)}, which has no OpenCode mapping here"
        )
    denied = {v for k, v in WRITE_TOOLS.items() if k in disallowed}
    if granted and "*" not in granted:
        # Deny an OpenCode permission only when no granted tool maps to it: Edit and
        # NotebookEdit share "edit", so granting Edit alone must keep edit allowed.
        kept = {WRITE_TOOLS[k] for k in granted if k in WRITE_TOOLS}
        denied |= set(WRITE_TOOLS.values()) - kept
    if denied:
        out.append("permission:")
        out.extend(f"  {d}: deny" for d in sorted(denied))

    out += ["---", "", BANNER, ""]
    return "\n".join(out) + body.lstrip("\n")


def main() -> int:
    apply = "--apply" in sys.argv
    if not SRC.is_dir():
        print(
            f"source missing: {SRC.resolve()} (run this from the repo root)",
            file=sys.stderr,
        )
        return 1
    if apply:
        DEST.mkdir(parents=True, exist_ok=True)

    sources = sorted(SRC.glob("*.md"))
    wrote = same = skipped = errors = 0
    refused: set[str] = set()
    for s in sources:
        try:
            keys, lists, body = split_frontmatter(s.read_text(encoding="utf-8"))
        except ValueError:
            skipped += 1
            print(f"SKIP (no frontmatter): {s.name}", file=sys.stderr)
            continue
        d = DEST / s.name
        try:
            new = translate(keys, lists, body)
        except ToolsError as e:
            # Never fall back to an unrestricted agent. A copy generated earlier
            # may be wider than the role now allows, so it is retired, not kept.
            errors += 1
            refused.add(s.name)
            print(f"ERROR (not generated): {s.name}: {e}", file=sys.stderr)
            continue
        if d.exists() and d.read_text(encoding="utf-8") == new:
            same += 1
            continue
        wrote += 1
        print(f"{'WRITE ' if apply else 'WOULD WRITE '}{s.name}")
        if apply:
            d.write_text(new, encoding="utf-8")

    known = {s.name for s in sources} - refused
    orphans = (
        [p for p in DEST.glob("*.md") if p.name not in known] if DEST.is_dir() else []
    )
    for p in orphans:
        print(
            f"{'RETIRE' if apply else 'WOULD RETIRE'} {p.name} "
            f"({'tools not translatable' if p.name in refused else 'no source in agents/'})"
        )
        if apply:
            RETIRED.mkdir(parents=True, exist_ok=True)
            shutil.move(str(p), str(RETIRED / p.name))

    print(
        f"\nsources={len(sources)} written={wrote} unchanged={same} skipped={skipped} "
        f"retired={len(orphans)} errors={errors} apply={int(apply)}"
    )
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
