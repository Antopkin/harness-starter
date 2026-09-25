# Double Isolation + Contradiction Detector

To prevent "subconscious cheating" — when the test author already knows the implementation, and the code author fits the code to the spec intent they peeked at — each half of the cycle runs in **its own isolated subagent context**. This is a symmetric extension of the earlier one-sided isolation (previously only GREEN was isolated).

Main principle: **each context knows exactly one side of the contract.** The test-writer sees the spec but not the implementation. The developer sees the test but not the spec.

---

## Two contexts: what we give, what we hide

### Test-writer context (writes the failing test)

| Receives | Has no access to |
|----------|---------------|
| SPEC (numbered AC/EC/ERR) | the path to the implementation file |
| the path to the test file (writable) | the ability to read `src/`, impl modules |
| the tag convention (`# spec: AC-1`) | any knowledge of the current implementation |
| the pytest run command | — |
| output language (named by main) | — |

Instruction: "Write **one** failing test from the spec. Each test refers to its criterion (`# spec: AC-N`). The test checks behavior through the public interface. Make sure the test FAILS before you return. Do not look at or assume the implementation."

If the imported module does not exist yet, create an empty stub (an empty `def`/class) so the test fails on the assertion, not on `ImportError`. Note this in the output.

**Output language:** the language of the user's request. **Length limit:** at most 100 words. **Return shape:** `test_file_path`, `test_name`, `spec_tag`, the marker `🔴 RED: test_<name> — FAIL` and an excerpt of the pytest output.

### Developer / GREEN context (writes minimal code)

| Receives | Has no access to |
|----------|---------------|
| ONLY the current test (**read-only!**), with the `# spec:` **tag stripped** | the path to the spec |
| a command to run the other tests (sees pass/fail, not their bodies) | the prose text of the requirements |
| the path/name of the implementation file (writable) | the accumulated test file as a whole |
| the pytest output (error message) | — |
| output language (named by main) | — |

Instruction: "Write **minimal** code so that THIS test passes. DO NOT touch test files. Hardcoded values are allowed. Do not invent behavior beyond the test. If making this test green breaks a previously green test, DO NOT force it: return `cross_ac_break` (see below)."

**Why the developer gets only the current test, without the tag and without the accumulated file.** One-test-deep isolation leaks if the whole growing test file goes in: the `# spec: AC-1` tag is a pointer to a criterion, and a set of tags plus assertions across several tests lets the developer reverse-engineer the spec's structure and code to the intent rather than to the test. So main **strips the tag** from the developer's copy (it keeps the tag↔test map itself) and hands over **only the current test**, and the others only as a run command (pass/fail), not as bodies. The developer sees "here is the input, here is the expected output" — and satisfies exactly that.

```python
# GOOD — the developer sees the behavior and the assertion, not the requirement prose:
def test_format_file_size_kilobytes():
    # spec: AC-1
    assert format_file_size(1024) == "1 KB"

# BAD — the requirement prose is baked into the test, the isolation leaks:
def test_format_file_size_kilobytes():
    """AC-1: per the client's brief, for compatibility with legacy billing
    sizes are always in binary KB/MB, the client separately asked ..."""
    assert format_file_size(1024) == "1 KB"
```

**Output language:** the language of the user's request. **Length limit:** at most 150 words. **Return shape:** the marker `🟢 GREEN: test_<name> — PASS (total: N, all green)`, `files_modified` and `cross_ac_break:{broke, while_greening}` if greening this test broke a previously green test of another AC; on a spec defect, the `spec_defect` block from the section below.

### Orchestration

- **Main context** holds the spec and coordinates: SPEC, PLAN, RED-launch, REFACTOR, COMMIT, SUMMARY.
- **Test-writer subagent** — RED (writes the test from the spec, blind to the impl).
- **Developer subagent** — GREEN (writes the code from the test, blind to the spec).

Without subagents: work in main, but hold both boundaries strictly — in RED don't peek at the implementation, in GREEN don't consult the spec, only the test.

---

## `spec_defect` — the contradiction signal

If the spec is internally contradictory, unimplementable or under-defined, do NOT compensate with guesses and do not weaken the tests. **Stop and raise `spec_defect`.**

### Triggers

1. **Contradictory criteria** — two AC/EC/ERR demand mutually exclusive behavior (AC-1 "returns synchronously" vs AC-3 "returns a coroutine").
2. **Missing precondition** — the tests assume an input shape/dependency the spec does not define, and there is no reasonable default.
3. **Unimplementable constraint** — a criterion cannot be implemented as stated (an AC "finish in <10ms" that needs a network round-trip without a cache).
4. **Under-specification** — one criterion is satisfied by several substantially different implementations, and you cannot choose without guessing the intent.

### What to do on a trigger

1. STOP. Do not write or change any implementation file.
2. Do not change the test file (the test-immutability rule holds here too).
3. Return the signal:

```
spec_defect: true
spec_defect_reason: "<1-2 sentences, name the specific ids>"
status: spec_defect
files_modified: []
summary: "no implementation attempted — spec_defect"
```

### What is NOT a spec defect (handle normally)

- The test fails because of a bug in the implementation → fix the implementation.
- The criterion is hard but implementable → carry on.
- An unfamiliar library → read the project's existing code.
- You did not think of an edge case → think harder, don't escalate.

### Anti-patterns (never)

- Weakening assertions to push a defective test through.
- A lookup table / hardcode only for the test inputs, to get around a spec contradiction.
- Inventing behavior the spec does not define and quietly hoping you guessed right.

---

## Worked example: the premium dashboard (must yield `spec_defect`, not green tests)

The spec contains two AC:

```
AC-2: an unpaid user does NOT have access to premium
AC-5: right after registration the user sees the premium dashboard
```

A just-registered unpaid user must see premium under AC-5 and must NOT see it under AC-2. For one and the same state (just-registered, unpaid) the requirements are mutually exclusive.

**The right outcome — the Coherence check (see `spec-phase.md`) catches this before RED:**

```
spec_defect: true
spec_defect_reason: "AC-2 vs AC-5: a just-registered unpaid user must
  both NOT see premium (AC-2) and immediately see the premium
  dashboard (AC-5) — mutually exclusive for one state."
status: spec_defect
```

Halt and escalate to a human for resolution. Do **not** write `if just_registered: show_premium`, do not build a lookup table, do not silently "pick" one of the AC.

---

## 2-strike rule (latent contradictions in GREEN)

The Coherence check catches explicit contradictions statically. But there are **latent** ones, visible only when you try to go green.

Symptom: the test cannot be made to pass without breaking another already-green test tied to a **different** AC. That means two AC quietly conflict through the implementation.

**Who counts the strikes is critical.** GREEN runs in a fresh blind subagent every cycle; such a context does not remember the last strike, and "New PASS, old FAIL" looks like an ordinary "fix the implementation" every time — a counter living inside GREEN would never fire, and the contradiction would be "fixed" test by test forever, producing green on a broken spec. So a strike is a **returned token that main counts**, not a narrative inside GREEN:

1. The GREEN subagent, finding that going green for `AC-i` makes a previously green test for `AC-j` fail, does NOT fit the test and **returns** a structured signal:
   ```
   cross_ac_break: { broke: AC-j, while_greening: AC-i }
   ```
   and hands back control without forcing green.
2. **Main** keeps a strike counter per AC pair across all cycles (GREEN's blind context cannot keep it). Any `cross_ac_break` is a strike, regardless of the "3 GREEN attempts" counter. On the **2nd** strike for the same pair, main does **STOP, emit `spec_defect`**:

```
spec_defect: true
spec_defect_reason: "AC-i vs AC-j: green for one consistently breaks
  green for the other — latent contradiction after 2 strikes."
status: spec_defect
```

The counter lives in main within one `/tdd` run, starts at 0 and is not reset between cycles. After the 2nd strike, escalate to a human with no third automatic attempt: the spec is fundamentally ambiguous.
