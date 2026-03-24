---
name: file-organization
description: "File organization principles: start grouped, split when complex, avoid generic module names"
---

# File Organization Principles

## Rules

### Start with grouped files and split only when complexity requires it

Keep related entities, value objects, and use cases together in single files until they exceed 300-400 lines or contain more than 5-6 major components.

```python
# Good -- domain/company.py (grouped together initially)
@dataclass(frozen=True)
class CompanyId:
    value: UUID

@dataclass(frozen=True)
class CompanyName:
    value: str
    def __post_init__(self):
        if len(self.value) < 2:
            raise ValueError("Name too short")

@dataclass
class Company:
    id: CompanyId
    name: CompanyName
    active: bool = False

# Bad -- premature split into separate files
# domain/company_id.py
# domain/company_name.py
# domain/company_entity.py
```

### Avoid generic module names like utils, helpers, or common

Use specific, descriptive names that reveal intent and place utilities close to where they're used.

```python
# Good
# domain/email_validation.py
def is_valid_email(email: str) -> bool:
    return "@" in email and "." in email.split("@")[1]

# Bad -- generic dumping ground
# utils/helpers.py
def is_valid_email(email): pass
def format_date(date): pass
def parse_json(json): pass
def hash_password(pwd): pass
def send_email(to, body): pass  # Mixed concerns
```

### Use __init__.py to expose public APIs when splitting modules

Maintain discoverability by re-exporting key classes so consumers import from the package level.

```python
# Good -- domain/company/__init__.py
from .entity import Company
from .value_objects import CompanyId, CompanyName
from .events import CompanyCreated

__all__ = ["Company", "CompanyId", "CompanyName", "CompanyCreated"]

# service/company.py -- clean import
from app.domain.company import Company, CompanyId

# Bad -- consumers must know internal structure
from app.domain.company.entity import Company
from app.domain.company.value_objects import CompanyId
```

### Group adapters by type initially, splitting when individual implementations grow complex

Keep all repositories in `repositories.py` and all API clients in `clients.py` until specific adapters warrant their own modules.

```python
# Good -- adapters/repositories.py (grouped initially)
class PostgresCompanyRepository(CompanyRepository): pass
class PostgresUserRepository(UserRepository): pass

# Split when PostgresCompanyRepository grows to 200+ lines

# Bad -- premature split with only 50 lines each
# adapters/postgres_company_repository.py
# adapters/postgres_user_repository.py
```
