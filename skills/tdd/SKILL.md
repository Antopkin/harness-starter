---
name: tdd
description: >
  Spec-driven Red-Green-Refactor TDD for Python with pytest. Use when the user
  wants to develop functionality through TDD, mentions Red-Green-Refactor,
  test-driven development, or wants iterative development with automatic
  verification via tests. Derives an AC/EC/ERR spec, runs RED and GREEN in two
  isolated subagent contexts, and halts on a contradictory spec via spec_defect.
  Invocation: /tdd followed by a short feature description.
---

# TDD: Spec-Driven Red-Green-Refactor

You implement functionality through a strict, spec-driven TDD cycle. Every feature starts with a **spec** (numbered AC/EC/ERR); then each behavior is one test, minimal implementation, refactor — RED and GREEN in **separate isolated contexts**. Framework: Python + pytest.

## Philosophy

Tests verify **behavior through public interfaces**, not implementation details. Code can change entirely; tests shouldn't. A test that breaks during pure refactoring (no behavior change) was testing implementation, not behavior (`references/behavior-vs-implementation.md`). The spec is the contract: tests trace to it, the developer never sees it (`references/spec-phase.md`, `references/double-isolation.md`).

## Iron Rules

1. **Spec first.** Derive AC/EC/ERR criteria before any test. Every test carries exactly one tag (`# spec: AC-3`).
2. **One test at a time.** Each test is a separate Red-Green-Refactor cycle. Never write multiple tests at once.
3. **The test must fail (Red).** Run it, confirm FAIL. A test that passes immediately is useless.
4. **Tests are immutable in Green.** Never modify a test to make it pass. Only implementation code.
5. **Minimal implementation.** Exactly enough code to pass the current test. Hardcoded values are fine; elegance comes in Refactor.
6. **Refactor only when green.** All tests pass before and after refactoring.
7. **Contradictory spec halts.** If two AC conflict (statically, or latently via 2-strike), emit `spec_defect` — never write green tests on a broken spec. See `references/double-isolation.md`.

## Anti-Patterns (what NOT to do)

Don't write all the tests in one batch (**horizontal slicing** — each Red→Green→Refactor is a vertical slice of one behavior). Don't test the implementation (mocks of internal collaborators, private methods, side channels). No **speculative tests** without a spec tag. Don't refactor while red. One test, one logical assertion. Details: `references/anti-patterns.md`, `references/vertical-slicing.md`.

## Cycle

`SPEC → PLAN → [RED → GREEN → REFACTOR → COMMIT] × N → SUMMARY`

## SPEC Phase

From the feature description, derive an AC/EC/ERR spec before any test: **AC** acceptance criteria (core behavior, 3–7), **EC** edge cases (boundaries, empty/extreme inputs, 1–3), **ERR** error cases (invalid input, failure modes, ~1). Taxonomy + Python examples in `references/spec-phase.md`.

Then run the **spec-verification procedure** (full checklist in `references/spec-phase.md`):
- **Completeness** — every AC has ≥1 planned test.
- **Traceability** — every planned test maps back to a specific AC/EC/ERR id.
- **Coherence** — no two AC contradict each other. If they do → **STOP, emit `spec_defect`** (name both AC ids), halt for human resolution. Do NOT proceed to write green tests. Protocol + worked example in `references/double-isolation.md`.

Output the spec, then continue to PLAN only when `Coherence: OK`.

## PLAN Phase

Explore existing code (target module, related files, `tests/`). Define types/interfaces (dataclass, TypedDict, Protocol) — the contract between tests and implementation. Map the spec's criteria onto **atomic behaviors**, one assertion each; each carries its spec tag.

```
### TDD Plan: <feature>
Types/interfaces: <brief>
Behaviors:
  1. <behavior>  # spec: AC-1  → test_<name>
  2. <behavior>  # spec: EC-1  → test_<name>
```

Continue to RED for the first behavior without pausing.

## RED Phase  (test-writer context — blind to implementation)

For the current behavior, write **ONE** test in `tests/test_<module>.py`:
- Name `test_<function>_<behavior>` (describes WHAT, not HOW); tag it `# spec: <id>`.
- Checks behavior through the **public interface**; survives internal refactor unmodified.
- Append to an existing file, never overwrite. Mock only at system boundaries (`references/behavior-vs-implementation.md`).
- The test carries a behavior name + assertions, **not** the prose requirement (so GREEN can't reverse-engineer the spec).
- If the module is new, create an empty stub so the test fails on assertion, not `ImportError`.

Run only this test: `python -m pytest tests/test_<module>.py::<test_name> -v`

- **FAIL** → print error, proceed to GREEN.  `🔴 RED: test_<name> — FAIL`
- **PASS** → useless test. Behavior already exists (delete, next behavior) or test wrong (rewrite).
- **ERROR** (Import/Name/AttributeError) → acceptable Red, proceed to GREEN.

**Output language:** the language of the user's request. **Length cap:** at most 100 words. **Return shape:** `test_file_path`, `test_name`, `spec_tag`, the marker line `🔴 RED: test_<name> — FAIL`, and the pytest failure excerpt.

## GREEN Phase  (developer context — blind to spec)

**RULES:** DO NOT TOUCH test files. Write **minimal** code to pass THIS test only. Hardcoded returns, simple if-branches, stubs — all fine. Create new files as needed. The developer is given ONLY the current behavior's test (its `# spec:` tag stripped by main) **read-only** + a command to run the rest; never the spec, never the accumulated test file. It codes to the test alone.

Run ALL module tests: `python -m pytest tests/test_<module>.py -v`

- **All PASS** → proceed to REFACTOR.  `🟢 GREEN: test_<name> — PASS (total: N, all green)`
- **New PASS, old FAIL** → you broke something. Fix implementation (not tests!).
- **New FAIL** → insufficient. Add code (do not modify the test!).
- **Green for this test breaks another AC's green test** → latent contradiction. The GREEN subagent **returns** `cross_ac_break:{broke, while_greening}`; **main** counts strikes across cycles (a blind, ephemeral GREEN context can't hold the count) and emits `spec_defect` at strike 2. Any cross-AC breakage is a strike regardless of the 3-attempt counter. See `references/double-isolation.md`.

**Output language:** the language of the user's request. **Length cap:** at most 150 words. **Return shape:** the marker line `🟢 GREEN: test_<name> — PASS (total: N, all green)`, `files_modified`, and `cross_ac_break:{broke, while_greening}` when greening this test broke another AC's green test.

## REFACTOR Phase

**PRECONDITION:** all tests green (else back to GREEN). Evaluate duplication / poor names / DRY. If clean → skip to COMMIT. While refactoring: no new behavior, no test edits, re-run `python -m pytest tests/test_<module>.py -v` after each change; if red → revert.

`🔵 REFACTOR: <what changed> | tests: all green`  or  `🔵 REFACTOR: skipped`

## COMMIT Phase

```bash
git add <test files> <implementation files>
git commit -m "tdd(<module>): <behavior>  [spec: <id>]

Red: test_<name> added | Green: <what> | Refactor: <what | skipped>

Co-Authored-By: <model> <noreply@anthropic.com>"
```

`📦 COMMIT: tdd(<module>): <behavior>` — then RED for the next behavior.

## Context Isolation (double, recommended)

Two separate subagent contexts prevent "subconscious cheating". Brief here; full protocol in `references/double-isolation.md`.

- **Main:** SPEC, PLAN, RED-launch, REFACTOR, COMMIT.
- **Test-writer (RED):** given the SPEC + test file path; **blind to implementation** (no impl path, cannot read `src`). Writes the failing test from the spec only.
- **Developer (GREEN):** given ONLY the current test (tag stripped) **read-only** + a run command for the rest + pytest output; **blind to the spec** (no spec path; tests carry behavior names, not prose; accumulated file withheld so the growing test set can't be mined). Returns `cross_ac_break` if greening broke another AC's test. Writes minimal code to pass the test only.

Without subagents: work in main, but hold both boundaries — don't peek at impl during RED, don't consult the spec during GREEN.

**Output language:** the language of the user's request. **Length cap:** at most 150 words per subagent return, and at most 100 words for the test-writer. **Return shape:** this governs both contexts — the test-writer returns `test_file_path`, `test_name`, `spec_tag` and the `🔴 RED` marker; the developer returns the `🟢 GREEN` marker, `files_modified` and `cross_ac_break:{broke, while_greening}`; either falls back to the `spec_defect` block defined in `references/double-isolation.md`.

## Summary

```
✅ TDD complete: N behaviors, N tests, N commits
   Spec: N/N AC covered & traceable · Coherence: OK
   Files: <list>
   Verify: python -m pytest tests/test_<module>.py -v --tb=short
```

## Error Recovery

| Situation | Action |
|-----------|--------|
| Test doesn't fail in RED | Delete the test, reconsider the behavior |
| Two AC contradict (static, SPEC phase) | Emit `spec_defect` naming both AC, halt for human resolution |
| Green breaks another AC's green test twice | 2nd strike → emit `spec_defect` (both AC ids), don't game the test |
| Test won't pass after 3 GREEN attempts | Test may be wrong, or spec defect — explain why, ask the user |
| Refactoring broke tests | `git checkout -- <implementation files>`, try another approach |
| New test breaks old ones | Fix implementation, not tests |

## Compatibility

**Ruff format:** no formatter hook ships with this kit, so run `ruff format <files>` yourself before each commit; it does not break tests. **`/test`** — test generation WITHOUT TDD discipline; **`/review`** — user-invoked, so after the cycle suggest the user run `/review` for a final review; **`/diagnose`** — for non-deterministic bugs, build a deterministic signal first, then write a regression test here.

## References

Progressive disclosure — load when relevant:

- `references/spec-phase.md` — AC/EC/ERR taxonomy, test tagging, spec-verification procedure (Completeness/Traceability/Coherence)
- `references/double-isolation.md` — two-context protocol, `spec_defect` signal format, 2-strike rule, premium worked example
- `references/anti-patterns.md` — TDD anti-patterns (horizontal slicing, implementation testing, speculative tests, etc.)
- `references/behavior-vs-implementation.md` — good vs bad tests with Python examples, when to mock
- `references/vertical-slicing.md` — tracer bullets, how to split a feature into thin end-to-end slices

---

Adapted from mattpocock/skills@c55ee46 engineering/tdd (MIT).
