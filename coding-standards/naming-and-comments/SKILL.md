---
name: naming-and-comments
description: "Conventions for self-documenting code: domain naming, intent-revealing identifiers, and minimal comments"
---

# Naming and Comments

## Naming Rules

### Use domain-specific vocabulary in names to align code with business concepts

```python
# Good
def calculate_premium_discount(membership_tier: MembershipTier) -> Decimal:
    ...

# Bad
def calc_disc(level: int) -> float:
    ...
```

### Choose specific names over generic ones (avoid `data`, `info`, `item`, `temp`)

```python
# Good
user_emails: list[str] = fetch_active_subscribers()
retry_delay_seconds: int = 30

# Bad
data: list = fetch_data()
temp: int = 30
```

### Name identifiers to reveal intent -- readers should understand purpose without context

```python
# Good
is_eligible_for_refund: bool = order.days_since_purchase < 30

# Bad
flag: bool = order.days < 30
```

### Avoid abbreviations unless they are industry-standard (e.g., `id`, `url`, `http`)

```python
# Good
user_id: str = get_current_user_id()
transaction_count: int = len(transactions)

# Bad
usr_cnt: int = get_usr()
tx_cnt: int = len(txs)
```

### Maintain consistent vocabulary across the codebase -- one term per concept

### Write code that reads like prose -- refactor until logic is self-evident

## Comment Rules

### Comment the WHY (business rules, design decisions), not the WHAT (obvious mechanics)

```python
# Good
# Premium users get bonus points monthly to encourage retention
# (Business rule from Q1 2024 strategy)
if user.is_premium:
    user.points += 10

# Bad
# Add 10 to points if premium
if user.is_premium:
    user.points += 10
```

### Document complex business rules with context about their origin or purpose

### Add comments for non-obvious algorithms, workarounds, or technical debt (`TODO`, `FIXME`)

### Delete commented-out code -- version control preserves history

```python
# Good
def process_order(order: Order) -> None:
    validate(order)
    save(order)

# Bad
def process_order(order: Order) -> None:
    # old_validate(order)
    validate(order)
    # send_email(order)  # TODO: maybe later?
    save(order)
```

### Avoid comments that repeat what code already expresses

## Docstring Rules

### Avoid docstrings by default -- prefer self-explanatory code through good naming

```python
# Good
def calculate_shipping_cost(weight_kg: float, destination_country: str) -> Decimal:
    ...

# Bad
def calculate_shipping_cost(weight_kg: float, destination_country: str) -> Decimal:
    """
    Calculate the shipping cost.

    Args:
        weight_kg: The weight in kg
        destination_country: The destination country
    """
    ...
```

### Reserve docstrings for library public APIs or explicitly specified contexts
