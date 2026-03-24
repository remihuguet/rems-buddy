---
name: testing-organization
description: "Three-tier testing strategy: unit (fakes), integration (real deps), e2e (critical paths)"
---

# Testing Organization

## Rules

### Organize tests in three folders: unit, integration, and e2e

Place the majority of tests in `unit/` for service layer testing with fakes, fewer tests in `integration/` for adapters with real dependencies, and minimal tests in `e2e/` for critical entrypoint paths.

```
# Good
tests/
├── unit/               # MOST tests here
│   ├── test_company_service.py
│   ├── test_user_service.py
│   └── fakes.py       # Fake implementations
├── integration/        # Some tests here
│   ├── test_repositories.py
│   └── test_views.py
└── e2e/               # Few tests here
    └── test_api.py    # Critical paths only

# Bad
tests/
├── test_everything.py  # All tests mixed together
└── unit/
    ├── test_company.py
    ├── test_repository.py  # Should be in integration
    └── test_api.py        # Should be in e2e
```

### Test domain logic through the service layer using fake implementations

Write unit tests that call service functions with in-memory repositories and mocks, ensuring fast, deterministic, and isolated tests without I/O.

```python
# Good
class FakeCompanyRepository(CompanyRepository):
    def __init__(self):
        self._companies = {}

    async def save(self, company: Company) -> None:
        self._companies[company.id] = company

async def test_create_company():
    fake_repo = FakeCompanyRepository()

    company_id = await create_company("ACME Corp", fake_repo)

    saved_company = fake_repo._companies[company_id]
    assert saved_company.name == "ACME Corp"
    assert saved_company.active is True

# Bad -- using real database in unit test
async def test_create_company(db_session):
    repo = PostgresCompanyRepository(db_session)
    company_id = await create_company("ACME Corp", repo)
```

### Test adapters and views with real external dependencies in integration tests

```python
# Good
async def test_postgres_company_repository_saves_and_retrieves(db_session):
    repo = PostgresCompanyRepository(db_session)
    company = Company(id=CompanyId(uuid4()), name="ACME Corp")

    await repo.save(company)
    retrieved = await repo.get(company.id)

    assert retrieved.id == company.id
    assert retrieved.name == "ACME Corp"
```

### Test entrypoints end-to-end focusing only on serialization and HTTP semantics

Validate status codes, request/response formats, and routing without retesting business logic already covered by unit tests.

```python
# Good
async def test_create_company_endpoint_returns_201(client):
    response = await client.post("/companies", json={"name": "ACME Corp"})

    assert response.status_code == 201
    assert "id" in response.json()
    assert UUID(response.json()["id"])

# Bad -- retesting business logic in e2e
async def test_create_company_validates_name_length(client):
    response = await client.post("/companies", json={"name": "A"})
    assert response.status_code == 400
    assert "Name too short" in response.json()["detail"]
```
