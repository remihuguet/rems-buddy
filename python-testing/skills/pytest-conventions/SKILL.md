---
name: pytest-conventions
description: Pytest mechanics for this user's Python projects — function-style tests over classes, fixtures and factory fixtures instead of setUp, parametrize, and pytest.raises. Use when writing or refactoring pytest tests.
paths: "**/*.py"
---

# Pytest conventions

## Functions, not classes

No `setUp`/`tearDown`, no `BaseTestCase` inheritance chains — fixtures cover it, and they compose where inheritance doesn't. Group related tests in a module.

```python
@pytest.fixture
def fake_repo() -> OrderRepository:
    return InMemoryOrderRepository()

def test_create_order__should_record_the_customer(fake_repo: OrderRepository):
    order = create_order("c1", "p1", fake_repo)

    assert order.customer_id == "c1"
```

## Factory fixtures for customizable data

A fixture returning a function, so each test overrides only the field it cares about:

```python
@pytest.fixture
def customer_factory():
    def _factory(name: str = "John", email: str = "john@example.com") -> Customer:
        return Customer(uuid4(), name, email)
    return _factory
```

Scope fixtures `function` (the default) unless setup is genuinely expensive and immutable, in which case `module` or `session`.

## Parametrize over near-duplicate tests

```python
@pytest.mark.parametrize("age,is_valid", [
    (17, False),
    (18, True),      # boundary
    (150, False),
])
def test_customer_age__should_be_validated(age: int, is_valid: bool): ...
```

Include boundaries and edge cases. Past three or four cases, lift the list into a named module-level constant so the test body stays readable.

## Exceptions via `pytest.raises`

Assert the message too when it carries meaning — the type alone often can't distinguish two different failures from the same call.

```python
def test_place_order__should_reject_an_already_placed_order():
    order = Order(uuid4(), uuid4(), Money(100, "USD"), status="placed")

    with pytest.raises(ValueError, match="already placed"):
        order.place()
```

Never `try/except/assert False` — it passes when the wrong exception is raised, and reports nothing useful when it fails.
