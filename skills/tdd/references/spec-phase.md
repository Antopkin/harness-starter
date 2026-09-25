# Spec Phase: AC / EC / ERR

Before you write the first test, you derive a **specification** from the feature description: a numbered contract between the tests and the implementation. Every behavior and every test after that carries exactly one spec tag (`# spec: AC-3`). The spec is the source of truth: the tests trace to it, and the final verification checks the code against the spec.

This is a static step. It catches holes and contradictions in the requirements before we spend Red→Green on imagined behavior. It does NOT prove the implementation correct; for that you need mutation testing (`mutmut`) or property-based tests.

---

## Taxonomy: three tag categories

Each requirement falls into exactly one category:

- **AC** (acceptance criteria) — the core. The mandatory behavior the feature exists for. "What the system does in the normal case."
- **EC** (edge cases) — the boundaries. Empty input, zero/extreme values, boundary sizes, a single element.
- **ERR** (error cases) — failures. Invalid input, exceptions, failure modes. "What the system does when something goes wrong."

The volume matches the target number of tests: **3–7 AC + 1–3 EC + 1 ERR** (the number of AC is set in the SPEC phase, see SKILL.md §SPEC; PLAN then breaks them down into atomic behaviors).

### Spec format

```
### Spec: <feature>

Acceptance Criteria
  AC-1: format_file_size(1024) returns "1 KB"
  AC-2: format_file_size(1048576) returns "1 MB"
  AC-3: binary units are used (base 1024, not 1000)

Edge Cases
  EC-1: format_file_size(0) returns "0 B"

Error Cases
  ERR-1: format_file_size(-1) raises ValueError
```

### A good AC: INVEST-style criteria

- **Concrete** — about observable behavior, not the implementation. `format_file_size(1024) == "1 KB"`, not "the function formats correctly".
- **Testable in isolation** — checkable without other criteria.
- **Atomic** — one behavior. A compound "X and Y" in one AC → split it into `AC-N` and `AC-N+1`.
- **Input-complete** — all preconditions are explicit. If a test assumes an input shape the spec does not define, that is a spec defect (see below).

---

## Tagging tests

Every test refers to its criterion in its name or a comment. This gives traceability in both directions.

```python
def test_format_file_size_kilobytes():
    # spec: AC-1
    assert format_file_size(1024) == "1 KB"

def test_format_file_size_zero():
    # spec: EC-1
    assert format_file_size(0) == "0 B"

def test_format_file_size_negative_raises():
    # spec: ERR-1
    with pytest.raises(ValueError):
        format_file_size(-1)
```

Order of writing tests: happy-path AC first, then EC, then ERR. One criterion → at least one test; one test → exactly one criterion.

---

## Spec-verification procedure (checklist, before the first RED)

Run it over the spec as a static check. Three dimensions:

### 1. Completeness — every AC has at least one planned test

```
[ ] List all criteria: AC-*, EC-*, ERR-*
[ ] For each criterion, find the planned test by matching id
[ ] Is every AC covered by ≥1 test? (EC/ERR desirable, AC mandatory)
```

An uncovered AC → a hole. Either add a test or take the criterion out of the spec deliberately.

### 2. Traceability — every planned test maps back to a specific id

```
[ ] Does every test have a # spec: <id> tag?
[ ] Does every id in a tag exist in the spec?
[ ] No "orphan" tests without a criterion (a test without a spec = a test of imagined behavior)
```

A test without a traceable criterion is a speculative test (see `anti-patterns.md` §3). Delete it or add a criterion.

### 3. Coherence — no two AC contradict each other

```
[ ] For each pair of AC: can both be true at the same time for the same input?
[ ] No mutually exclusive requirements (sync vs async, "visible" vs "not visible" for the same state)?
[ ] No unachievable constraints (physically/logically impossible as stated)?
```

If two AC are mutually exclusive, **STOP, emit `spec_defect`**; do not write green tests on a contradictory spec. The full signal protocol, the worked example (premium dashboard) and the 2-strike rule are in `double-isolation.md`.

---

## Final spec report

```
Spec Verification
  Completeness:  N/N AC covered by tests
  Traceability:  N/N tests trace to criteria
  Coherence:     OK | spec_defect: <AC-i> vs <AC-j>
```

Move on to PLAN/RED only with `Coherence: OK`. With `spec_defect`, halt and escalate to a human.
