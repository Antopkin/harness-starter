#!/usr/bin/env python3
"""Compute the frontier of a wayfinder effort.

Usage: frontier.py <effort_dir> [--tree]

Reads every T-*.md ticket in <effort_dir> and prints the frontier: the sorted
ids of tickets with status "open" whose every blocked_by id is "closed" or
"out-of-scope", one per line. MAP.md must exist in <effort_dir>, which is how a
wrong directory is told apart from an effort; its content and any other files
are ignored.

Exit codes:
  0  the frontier is not empty (ids on stdout); also used, with nothing on
     stdout and "done" on stderr, when no open or claimed ticket remains
  2  <effort_dir> is not a directory, has no MAP.md or holds no T-*.md ticket
     (most likely a wrong directory, never a finished effort); or a ticket
     without valid frontmatter, an unknown blocked_by id, a duplicate id, a
     status or type or mode outside its enum, or a dependency cycle (the cycle
     is named on stderr)
  3  the frontier is empty while open or claimed tickets remain ("stuck")

--tree prints the dependency tree instead: each ticket under the tickets that
block it, roots first, after the same validation (exit 2 on invalid tickets).

Standard library only.

Adapted from mattpocock/skills@c55ee46 engineering/wayfinder (MIT).
"""

import re
import sys
from pathlib import Path

STATUSES = {"open", "claimed", "closed", "out-of-scope"}
TYPES = {"research", "grill", "spike", "task"}
MODES = {"afk", "hitl"}
REQUIRED = ("id", "title", "type", "mode", "status")
DONE = {"closed", "out-of-scope"}


def strip_quotes(v):
    v = v.strip()
    if len(v) >= 2 and v[0] == v[-1] and v[0] in "'\"":
        return v[1:-1].strip()
    return v


def parse_list(raw):
    """Parse a blocked_by value: flow list, scalar or empty."""
    raw = raw.strip()
    if raw in ("", "~", "null", "[]"):
        return []
    if raw.startswith("["):
        if not raw.endswith("]"):
            raise ValueError(f"unterminated flow list: {raw}")
        inner = raw[1:-1]
        return [strip_quotes(x) for x in inner.split(",") if strip_quotes(x)]
    return [strip_quotes(raw)]


def parse_ticket(path):
    text = path.read_text(encoding="utf-8").replace("\r\n", "\n")
    m = re.match(r"---\n(.*?)\n---[ \t]*(\n|$)", text, re.S)
    if not m:
        raise ValueError(
            "no frontmatter block (the file must start with --- and close it with ---)"
        )
    fields, last_key = {}, None
    for n, line in enumerate(m.group(1).split("\n"), 2):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        item = re.match(r"^\s+-\s*(.*)$", line) or re.match(r"^-\s+(.*)$", line)
        if item:
            if (
                last_key != "blocked_by"
                or fields["blocked_by"]
                and not isinstance(fields["blocked_by"], list)
            ):
                raise ValueError(f"line {n}: list item outside an empty blocked_by")
            if not isinstance(fields["blocked_by"], list):
                fields["blocked_by"] = []
            value = strip_quotes(item.group(1))
            if value:
                fields["blocked_by"].append(value)
            continue
        kv = re.match(r"^([A-Za-z_][\w-]*):(.*)$", line)
        if not kv:
            raise ValueError(f"line {n}: not a 'key: value' line: {line!r}")
        key, value = kv.group(1), kv.group(2).strip()
        if key in fields:
            raise ValueError(f"line {n}: duplicate key {key}")
        fields[key] = value
        last_key = key
    missing = [k for k in REQUIRED if not strip_quotes(str(fields.get(k, "")))]
    if missing:
        raise ValueError(f"missing or empty field(s): {', '.join(missing)}")
    blocked = fields.get("blocked_by", "")
    blocked = blocked if isinstance(blocked, list) else parse_list(blocked)
    t = {k: strip_quotes(fields[k]) for k in REQUIRED}
    t["blocked_by"] = blocked
    t["claimed_by"] = strip_quotes(fields.get("claimed_by", "") or "")
    t["file"] = path.name
    for key, enum in (("status", STATUSES), ("type", TYPES), ("mode", MODES)):
        if t[key] not in enum:
            raise ValueError(f"{key} {t[key]!r} is not one of {'|'.join(sorted(enum))}")
    return t


def find_cycle(tickets):
    """Return one dependency cycle as a list of ids, or None."""
    WHITE, GREY, BLACK = 0, 1, 2
    colour = {i: WHITE for i in tickets}
    stack = []

    def visit(i):
        colour[i] = GREY
        stack.append(i)
        for b in tickets[i]["blocked_by"]:
            if colour[b] == GREY:
                return stack[stack.index(b) :] + [b]
            if colour[b] == WHITE:
                found = visit(b)
                if found:
                    return found
        stack.pop()
        colour[i] = BLACK
        return None

    for i in sorted(tickets):
        if colour[i] == WHITE:
            found = visit(i)
            if found:
                return found
    return None


def load(effort_dir):
    errors, tickets = [], {}
    for path in sorted(effort_dir.glob("T-*.md")):
        if not path.is_file():
            continue
        try:
            t = parse_ticket(path)
        except (ValueError, UnicodeDecodeError) as e:
            errors.append(f"{path.name}: invalid frontmatter: {e}")
            continue
        if t["id"] in tickets:
            errors.append(
                f"{path.name}: duplicate id {t['id']} (also in {tickets[t['id']]['file']})"
            )
            continue
        tickets[t["id"]] = t
    for i in sorted(tickets):
        for b in tickets[i]["blocked_by"]:
            if b not in tickets:
                errors.append(f"{tickets[i]['file']}: unknown blocked_by id {b}")
    if not errors:
        cycle = find_cycle(tickets)
        if cycle:
            errors.append("dependency cycle: " + " -> ".join(cycle))
    return tickets, errors


def print_tree(tickets):
    unblocks = {i: [] for i in tickets}
    for i, t in tickets.items():
        for b in t["blocked_by"]:
            unblocks[b].append(i)

    def show(i, depth, seen):
        t = tickets[i]
        again = " (see above)" if i in seen else ""
        print(f"{'  ' * depth}{i} [{t['status']}] {t['title']}{again}")
        if i in seen:
            return
        seen.add(i)
        for c in sorted(unblocks[i]):
            show(c, depth + 1, seen)

    seen = set()
    for root in sorted(i for i, t in tickets.items() if not t["blocked_by"]):
        show(root, 0, seen)


def main(argv):
    args = [a for a in argv if a != "--tree"]
    if len(args) != 1:
        print("usage: frontier.py <effort_dir> [--tree]", file=sys.stderr)
        return 2
    effort_dir = Path(args[0])
    if not effort_dir.is_dir():
        print(f"not a directory: {effort_dir}", file=sys.stderr)
        return 2
    if not (effort_dir / "MAP.md").is_file():
        print(
            f"no MAP.md in {effort_dir}: not a wayfinder effort directory",
            file=sys.stderr,
        )
        return 2
    tickets, errors = load(effort_dir)
    if errors:
        for e in errors:
            print(e, file=sys.stderr)
        return 2
    if not tickets:
        print(
            f"no T-*.md ticket in {effort_dir}: a wrong directory, or tickets not yet"
            " created; an effort is done only when its tickets are all closed",
            file=sys.stderr,
        )
        return 2
    if "--tree" in argv:
        print_tree(tickets)
        return 0
    frontier = sorted(
        i
        for i, t in tickets.items()
        if t["status"] == "open"
        and all(tickets[b]["status"] in DONE for b in t["blocked_by"])
    )
    if frontier:
        print("\n".join(frontier))
        return 0
    live = sorted(i for i, t in tickets.items() if t["status"] in ("open", "claimed"))
    if live:
        print("stuck")
        print(
            "open or claimed with no takeable ticket: " + ", ".join(live),
            file=sys.stderr,
        )
        return 3
    print("done: no open or claimed tickets", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
