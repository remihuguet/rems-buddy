---
name: naming-and-comments
description: This user's opinionated rules for docstrings, comments, and naming — no docstrings by default, comments stripped to the vital minimum and only for context that naming and abstraction cannot carry, never a changelog. Use when writing or reviewing non-trivial application code.
---

# Naming and comments

## Docstrings are off by default

Don't write them. A precise name plus type hints carries the contract. Add a docstring only for a library's genuinely public API, or when asked.

```python
def calculate_shipping_cost(weight_kg: float, destination_country: str) -> Decimal: ...
```

## Comments are the last resort, not the first

The code carries the explanation. A comment is only for context that naming and abstraction genuinely cannot express: a business rule and the decision behind it, a workaround and what it works around, a constraint that isn't visible from the code.

Before writing one, try to make the code say it instead — rename the value, extract the condition into a named predicate, pull the block into a function whose name is the sentence you were about to type. If that works, the comment is redundant.

Strip comments to the bare, vital minimum. Never restate what the line already says.

```python
# Monthly rather than per-order: retention experiment, see RFC-14
if user.is_premium:
    user.points += 10
```

A comment is not a changelog. No "changed to X", no "previously Y", no dated edit notes, no marking which ticket last touched the line. Pointing at the decision behind a rule is context and belongs; recording that the line changed is history and belongs in git. Delete commented-out code rather than leaving it.

## Naming

Use the domain's own vocabulary, one term per concept, consistently across the codebase — if the business says "member", the code doesn't say "user" in half the modules. Names should carry intent: `is_eligible_for_refund` over `flag`, `calculate_premium_discount` over `calc_disc`.
