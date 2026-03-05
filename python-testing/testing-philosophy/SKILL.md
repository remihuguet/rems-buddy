---
name: testing-philosophy
description: "Behavior-driven testing philosophy: diamond approach, fakes over mocks, dependency injection"
---

# Testing Philosophy & Practices

## Rules

### Define unit tests as behavior tests through entry points with fake dependencies -- not tests of individual code units

```python
# Good
def test_order_creation_reserves_inventory():
    fake_repo = InMemoryOrderRepository()
    fake_inventory = InMemoryInventoryService()

    create_order(customer_id="c1", product_id="p1", repo=fake_repo, inventory=fake_inventory)

    assert fake_inventory.reserved["p1"] == 1

# Bad
def test_order_sets_status_field():
    order = Order()
    order._set_status("pending")
    assert order._status == "pending"
```

### Use integration tests to verify interfaces with real external systems (database, file system, network)

### Reserve end-to-end tests for critical user paths only -- all real dependencies, fewest in number

### Write most tests at the service/acceptance level through entry points with fakes

### Limit low-level unit tests to complex algorithms that benefit from isolated testing

### Follow Arrange-Act-Assert pattern: setup, execute, verify -- separated by blank lines

```python
# Good
def test_premium_users_get_discount():
    customer = CustomerFactory(tier=Tier.PREMIUM)
    product = ProductFactory(price=Decimal("100"))

    order = create_order(customer.id, product.id)

    assert order.total == Decimal("80")

# Bad
def test_premium_users_get_discount():
    customer = CustomerFactory(tier=Tier.PREMIUM)
    order = create_order(customer.id, ProductFactory(price=Decimal("100")).id)
    assert order.total == Decimal("80")
    assert order.discount_applied is True
    another_order = create_order(customer.id, ProductFactory().id)
```

### Name tests to express intent and read like documentation

```python
# Good
def test_user_cannot_order_out_of_stock_product():
    ...

def test_order_total_includes_shipping_for_non_premium_users():
    ...

# Bad
def test_order_validation():
    ...

def test_calculate_total_method():
    ...
```

### Avoid implementation details in test names -- focus on behavior and outcomes

### Prefer fakes (working in-memory implementations) over mocks for most test scenarios

```python
# Good
class InMemoryOrderRepository:
    def __init__(self):
        self._orders: dict[str, Order] = {}

    def save(self, order: Order) -> None:
        self._orders[order.id] = order

    def get(self, order_id: str) -> Order | None:
        return self._orders.get(order_id)

# Bad
def test_order_saved(mocker):
    mock_repo = mocker.Mock()
    create_order("c1", "p1", repo=mock_repo)
    mock_repo.save.assert_called_once()  # Breaks if save() renamed
```

### Use stubs only for predefined responses from external services

### Avoid mocks when possible -- they couple tests to implementation and break during refactoring

### Design production code with dependency injection to enable testing with fakes

```python
# Good
def create_order(customer_id: str, product_id: str, repo: OrderRepository) -> Order:
    order = Order(customer_id, product_id)
    repo.save(order)
    return order

# Bad
def create_order(customer_id: str, product_id: str) -> Order:
    repo = PostgreSQLOrderRepository()
    order = Order(customer_id, product_id)
    repo.save(order)
    return order
```
