# Behavior vs Implementation Testing

**Main principle:** tests check behavior through the public interface, not implementation details. The code may change entirely; the tests should not.

## Good tests

**Integration-style:** they test through real interfaces, not through mocks of internal parts.

```python
# GOOD: tests observable behavior
def test_user_can_checkout_with_valid_cart():
    cart = create_cart()
    cart.add(product)
    result = checkout(cart, payment_method)
    assert result.status == "confirmed"
```

Characteristics:
- They check behavior that matters to users/callers
- They use only the public API
- They survive internal refactoring
- They describe **WHAT**, not **HOW**
- One logical assertion per test

The test name reads like a specification: `test_user_can_checkout_with_valid_cart` tells you at once which capability the system has.

## Bad tests

**Implementation-detail tests:** tied to the internal structure.

```python
# BAD: tests implementation details
def test_checkout_calls_payment_service():
    mock_payment = Mock(spec=PaymentService)
    checkout(cart, payment)
    mock_payment.process.assert_called_with(cart.total)
```

Red flags:
- They mock internal collaborators
- They test private methods
- They assert on call counts/order
- The test breaks during refactoring without a behavior change
- The test name describes **HOW**, not **WHAT**
- They verify through external channels instead of the interface

```python
# BAD: bypasses the interface to verify
def test_create_user_saves_to_database():
    create_user(name="Alice")
    row = db.execute("SELECT * FROM users WHERE name = ?", ("Alice",)).fetchone()
    assert row is not None

# GOOD: verifies through the interface
def test_create_user_makes_user_retrievable():
    user = create_user(name="Alice")
    retrieved = get_user(user.id)
    assert retrieved.name == "Alice"
```

The second version survives a migration from SQLite to Postgres, a schema change, an ORM layer. The first does not.

## A test must survive refactoring

A simple checklist for checking a test:

```
[ ] The test describes behavior, not implementation
[ ] The test uses only the public interface
[ ] The test survives internal refactoring (a rename, extracting a helper)
[ ] The test name describes WHAT, not HOW
[ ] One logical assertion
```

If even one item is violated, rewrite the test.

## When to mock (and when not to)

**Mock only at system boundaries:**
- External APIs (payments, email, SMS)
- Databases (sometimes a test DB is better)
- Time / randomness
- The file system (sometimes)

**DON'T mock:**
- Your own classes/modules
- Internal collaborators
- Anything you control yourself

If you have to mock something of your own to write a test, that signals a badly designed interface. Redesign it rather than papering over it with a mock.

The test name describes WHAT but does NOT carry the requirement prose: an assertion plus a behavioral name, not the literal AC text. This keeps the GREEN context isolated (`double-isolation.md`): the developer cannot reverse-engineer the spec from the test.
