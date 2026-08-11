---
name: testing-strategy
description: This user's testing strategy for Python projects — the three-tier unit/integration/e2e split, what "unit test" means here (behavior through entry points with fakes, not per-class tests), fakes over mocks, and test naming. Use when adding, reorganizing, or reviewing Python tests.
paths: "**/*.py"
---

# Testing strategy

## Three tiers, diamond-shaped

```
tests/
├── unit/            ← most tests live here
│   ├── test_company_service.py
│   └── fakes.py
├── integration/     ← adapters and views, real dependencies
│   ├── test_repositories.py
│   └── test_views.py
└── e2e/             ← critical paths only
    └── test_api.py
```

## "Unit test" means behavior through an entry point, with fakes

Not a test per class. Call the service function with in-memory fakes and assert on the observable outcome. Low-level tests of individual objects are reserved for genuinely intricate algorithms that benefit from isolation.

```python
async def test_create_company__should_persist_an_active_company():
    fake_repo = FakeCompanyRepository()

    company_id = await create_company("ACME Corp", fake_repo)

    saved = await fake_repo.get(company_id)
    assert saved.name == "ACME Corp"
    assert saved.active is True
```

This is why a test spanning entrypoint → service → adapter → database in one go is a problem: when it fails, it hasn't told you which layer broke.

**Integration tests** exercise adapters and views against the real thing — database, filesystem, network. **E2E tests** cover critical user paths only, and check serialization, status codes, and routing rather than re-testing business rules already covered in `unit/`.

## Fakes over mocks

A fake is a working in-memory implementation of the port. It survives renaming `save` to `store`; `mock_repo.save.assert_called_once()` does not, which is how a green suite ends up proving only that the code still calls the methods it used to.

```python
class FakeCompanyRepository(CompanyRepository):
    def __init__(self) -> None:
        self._companies: dict[CompanyId, Company] = {}

    async def save(self, company: Company) -> None:
        self._companies[company.id] = company

    async def get(self, id: CompanyId) -> Company | None:
        return self._companies.get(id)
```

Stubs are fine for canned responses from external services. Reach for `unittest.mock` only when there's no seam to inject through — and when that happens, the production code usually wants dependency injection rather than the test wanting a mock.

## Naming and shape

`test_{subject}__should_{expected_behavior}` — the subject is the behavior under test, not the method name.

```python
def test_premium_customer__should_receive_a_discount(): ...        # ✔
def test_order__should_reject_an_out_of_stock_product(): ...       # ✔
def test_calculate_total_method(): ...                             # ✘ names the implementation
def test_order_validation(): ...                                   # ✘ asserts nothing in particular
```

Arrange / Act / Assert, separated by blank lines, one behavior per test. A test that acts twice is two tests.
