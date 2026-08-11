---
name: file-organization
description: Module and file layout rules for this user's Python projects — group first and split on evidence, no utils/helpers/common modules, __init__.py as the public API. Use when creating new Python modules or deciding where code belongs.
paths: "**/*.py"
---

# File organization

## Group first, split on evidence

Keep an aggregate's entities, value objects, and events together in one module until it earns a split — roughly 300–400 lines, or more than five or six substantial components. `domain/company.py` holding `CompanyId`, `CompanyName`, and `Company` is correct; `company_id.py`, `company_name.py`, and `company_entity.py` at 30 lines each is a directory tree pretending to be a design.

Same for adapters: all repositories in `adapters/repositories.py`, all clients in `adapters/clients.py`, split when an individual implementation grows heavy.

## No `utils`, `helpers`, or `common`

These have no admission criteria, so everything ends up in them and nothing can be found. Name the module after what's in it and put it next to what uses it — `domain/email_validation.py`, not `utils/helpers.py`.

## When you do split, `__init__.py` is the public API

Re-export so consumers import from the package and stay ignorant of the internal layout:

```python
# domain/company/__init__.py
from .entity import Company
from .events import CompanyCreated
from .value_objects import CompanyId, CompanyName

__all__ = ["Company", "CompanyCreated", "CompanyId", "CompanyName"]
```

```python
from app.domain.company import Company, CompanyId          # ✔
from app.domain.company.value_objects import CompanyId     # ✘ couples to internals
```
