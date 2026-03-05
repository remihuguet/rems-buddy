---
name: architecture-pitfalls
description: "Common architecture anti-patterns to avoid in domain-centric layered applications"
---

# Common Architecture Pitfalls

## Rules

### Never put business logic in entrypoints

Keep entrypoints exclusively for input validation, data serialization/deserialization, dependency injection, and calling service layer functions.

```python
# Good -- entrypoints/api/companies.py
@router.post("/companies")
async def create_company_endpoint(
    request: CreateCompanyRequest,
    repo: CompanyRepository = Depends(get_repository)
):
    company_id = await create_company(request.name, repo)
    return {"id": str(company_id.value)}

# Bad -- business validation and orchestration in entrypoint
@router.post("/companies")
async def create_company_endpoint(request, repo):
    if len(request.name) < 3:
        raise HTTPException(400, "Name too short")
    company = Company(id=CompanyId(uuid4()), name=request.name)
    company.activate()
    await repo.save(company)
```

### Never import concrete adapters in the domain layer

Depend only on abstract ports (interfaces) defined within the domain.

```python
# Good -- domain/company.py
from app.domain.ports import EmailSender  # Port, not adapter

class Company:
    async def notify_activation(self, sender: EmailSender) -> None:
        await sender.send(self.admin_email, "Activated", "...")

# Bad
from app.adapters.sendgrid import SendGridClient  # Concrete adapter in domain
```

### Never test through multiple layers in a single test

Use appropriate test doubles for each layer: fakes in unit tests, real dependencies in integration tests, full stack in e2e tests.

```python
# Good -- tests/unit/test_company_service.py (single layer)
async def test_create_company():
    fake_repo = FakeCompanyRepository()
    company_id = await create_company("ACME", fake_repo)
    assert fake_repo._companies[company_id].name == "ACME"

# Bad -- testing entrypoint + service + adapter + database in one test
async def test_create_company_endpoint(client, db_session):
    response = await client.post("/companies", json={"name": "ACME"})
```

### Never create circular dependencies between layers

Follow strict dependency flow: dependencies point inward toward the domain.

```python
# Good
# entrypoints -> service -> domain <- adapters

# Bad
# domain/company.py
from app.service.company import notify_admins  # domain -> service
# service/company.py
from app.adapters.repositories import PostgresRepo  # service -> adapter
```

### Never create premature abstractions before the third repetition

Duplication is cheaper than the wrong abstraction. Only extract common code after seeing the pattern three times.

```python
# Good -- first and second occurrence: inline
def create_user(name: str) -> User:
    if not name or len(name) < 2:
        raise ValueError("Name too short")
    return User(name=name)

def create_company(name: str) -> Company:
    if not name or len(name) < 2:
        raise ValueError("Name too short")
    return Company(name=name)

# Third occurrence -- now extract
def validate_name(name: str) -> None:
    if not name or len(name) < 2:
        raise ValueError("Name too short")

# Bad -- abstracting after first use
def validate_entity_name(name: str, min_length: int = 2) -> None: ...
```

### Never bypass the service layer to directly call repositories from entrypoints

Always route operations through service handlers to ensure business rules are enforced and transactions are properly managed.

```python
# Good
@router.post("/companies/{id}/activate")
async def activate_endpoint(id: UUID, repo = Depends(get_repository)):
    await activate_company(CompanyId(id), repo)
    return {"status": "activated"}

# Bad -- bypassing service layer
@router.post("/companies/{id}/activate")
async def activate_endpoint(id: UUID, repo = Depends()):
    company = await repo.get(CompanyId(id))
    company.active = True  # No business rule enforcement
    await repo.save(company)
```
