# TDD Anti-Patterns

## 1. Horizontal Slicing (the main anti-pattern)

**DON'T:** write all the tests first and then write the whole implementation.

```
WRONG (horizontal):
  RED:   test_1, test_2, test_3, test_4, test_5
  GREEN: impl_1, impl_2, impl_3, impl_4, impl_5
```

What you get:
- Tests written in a batch check **imagined** behavior, not real behavior.
- It ends up testing shape (data structures, function signatures) rather than user-facing behavior.
- The tests become insensitive to real changes: they pass when the behavior is broken and fail when the behavior is fine.
- You outrun your headlights: you fix the test structure before you understand the implementation.

**RIGHT:** vertical slicing through tracer bullets. One test → one implementation → repeat.

```
RIGHT (vertical):
  RED→GREEN: test_1 → impl_1
  RED→GREEN: test_2 → impl_2
  RED→GREEN: test_3 → impl_3
```

Each next test responds to what you learned in the previous cycle. Because the code was just written, you know exactly which behavior matters and how to check it.

See `vertical-slicing.md` for details.

---

## 2. Testing the implementation, not the behavior

**DON'T:** mock internal collaborators, test private methods, verify through side channels (reading from the DB directly instead of using the interface).

Sign of trouble: the test breaks during refactoring although the behavior did not change. If renaming an internal function breaks a test, that test was checking the implementation, not the behavior.

```python
# BAD: tests the implementation (mocks an internal collaborator)
def test_checkout_calls_payment_service():
    cart = Cart()
    mock_payment = Mock(spec=PaymentService)
    checkout(cart, mock_payment)
    mock_payment.process.assert_called_once_with(cart.total)

# GOOD: tests behavior through the public interface
def test_checkout_returns_confirmed_status():
    cart = Cart()
    cart.add(product)
    result = checkout(cart, payment_method)
    assert result.status == "confirmed"
```

See `behavior-vs-implementation.md`.

---

## 3. Speculative tests (for the future)

**DON'T:** add tests for functionality that is not needed yet. "Just in case it comes in handy."

Every test is a commitment: it has to be maintained, refactored along with the code, explained to the team. Speculative tests turn into technical debt. Write only the test that describes the behavior needed right now. The spec tag (`# spec: <id>`, see `spec-phase.md`) catches this: a test without a traceable AC/EC/ERR is a speculative candidate.

---

## 4. Refactoring while red

**DON'T:** refactor when the tests are not green. Pass first, then refactor.

If you try to refactor while red, you will not know what broke: the new refactor or the old bug. Reach a green state by any means (even a hardcoded return), then improve.

---

## 5. Multi-assert test

**DON'T:** check several independent behaviors in one test. One test, one logical assertion.

```python
# BAD: checks several things
def test_checkout():
    assert cart.total == 100
    assert checkout(cart).status == "confirmed"
    assert send_email.called

# GOOD: split into 3 tests
def test_cart_total_sums_items(): ...
def test_checkout_confirms_valid_cart(): ...
def test_checkout_sends_confirmation_email(): ...
```

When one of the 3 separate tests fails, you know exactly what broke. When the multi-assert test fails, you dig.
