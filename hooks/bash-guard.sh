#!/bin/sh
# PreToolUse Bash guard — block irreversible / destructive commands.
#
# Hardened 2026-07-03: the previous inline pattern was bypassable:
#   * `git -C <path> reset --hard`  (args between `git` and `reset`)
#   * `git push origin main --force` (args between `push` and `--force`)
#   * `git commit --no-verify`       (not matched at all)
# New git branches allow arbitrary non-separator args between the verb and the
# dangerous flag, and --no-verify is caught.
# Hardened 2026-07-03 (audit): the rm branch previously listed only the literals
# -rf/-fR/-Rf, so `rm -fr` (force-recursive, f-before-r combined) AND `rm -R -f`
# (uppercase R, spaced) fell through. sudo branch preserved verbatim.
# Hardened 2026-09-25 (review): the whole-command regexes for rm, reset, push
# and commit still walked past `rm -v -rf`, `rm x -rf`, `git reset -q --hard`,
# `git push origin +main`, `git commit -n` and long-option prefixes, so those
# rules now live in the per-word pass below, next to clean, checkout and switch.
#
# Wiring: .claude/settings.json runs this as bash "$CLAUDE_PROJECT_DIR/hooks/bash-guard.sh".
# Exit 2 blocks the call and shows stderr to the agent; exit 0 lets it through.
# Without jq the guard cannot read its input, so it refuses every command until
# jq is installed rather than silently letting everything pass. A jq that is
# present but fails is treated the same way.
command -v jq >/dev/null 2>&1 || { echo "guard inactive: install jq (brew install jq / apt install jq)" >&2; exit 2; }

CMD=$(jq -r '.tool_input.command' 2>/dev/null) || { echo "guard: cannot parse hook input" >&2; exit 2; }
[ "$CMD" = "null" ] && exit 0
[ -z "$CMD" ] && exit 0

PAT='(--no-verify|sudo[[:space:]])'
if printf '%s\n' "$CMD" | grep -qE "$PAT"; then
  echo "BLOCKED: dangerous command: $CMD" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Added 2026-09-25 (after mattpocock/skills git-guardrails, MIT): per-segment
# rules. Upstream matched fixed strings over the whole command, which a
# `git -C <dir>` or a `-c k=v` between `git` and the verb walks straight past.
# Here the command is cut into segments on ; && || | & ( ) ` and newlines, each
# segment is split into words with quotes and backslashes stripped (so '.' and
# "." read as .), and EVERY word whose basename is `rm` or `git` is analysed:
# leading VAR=1 assignments, `bash -c '...'` and `xargs rm` are covered by that
# scan, and git's global options (-C <dir>, -c <k=v>, --git-dir <d>,
# --no-pager ...) are skipped before the verb is read. Every later word of the
# segment counts, wherever it stands, because rm and git both accept options
# after their operands. Then:
#   * rm is refused when its words ask for both recursion (r or R in a short
#     cluster, --recursive or a prefix of it) and force (f in a short cluster,
#     --force or a prefix of it), whether the two come together or apart.
#   * git reset is refused when any word after the verb starts with --h, so
#     --hard and every abbreviation of it are caught. Only --help, spelled out
#     exactly, is let through, so git reset --help still opens the manual.
#   * git push is refused on f in a short cluster (-f, -uf), on --force and its
#     prefixes down to --fo, and on a refspec that starts with +, which forces
#     that one ref. --force-with-lease stays allowed.
#   * git commit is refused on n in a short cluster (-n, -an) and on any prefix
#     of --no-verify from --no-veri on (--no-ver is ambiguous with --no-verbose,
#     and git rejects it). A cluster stops at the first option that takes a
#     value (m, F, C, c, t), so the text of -mnote is not read, and a value
#     option at the end of a cluster takes the next word. u and S end a cluster
#     too, but their optional value is attached (-uno, -Skey), so the next word
#     is read as an option again: -u -n and -S -n are refused. The value of -m,
#     -F, --message, --file and the other value options is skipped as one shell
#     word, quotes included, so git commit -m "fix -n handling" is allowed.
#   * git commit and git push are refused when a global -c (or --config-env)
#     sets core.hooksPath, in any letter case: that switches the hooks off as
#     surely as --no-verify does.
#   * git checkout / git switch are refused on f in a short cluster, on --force
#     and its prefixes down to --f, and on --discard-changes and its prefixes
#     down to --di. A cluster stops at b, B, c or C, whose value is a branch.
#     (git push keeps --fo as its shortest --force: there --f is ambiguous.)
#   * git clean is refused unless it carries -n (alone or in a short cluster such
#     as -nd) or --dry-run before any `--`. So every force spelling, every
#     long-option prefix (--forc) and a -c clean.requireForce=false override are
#     refused alike: without a dry-run flag there is no safe clean.
#   * git checkout / git restore are refused when a pathspec word is ., ./, :/
#     or *, with or without a preceding --. git restore --staged (or -S) alone
#     only touches the index and stays allowed; any worktree mode (the default,
#     --worktree or -W) with such a pathspec is refused.
# Hardened the same day after a review walked past it five ways. --attr-source
# and --super-prefix take a value word too, so that value is no longer read as
# the verb. In git clean a short cluster ending in e (-fe) swallows the next word
# as its exclude pattern, so a -n there is not a dry run, and --no-dry-run (or
# any prefix from --no-d on) switches dry-run back off. In git restore any
# abbreviation of --worktree counts as worktree mode and --no-staged undoes
# --staged. Whole-tree pathspecs are now read the way the shell and git read
# them: a backslash-newline continuation is joined (both the raw and the joined
# text are scanned), the $ of $'.' is dropped with the quotes, a pathspec is
# normalised (// and ./ segments collapsed, x/.. segments resolved, so ./.,
# .// and src/.. all count as .), a :(top) or :/ magic with nothing after it is
# the whole tree (the parentheses of a :(magic) are kept from cutting the
# segment), and --pathspec-from-file counts as whole-tree, since the guard
# cannot see what the file lists.
# Hardened again the same day (last review round). Exclude magic is whole-tree
# too: a pathspec made only of excludes (:!x, :^x, :(exclude)x) means "the whole
# tree except x", so every short magic with ! or ^ and every :(...) magic that
# names exclude counts. So does a pattern made only of *, ?, [ and ] after
# normalisation (*, **, ?*), which matches every path. A :(...) magic without
# top is read like the bare pathspec after it, so :(icase). counts as . does.
# Owner decisions of 2026-09-25, applied before the per-word pass. A heredoc
# body is data when its delimiter is quoted (<<'X', <<"X", <<-'X') and no word
# of the marker line names a shell or an interpreter (sh, bash, zsh, dash, ksh,
# fish, ssh, eval, source, ., xargs, env, sudo, python*, node, deno, bun, perl,
# ruby, php, osascript, awk, sed). Every word of the line is checked, not only
# the one before <<, so cat <<'X' | bash counts as an interpreter too. Such a
# body is dropped, which lets git commit -F - <<'MSG' carry a message that
# names the very commands it explains. The marker line is scanned in full, text
# after the marker included, and so is everything after the terminator line.
# The body of an unquoted delimiter is scanned, since the shell expands $(...)
# in it, and the body an interpreter reads is scanned with its quotes, commas
# and brackets turned into spaces, so os.system('...') or a ["rm", ...] list is
# read as the command it runs. In a git commit segment the value of -m, -F,
# --message and --file is data up to its own end (its closing quote, or the
# end of an unquoted word): text after it is scanned as usual, and whatever
# follows a $( or a backtick inside the value is read as a command, heredoc
# rules included. Backslash-newline joins are made after this step, so a
# continuation cannot hide behind a heredoc terminator.
# The price of scanning every `rm` and `git` word is the same bargain as the
# rest of this file: an echo, or a commit message passed any other way, that
# spells one of these commands out is refused too. Known limit: a git alias defined with
# -c alias.x=... is not expanded. If awk itself fails, the guard fails closed.
VERDICT=$(printf '%s\n' "$CMD" | awk -v sq="'" '
function unq(t) { gsub("[$][" sq "\"]", "", t); gsub(sq, "", t); gsub(/"/, "", t); gsub(/\\/, "", t); return t }
function norm(t,   np, pt, st, ns, i, out) {
  gsub(/\/\/+/, "/", t)
  while (t ~ /^\.\/./) t = substr(t, 3)
  while (t ~ /\/\.\//) sub(/\/\.\//, "/", t)
  sub(/\/\.$/, "/", t)
  if (substr(t, 1, 1) != "/" && t ~ /(^|\/)\.\.(\/|$)/) {
    np = split(t, pt, "/"); ns = 0
    for (i = 1; i <= np; i++) {
      if (pt[i] == "" || pt[i] == ".") continue
      if (pt[i] == ".." && ns > 0 && st[ns] != "..") { ns--; continue }
      st[++ns] = pt[i]
    }
    if (ns == 0) return "."
    out = st[1]; for (i = 2; i <= ns; i++) out = out "/" st[i]
    return out
  }
  return t
}
function wholetree(t,   r, p, mg, top, ch, g) {
  r = t
  if (substr(r, 1, 2) == ":\001") {
    p = index(r, "\002"); if (!p) return 0
    mg = "," substr(r, 3, p - 3) ","
    if (index(mg, "exclude")) return 1
    top = (mg ~ /,top,/)
    r = substr(r, p + 1); if (r == "") return top
  } else if (substr(r, 1, 1) == ":" && length(r) > 1 && index("/!^", substr(r, 2, 1))) {
    p = 2
    while (p <= length(r)) {
      ch = substr(r, p, 1)
      if (!index("/!^", ch)) break
      if (ch == "!" || ch == "^") return 1
      p++
    }
    r = substr(r, p); sub(/^:/, "", r); if (r == "") return 1
  }
  r = norm(r)
  if (r == "." || r == "./" || r == ":/") return 1
  g = r; gsub(/[*?]/, "", g); gsub(/\[/, "", g); gsub(/\]/, "", g)
  return (r != "" && g == "")
}
function isprefix(a, full, min) { return (length(a) >= min && substr(full, 1, length(a)) == a) }
# 1 when the short cluster a (e.g. -uf) holds bad before any char of vstop or
# estop. A vstop char takes a value: at the very end of the cluster it takes
# the next word (valnext). An estop char ends the cluster and takes nothing.
function cluster(a, bad, vstop, estop,   c, p, ch) {
  c = substr(a, 2); valnext = 0
  for (p = 1; p <= length(c); p++) {
    ch = substr(c, p, 1)
    if (index(bad, ch)) return 1
    if (index(vstop, ch)) { if (p == length(c)) valnext = 1; return 0 }
    if (estop != "" && index(estop, ch)) return 0
  }
  return 0
}
# Advance the global quote state Q ("", s, d or a for $'...') through raw word t.
function qwalk(t,   i, ch, L) {
  L = length(t)
  for (i = 1; i <= L; i++) {
    ch = substr(t, i, 1)
    if (Q == "") {
      if (ch == "\\") i++
      else if (ch == sq) Q = "s"
      else if (ch == "\"") Q = "d"
      else if (ch == "$" && substr(t, i + 1, 1) == sq) { Q = "a"; i++ }
    } else if (Q == "s") { if (ch == sq) Q = "" }
    else if (ch == "\\") i++
    else if ((Q == "d" && ch == "\"") || (Q == "a" && ch == sq)) Q = ""
  }
}
# The last raw word of the shell word that starts at raw word k: a quoted value
# with spaces in it spans several raw words.
function wend(w, k, n) { qwalk(w[k]); while (Q != "" && k < n) { k++; qwalk(w[k]) } return k }
# 1 when a is a long git commit option (or an abbreviation git accepts or
# rejects as ambiguous) whose required value is the next word.
function cvlong(a) {
  return (isprefix(a, "--message", 4) || isprefix(a, "--file", 5) || isprefix(a, "--fixup", 5) ||
          isprefix(a, "--template", 4) || isprefix(a, "--trailer", 4) || isprefix(a, "--author", 4) ||
          isprefix(a, "--date", 4) || isprefix(a, "--reuse-message", 5) || isprefix(a, "--reedit-message", 5) ||
          isprefix(a, "--squash", 4) || isprefix(a, "--cleanup", 4) || isprefix(a, "--pathspec-from-file", 12))
}
function scan(s,   seg, nseg, i, n, w, u, k, b, j, o, verb, dry, m, a, c, p, staged, wt, hit, rr, ff, hp, e) {
  while (match(s, /:\([^() \t]*\)/)) s = substr(s, 1, RSTART) "\001" substr(s, RSTART + 2, RLENGTH - 3) "\002" substr(s, RSTART + RLENGTH)
  gsub(/&&|\|\||[;|&()`]/, "\n", s)
  nseg = split(s, seg, "\n")
  for (i = 1; i <= nseg; i++) {
    n = split(seg[i], w)
    for (k = 1; k <= n; k++) u[k] = unq(w[k])
    for (k = 1; k <= n; k++) {
      b = u[k]; sub(/.*\//, "", b)
      if (b == "rm") {
        rr = 0; ff = 0
        for (m = k + 1; m <= n; m++) {
          a = u[m]
          if (a ~ /^--/) { if (isprefix(a, "--recursive", 3)) rr = 1; if (isprefix(a, "--force", 3)) ff = 1 }
          else if (a ~ /^-./) { c = substr(a, 2); if (c ~ /[rR]/) rr = 1; if (index(c, "f")) ff = 1 }
        }
        if (rr && ff) { print "rm recursive and forced"; exit }
        continue
      }
      if (b != "git") continue
      j = k + 1; hp = 0
      while (j <= n && substr(u[j], 1, 1) == "-") {
        o = u[j]
        if ((o == "-c" || o == "--config-env") && tolower(u[j + 1]) ~ /^core\.hookspath/) hp = 1
        if (tolower(o) ~ /^--config-env=core\.hookspath/) hp = 1
        if (o == "-C" || o == "-c" || o == "--git-dir" || o == "--work-tree" || o == "--namespace" || o == "--config-env" || o == "--attr-source" || o == "--super-prefix") j += 2
        else j++
      }
      if (j > n) continue
      verb = u[j]
      if (hp && (verb == "commit" || verb == "push")) { print "git -c core.hooksPath on " verb; exit }
      if (verb == "reset") {
        for (m = j + 1; m <= n; m++) if (u[m] ~ /^--h/ && u[m] != "--help") { print "git reset --hard"; exit }
      }
      if (verb == "push") {
        for (m = j + 1; m <= n; m++) {
          a = u[m]
          if (a ~ /^--/) { if (isprefix(a, "--force", 4)) { print "git push --force"; exit } }
          else if (a ~ /^-./) { if (cluster(a, "f", "o", "")) { print "git push --force"; exit }; if (valnext) m++ }
          else if (substr(a, 1, 1) == "+") { print "git push of a forced +refspec"; exit }
        }
      }
      if (verb == "commit") {
        Q = ""
        for (m = j + 1; m <= n; m++) {
          a = u[m]; e = wend(w, m, n)
          if (a ~ /^--no-veri/) { print "git commit --no-verify"; exit }
          if (a ~ /^--/) { if (a !~ /=/ && cvlong(a) && e < n) e = wend(w, e + 1, n) }
          else if (a ~ /^-./) {
            if (cluster(a, "n", "mFCct", "uS")) { print "git commit --no-verify"; exit }
            if (valnext && e < n) e = wend(w, e + 1, n)
          }
          m = e
        }
      }
      if (verb == "checkout" || verb == "switch") {
        for (m = j + 1; m <= n; m++) {
          a = u[m]
          if (a ~ /^--/) { if (isprefix(a, "--force", 3) || isprefix(a, "--discard-changes", 4)) { print "git " verb " --force"; exit } }
          else if (a ~ /^-./) { if (cluster(a, "f", "bBcC", "")) { print "git " verb " --force"; exit }; if (valnext) m++ }
        }
      }
      if (verb == "clean") {
        dry = 0
        for (m = j + 1; m <= n; m++) {
          a = u[m]
          if (a == "--") break
          if (a == "--dry-run") { dry = 1; continue }
          if (a ~ /^--no-d/) { dry = 0; continue }
          if (a == "-e" || a ~ /^--e[^=]*$/) { m++; continue }
          if (a ~ /^-[^-]/) {
            c = substr(a, 2); p = index(c, "e")
            if (p == length(c)) m++
            if (p) c = substr(c, 1, p - 1)
            if (index(c, "n")) dry = 1
          }
        }
        if (!dry) { print "git clean without -n/--dry-run"; exit }
      }
      if (verb == "checkout" || verb == "restore") {
        staged = 0; wt = 0; hit = 0
        for (m = j + 1; m <= n; m++) {
          a = u[m]
          if (wholetree(a)) hit = 1
          else if (a ~ /^--pathspec-fr/) hit = 1
          else if (a == "--staged") staged = 1
          else if (a ~ /^--no-s/) staged = 0
          else if (a ~ /^--w/) wt = 1
          else if (a ~ /^-[^-]/) {
            c = substr(a, 2); p = index(c, "s"); if (p) c = substr(c, 1, p - 1)
            if (index(c, "S")) staged = 1
            if (index(c, "W")) wt = 1
          }
        }
        if (hit && (verb == "checkout" || !staged || wt)) { print "git " verb " of the whole tree"; exit }
      }
    }
  }
}
# The text t with every backslash-newline continuation joined.
function joinbs(t,   nl, L, i, ln, bs, joined) {
  nl = split(t, L, "\n"); joined = ""
  for (i = 1; i <= nl; i++) {
    ln = L[i]; bs = 0
    while (bs < length(ln) && substr(ln, length(ln) - bs, 1) == "\\") bs++
    if (bs % 2 && i < nl) joined = joined substr(ln, 1, length(ln) - 1)
    else joined = joined ln "\n"
  }
  return joined
}
# 1 when b (a basename) is a shell or an interpreter that runs what it reads.
function interp(b) { return (b ~ /^(sh|bash|zsh|dash|ksh|fish|ssh|eval|source|[.]|xargs|env|sudo|node|deno|bun|perl|ruby|php|osascript|awk|sed)$/ || b ~ /^python/) }
# A commit value v is data: it is emitted as _, and the text after its first $(
# or backtick is queued in SUBQ to be read as a command.
function blank(v,   p, q) {
  p = index(v, "$("); q = index(v, "`")
  if (q && (!p || q < p)) SUBQ = SUBQ substr(v, q + 1) "\n"
  else if (p) SUBQ = SUBQ substr(v, p + 2) "\n"
  return "_"
}
# End of the raw word WB: note an interpreter on the line (LI), follow the
# segment through git, its global options and commit (ST), and emit the word to
# OUT, a -m/-F/--message/--file value blanked.
function wdone(   w, a, b, c, p, ch, o) {
  if (WB == "") return
  w = WB; WB = ""; a = unq(w); o = w
  b = a; sub(/.*\//, "", b); if (interp(b)) LI = 1
  if (ST == 0) { if (a !~ /^[A-Za-z_][A-Za-z0-9_]*=/) ST = (b == "git") ? 1 : 9 }
  else if (ST == 1) {
    if (SK) SK = 0
    else if (substr(a, 1, 1) == "-") { if (a == "-C" || a == "-c" || a == "--git-dir" || a == "--work-tree" || a == "--namespace" || a == "--config-env" || a == "--attr-source" || a == "--super-prefix") SK = 1 }
    else ST = (a == "commit") ? 2 : 9
  } else if (ST == 2) {
    if (VN) { if (VN == 2) o = blank(w); VN = 0 }
    else if (a == "--") ST = 9
    else if (a ~ /^--/) {
      p = index(a, "=")
      if (p) { c = substr(a, 1, p - 1); if (isprefix(c, "--message", 4) || isprefix(c, "--file", 5)) o = c "=" blank(substr(w, index(w, "=") + 1)) }
      else if (isprefix(a, "--message", 4) || isprefix(a, "--file", 5)) VN = 2
      else if (cvlong(a)) VN = 1
    } else if (a ~ /^-./) {
      for (p = 2; p <= length(a); p++) {
        ch = substr(a, p, 1)
        if (ch == "m" || ch == "F") { if (p == length(a)) VN = 2; else o = substr(a, 1, p) blank(substr(a, p + 1)); break }
        if (index("Cct", ch)) { if (p == length(a)) VN = 1; break }
        if (index("uS", ch)) break
      }
    }
  }
  OUT = OUT o
}
# The command text s with its data taken out: the bodies of quoted heredocs no
# interpreter reads, and the values of git commit -m/-F. Bodies that stay code
# are added to EXTRA; for an interpreter, quotes, commas and brackets turn to spaces.
function prep(s,   i, n, ch, c, j, k, d, dq, dash, e, ln, cmp, data) {
  OUT = ""; WB = ""; PQ = ""; ST = 0; SK = 0; VN = 0; LI = 0; NH = 0
  n = length(s); i = 1
  while (i <= n) {
    ch = substr(s, i, 1)
    if (PQ != "") {
      WB = WB ch
      if (PQ == "s") { if (ch == sq) PQ = "" }
      else if (ch == "\\") { WB = WB substr(s, i + 1, 1); i++ }
      else if ((PQ == "d" && ch == "\"") || (PQ == "a" && ch == sq)) PQ = ""
      i++; continue
    }
    if (ch == "\\") { WB = WB ch substr(s, i + 1, 1); i += 2; continue }
    if (ch == sq) { PQ = "s"; WB = WB ch; i++; continue }
    if (ch == "\"") { PQ = "d"; WB = WB ch; i++; continue }
    if (ch == "$" && substr(s, i + 1, 1) == sq) { PQ = "a"; WB = WB ch sq; i += 2; continue }
    if (ch == " " || ch == "\t") { wdone(); OUT = OUT ch; i++; continue }
    if (ch == "<" && substr(s, i + 1, 1) == "<" && substr(s, i + 2, 1) != "<") {
      wdone(); j = i + 2; dash = 0; d = ""; dq = 0
      if (substr(s, j, 1) == "-") { dash = 1; j++ }
      while (j <= n && (substr(s, j, 1) == " " || substr(s, j, 1) == "\t")) j++
      while (j <= n) {
        c = substr(s, j, 1)
        if (index(" \t\n;&|()<>", c)) break
        if (c == sq || c == "\"") {
          dq = 1; k = index(substr(s, j + 1), c)
          if (!k) { d = d substr(s, j + 1); j = n + 1; break }
          d = d substr(s, j + 1, k - 1); j += k + 1; continue
        }
        if (c == "\\") { dq = 1; d = d substr(s, j + 1, 1); j += 2; continue }
        if (c == "$" && (substr(s, j + 1, 1) == sq || substr(s, j + 1, 1) == "\"")) { j++; continue }
        d = d c; j++
      }
      OUT = OUT substr(s, i, j - i)
      if (d != "") { NH++; HD[NH] = d; HQ[NH] = dq; HT[NH] = dash }
      i = j; continue
    }
    if (ch == "\n") {
      wdone(); ST = 0; SK = 0; VN = 0; OUT = OUT ch; i++
      for (k = 1; k <= NH; k++) {
        data = (HQ[k] && !LI)
        while (i <= n) {
          e = index(substr(s, i), "\n")
          if (e) { ln = substr(s, i, e - 1); i += e } else { ln = substr(s, i); i = n + 1 }
          cmp = ln; if (HT[k]) sub(/^\t+/, "", cmp)
          if (cmp == HD[k]) break
          if (data) continue
          if (LI) { gsub(sq, " ", ln); gsub(/"/, " ", ln); gsub(/,/, " ", ln); gsub(/\[/, " ", ln); gsub(/\]/, " ", ln) }
          EXTRA = EXTRA ln "\n"
        }
      }
      NH = 0; LI = 0; continue
    }
    if (index(";&|()`", ch)) { wdone(); ST = 0; SK = 0; VN = 0; OUT = OUT ch; i++; continue }
    WB = WB ch; i++
  }
  wdone()
  return OUT
}
{ raw = raw $0 "\n" }
END {
  EXTRA = ""; SUBQ = ""; t = raw
  for (r = 0; t != "" && r < 16; r++) {
    o = prep(t); t = SUBQ; SUBQ = ""
    scan(o); scan(joinbs(o))
  }
  if (t != "") { scan(t); scan(joinbs(t)) }
  scan(EXTRA); scan(joinbs(EXTRA))
}') || { echo "BLOCKED: bash-guard per-word check failed to run" >&2; exit 2; }
if [ -n "$VERDICT" ]; then
  echo "BLOCKED: dangerous command ($VERDICT): $CMD" >&2
  exit 2
fi

# Added 2026-09-03: the Bash half of the credential-store protection. The Read
# and Grep half is hooks/read-guard.sh. Any command naming Claude Code's
# credential store (the .claude.json file in your home directory) is refused, so
# the cat / grep / less / head / jq route is closed as firmly as the Read tool is.
# Note this is a whole-command substring match, like every pattern above it: do
# not write the file name as a literal in an unrelated command or comment.
CLAUDEJSON='\.claude\.json'
if printf '%s\n' "$CMD" | grep -qEi "$CLAUDEJSON"; then
  echo "BLOCKED: protected file referenced in command" >&2
  exit 2
fi
exit 0
