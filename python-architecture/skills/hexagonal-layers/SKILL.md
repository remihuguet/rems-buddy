---
name: hexagonal-layers
description: "Five-layer hexagonal architecture: domain, service, adapters, views, and entrypoints"
---

# Layer Responsibilities and Dependencies

Five-layer architecture following the Ports and Adapters (Hexagonal Architecture) pattern. Dependency flow: **entrypoints -> service -> domain <- adapters**. Views bypass domain for read performance.

## Rules

### Domain layer: pure business logic with zero external dependencies

Contains entities, value objects, aggregates, domain services, domain events, and commands. All I/O dependencies expressed as ports (abstract interfaces).

```python
# Good -- domain/company.py
from dataclasses import dataclass
from uuid import UUID
from abc import ABC, abstractmethod

@dataclass(frozen=True)
class CompanyId:
    value: UUID

@dataclass
class Company:
    id: CompanyId
    name: str

    def activate(self) -> None:
        if not self.name:
            raise ValueError("Cannot activate company without name")

# domain/ports.py
class CompanyRepository(ABC):
    @abstractmethod
    async def save(self, company: Company) -> None:
        pass

# Bad -- importing database library in domain
import sqlalchemy
from app.adapters.database import session
```

### Service layer: use case handlers depending only on the domain layer

Orchestrates business operations by coordinating repositories, enforcing business rules, and managing transactions through UnitOfWork and MessageBus.

```python
# Good -- service/company.py
from app.domain.company import Company, CompanyId
from app.domain.ports import CompanyRepository

async def create_company(name: str, repository: CompanyRepository) -> CompanyId:
    company = Company(id=CompanyId(uuid4()), name=name)
    company.activate()
    await repository.save(company)
    return company.id

# Bad -- importing adapters directly in service
from app.adapters.postgres_repository import PostgresCompanyRepository
```

### Adapters layer: infrastructure implementations of domain ports

Place all infrastructure concerns here: database repositories, external API clients, email services, message queue connectors.

```python
# Good -- adapters/repositories.py
from app.domain.company import Company, CompanyId
from app.domain.ports import CompanyRepository

class PostgresCompanyRepository(CompanyRepository):
    def __init__(self, session: AsyncSession):
        self.session = session

    async def save(self, company: Company) -> None:
        await self.session.execute(
            sqlalchemy.insert(companies_table).values(
                id=company.id.value, name=company.name
            )
        )
```

### Views layer: query operations bypassing the domain model

Read-only functions that query databases directly for performance, maintaining type hints based on domain models.

```python
# Good -- views/company.py
async def get_company_names(session: AsyncSession) -> list[tuple[CompanyId, str]]:
    result = await session.execute(
        "SELECT id, name FROM companies WHERE active = true"
    )
    return [(CompanyId(row.id), row.name) for row in result]

# Bad -- modifying state in a view
async def get_and_activate_company(company_id, session):
    await session.execute("UPDATE companies SET active = true WHERE id = :id", ...)
```

### Entrypoints layer: thin with only serialization, deserialization, and dependency injection

Contains FastAPI routes, CLI commands, pub/sub consumers, scheduled jobs. No business logic.

```python
# Good -- entrypoints/api/companies.py
@router.post("/companies")
async def create_company_endpoint(
    request: CreateCompanyRequest,
    repository: CompanyRepository = Depends(get_repository)
):
    company_id = await create_company(request.name, repository)
    return {"id": str(company_id.value)}

# Bad -- business logic in entrypoint
@router.post("/companies")
async def create_company_endpoint(request, repository):
    if not request.name or len(request.name) < 3:
        raise HTTPException(400, "Name too short")
    company = Company(id=CompanyId(uuid4()), name=request.name)
    await repository.save(company)
```

### Enforce strict dependency flow: entrypoints -> service -> domain <- adapters

Domain never imports from outer layers. Service only imports from domain. Adapters implement interfaces defined in domain.

```python
# Good
# domain/ports.py - defines interface
class EmailSender(ABC):
    @abstractmethod
    async def send(self, to: str, subject: str, body: str) -> None: pass

# service/notifications.py - depends on port
async def notify_user(email: str, sender: EmailSender) -> None:
    await sender.send(email, "Welcome", "Hello!")

# adapters/email.py - implements port
class SendGridEmailSender(EmailSender):
    async def send(self, to: str, subject: str, body: str) -> None: ...

# Bad -- domain importing from adapters
from app.adapters.email import SendGridEmailSender
```

### Define all ports (interfaces) in the domain layer, never in adapters

Use Python's ABC or Protocol to specify contracts for repositories, external services, and other I/O dependencies.

### Place UnitOfWork and MessageBus in the service layer

Infrastructure coordination patterns belong in the service layer, not the domain layer.

```python
# Good -- service/unit_of_work.py
class UnitOfWork(Protocol):
    companies: CompanyRepository
    def commit(self) -> None: ...
    def collect_new_events(self) -> Generator[DomainEvent]: ...
```

### Define UnitOfWork as a @runtime_checkable Protocol for structural typing

Enables test doubles to implement the interface through duck typing without explicit inheritance.

```python
@runtime_checkable
class UnitOfWork(Protocol):
    companies: CompanyRepository

    def __enter__(self) -> "UnitOfWork": ...
    def __exit__(self, *args) -> None: ...
    def commit(self) -> None: ...
    def rollback(self) -> None: ...
    def collect_new_events(self) -> Generator[DomainEvent, None, None]: ...

# Test double -- no inheritance needed
class FakeUnitOfWork:
    def __init__(self):
        self.companies = FakeCompanyRepository()
        self.committed = False

    def __enter__(self): return self
    def __exit__(self, *args): self.rollback()
    def commit(self): self.committed = True
    def rollback(self): pass
    def collect_new_events(self):
        for company in self.companies.seen:
            while company.events:
                yield company.events.pop(0)
```
