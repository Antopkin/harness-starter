# Vertical Slicing (Tracer Bullets)

## What it is

A **vertical slice** is one thin behavior, from the test interface down to the implementation, finished in a single Red→Green→Refactor cycle. Not "the whole skeleton first, then the meat", but "one working end-to-end behavior, then the next".

The analogy comes from shooting: a tracer bullet glows in flight, so you see at once whether you hit the target. In development, the first vertical slice checks that the whole path from input to result works at all. Further slices add behavior on top of a working base.

## Why vertical rather than horizontal

**Horizontal slicing** splits the work by layers: first all the tests, then the whole implementation (or: first all the DB tables, then the whole backend, then the whole frontend). The problems:

1. **Tests written in a batch are detached from reality.** You don't know how the code behaves until you have written the implementation. The tests end up being about imagined behavior.
2. **A long wait for the first working feature.** You have to close the whole layer before anything works.
3. **Design changes are expensive.** If on the 4th test you realise the interface should be different, you rewrite the previous 3 tests and their implementations.

**Vertical slicing** splits by behaviors. Each slice is self-contained. After every cycle you have a **working partial feature** that you can show.

## The right flow

```
Behavior 1: the user can add a product to the cart
  RED:    test_add_to_cart_increases_count
  GREEN:  cart.add(product) increases len(cart.items)

Behavior 2: an empty cart counts as invalid
  RED:    test_empty_cart_invalid
  GREEN:  cart.is_valid() returns False for an empty one

Behavior 3: checkout with a valid cart returns confirmed
  RED:    test_checkout_returns_confirmed_for_valid_cart
  GREEN:  checkout() calls payment, returns Result(status="confirmed")
```

Each step works on its own. After step 1 the cart can already accept products, which is enough for some use case. After step 3 you have a minimum viable checkout.

## Tracer bullet: the first shot

The first slice matters most. Its goal is to **prove that the path works end-to-end**, not to cover every case. Hardcoded return values are fine at this stage. A smoke test is fine.

Example: if you are building an API endpoint, the first slice is "POST /checkout returns 200". Not input validation, not error handling, not a proper response body. Just 200. After that you add behaviors.

```python
# The first tracer bullet - minimally works
def test_checkout_endpoint_returns_200():
    response = client.post("/checkout", json={"cart_id": "abc"})
    assert response.status_code == 200

# The implementation may be hardcoded
@app.post("/checkout")
def checkout_endpoint(payload):
    return {"status": "ok"}
```

This is embarrassing code. But it works. After it, the next test demands real validation; you add it, and the implementation evolves naturally.

## How to split into slices

A good slice = one observable behavior that can be described in one sentence.

Signs of a right slice:
- It is described as "the user can ..." or "the system does ..."
- It does not depend on other slices in the same cycle
- It takes 5-15 minutes to implement (not 2 hours)
- It can be demonstrated without explanation: "this works"

Signs of a wrong slice:
- It is described as "and ... and ... and ..." (several behaviors in one)
- It needs simultaneous changes in 5 files
- It cannot be explained without a diagram

If a slice is big, split it. If a slice took 30 seconds, the next one can be meatier.

## After the TDD session

Once all the slices are done, the code may look naive (hardcoded branches, duplication, sub-optimal structures). That is normal; that is what the Refactor phase is for. When all behaviors are covered by tests, you can improve the design safely: the tests catch regressions.

Each slice corresponds to one spec criterion (AC/EC/ERR, see `spec-phase.md`): one observable behavior = one tag = one Red→Green→Refactor.
