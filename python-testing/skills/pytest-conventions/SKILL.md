---
name: pytest-conventions
description: "Pytest-specific conventions: function-style tests, fixtures, parametrize, and exception testing"
---

# Pytest Conventions

## Rules

### Write tests as functions, not classes -- pytest's fixture system eliminates the need for setUp/tearDown

```python
# Good
def test_create_order(fake_repo: OrderRepository, customer_factory):
    customer = customer_factory()
    order = create_order(customer.id, "p1", fake_repo)
    assert order.customer_id == customer.id

# Bad
class TestOrderCreation:
    def setUp(self):
        self.repo = InMemoryOrderRepository()

    def test_create_order(self):
        order = create_order("c1", "p1", self.repo)
        assert order is not None
```

### Use `pytest.fixture` for shared setup logic instead of class inheritance

```python
# Good
@pytest.fixture
def fake_repo() -> OrderRepository:
    return InMemoryOrderRepository()

@pytest.fixture
def customer_factory():
    def _factory(name: str = "John", email: str = "john@example.com") -> Customer:
        return Customer(uuid4(), name, email)
    return _factory

def test_order_creation(fake_repo: OrderRepository, customer_factory):
    customer = customer_factory(name="Jane")
    order = create_order(customer.id, "p1", fake_repo)
    assert fake_repo.get(order.id) is not None

# Bad
class BaseTestCase:
    def setUp(self):
        self.repo = InMemoryOrderRepository()
        self.customer = Customer(uuid4(), "John", "john@example.com")

class TestOrder(BaseTestCase):
    def test_order(self):
        order = create_order(self.customer.id, "p1", self.repo)
```

### Group related tests in modules, not test classes

### Use factory fixtures (functions returning functions) for customizable test data

### Scope fixtures appropriately: `function` (default), `module`, or `session`

### Use `@pytest.mark.parametrize` to test multiple scenarios with the same logic

```python
# Good
@pytest.mark.parametrize("age,is_valid", [
    (17, False),
    (18, True),
    (25, True),
    (150, False),
])
def test_customer_age_validation(age: int, is_valid: bool):
    if is_valid:
        customer = Customer(uuid4(), "Test", "test@example.com", age)
        assert customer.age == age
    else:
        with pytest.raises(ValueError):
            Customer(uuid4(), "Test", "test@example.com", age)

# Bad
def test_age_17_invalid():
    with pytest.raises(ValueError):
        Customer(uuid4(), "Test", "test@example.com", 17)

def test_age_18_valid():
    customer = Customer(uuid4(), "Test", "test@example.com", 18)
    assert customer.age == 18
```

### Keep parameter lists readable -- extract to variables if longer than 3-4 cases

### Include edge cases and boundary values in parametrized tests

### Use `pytest.raises(ExceptionType)` context manager to verify exceptions

```python
# Good
def test_cannot_place_already_placed_order():
    order = Order(uuid4(), uuid4(), Money(100, "USD"), status="placed")

    with pytest.raises(ValueError, match="already placed"):
        order.place()

# Bad
def test_cannot_place_already_placed_order():
    order = Order(uuid4(), uuid4(), Money(100, "USD"), status="placed")
    try:
        order.place()
        assert False
    except:
        pass
```

### Add `match` parameter to validate exception messages when relevant

### Test both the exception type and its context/message for critical errors
