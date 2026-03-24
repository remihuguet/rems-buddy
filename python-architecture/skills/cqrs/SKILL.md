---
name: cqrs
description: "CQRS pattern: separate write operations (commands) from read operations (queries)"
---

# CQRS Pattern

Command Query Responsibility Segregation: separate write operations (commands) from read operations (queries). Commands go through the service layer with full domain validation. Queries can bypass the domain model for performance.

## Rules

### Separate write operations (commands) from read operations (queries)

Route all state modifications through the service layer with full domain validation. Provide dedicated query functions in the views layer.

```python
# Good
# service/company.py -- COMMAND (write)
async def activate_company(
    company_id: CompanyId, repository: CompanyRepository
) -> None:
    company = await repository.get(company_id)
    company.activate()  # Domain validation
    await repository.save(company)

# views/company.py -- QUERY (read)
async def get_active_companies(session: AsyncSession) -> list[dict]:
    result = await session.execute(
        "SELECT id, name FROM companies WHERE active = true"
    )
    return [{"id": row.id, "name": row.name} for row in result]

# Bad -- mixing command and query
async def get_and_activate_company(company_id, repository):
    company = await repository.get(company_id)
    company.activate()  # Side effect in query
    await repository.save(company)
    return company
```

### Allow views to bypass the domain model and query databases directly

Optimize read performance by accessing data stores without domain object instantiation.

```python
# Good -- views/dashboard.py
@dataclass
class CompanySummary:
    company_id: UUID
    name: str
    user_count: int

async def get_company_dashboard(session: AsyncSession) -> list[CompanySummary]:
    result = await session.execute("""
        SELECT c.id, c.name, COUNT(u.id) as user_count
        FROM companies c LEFT JOIN users u ON u.company_id = c.id
        GROUP BY c.id, c.name
    """)
    return [CompanySummary(**row) for row in result]

# Bad -- loading full domain objects for simple query
async def get_company_names(repository: CompanyRepository) -> list[str]:
    companies = await repository.list()
    return [company.name for company in companies]
```

### Ensure query operations have no side effects and never modify state

Views are purely for data retrieval, returning simple DTOs or domain objects.

```python
# Good -- pure query
async def get_company_statistics(company_id: CompanyId, session: AsyncSession) -> dict:
    result = await session.execute(
        "SELECT COUNT(*) as user_count FROM users WHERE company_id = :id",
        {"id": company_id.value}
    )
    return {"user_count": result.scalar()}

# Bad -- side effects in view
async def get_company_and_log_access(company_id, session):
    await session.execute(
        "INSERT INTO access_log (company_id, accessed_at) VALUES (:id, NOW())", ...
    )
    return await session.get(Company, company_id.value)
```
