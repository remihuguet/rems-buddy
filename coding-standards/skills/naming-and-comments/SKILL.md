---
name: naming-and-comments
description: This user's opinionated rules for docstrings, comments, and naming — notably no docstrings by default, and comments that explain why rather than what. Use when writing or reviewing non-trivial application code.
---

# Naming and comments

## Docstrings are off by default

Don't write them. A precise name plus type hints carries the contract. Add a docstring only for a library's genuinely public API, or when asked.

```python
def calculate_shipping_cost(weight_kg: float, destination_country: str) -> Decimal: ...
```

## Comments explain why, never what

Comment business rules, non-obvious algorithms, workarounds, and where they came from. Never restate what the line already says.

```python
# Premium users get bonus points monthly to encourage retention (Q1 2024 strategy)
if user.is_premium:
    user.points += 10
```

Delete commented-out code rather than leaving it — git has the history.

## Naming

Use the domain's own vocabulary, one term per concept, consistently across the codebase — if the business says "member", the code doesn't say "user" in half the modules. Names should carry intent: `is_eligible_for_refund` over `flag`, `calculate_premium_discount` over `calc_disc`.
