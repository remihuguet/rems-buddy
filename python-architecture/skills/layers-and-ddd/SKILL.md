---
name: layers-and-ddd
description: Five-layer hexagonal architecture and DDD building blocks for this user's Python backends — layer responsibilities, dependency direction, ports and adapters, value objects, entities, aggregates, and repositories. Use when adding or reviewing code in a Python service that has domain/, service/, adapters/, views/, or entrypoints/ directories.
paths: "**/*.py"
---

# Layers and DDD

Dependency direction, and the whole point of the arrangement:

```
entrypoints ──▶ service ──▶ domain ◀── adapters
                              ▲
                   views ──────┘  (reads only; may bypass domain)
```

The domain imports from nothing outside itself. Everything else points inward.

## Layer responsibilities

**`domain/`** — entities, value objects, aggregates, domain services, events, commands, and the ports. No I/O, no framework imports, no `sqlalchemy`, no adapter imports. Every external dependency appears as an abstract port defined *here*, never in `adapters/`.

```python
# domain/ports.py
class CompanyRepository(ABC):
    @abstractmethod
    async def get(self, id: CompanyId) -> Company | None: ...
    @abstractmethod
    async def save(self, company: Company) -> None: ...
```

**`service/`** — use-case handlers. Imports the domain and its ports, never a concrete adapter. Owns transaction boundaries (`UnitOfWork`) and message routing (`MessageBus`).

```python
# service/company.py
async def create_company(name: str, repository: CompanyRepository) -> CompanyId:
    company = Company(id=CompanyId(uuid4()), name=name)
    company.activate()
    await repository.save(company)
    return company.id
```

**`adapters/`** — infrastructure implementations of domain ports: repositories, API clients, email senders, queue connectors.

**`views/`** — read-only query functions. These may query the database directly and skip the domain model entirely; see the `messaging-and-cqrs` skill.

**`entrypoints/`** — FastAPI routes, CLI commands, consumers, scheduled jobs. Serialization, deserialization, dependency injection, and a call into `service/`. Nothing else.

```python
# entrypoints/api/companies.py
@router.post("/companies")
async def create_company_endpoint(
    request: CreateCompanyRequest,
    repository: CompanyRepository = Depends(get_repository),
):
    company_id = await create_company(request.name, repository)
    return {"id": str(company_id.value)}
```

Business validation in an entrypoint, or an entrypoint reaching past `service/` straight to a repository, both defeat the arrangement: the rule stops being enforced anywhere.

## Building blocks

### Value objects — identity is the attributes

Immutable, validated on construction, specifically named.

```python
@dataclass(frozen=True)
class Money:
    amount: Decimal
    currency: str

    def __post_init__(self) -> None:
        if self.amount < 0:
            raise ValueError("Amount cannot be negative")

    def add(self, other: "Money") -> "Money":
        if self.currency != other.currency:
            raise ValueError("Cannot add different currencies")
        return Money(self.amount + other.amount, self.currency)
```

### Entities — identity persists, state changes

Mutable, equality on identity alone, behaviour as methods. An entity with only fields and no behaviour is an anemic model — the business rules ended up somewhere they can't be enforced.

```python
@dataclass
class Company:
    id: CompanyId
    name: str
    active: bool = False

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Company) and self.id == other.id

    def activate(self) -> None:
        if not self.name:
            raise ValueError("Cannot activate company without name")
        self.active = True
```

### Aggregates — the consistency boundary

One root entity, all external access through it, invariants enforced in its methods. Members of the aggregate have no repository of their own.

```python
@dataclass
class Order:                              # aggregate root
    id: OrderId
    customer_id: CustomerId
    _line_items: list[LineItem] = field(default_factory=list)

    def add_item(self, product_id: ProductId, quantity: int) -> None:
        if quantity <= 0:
            raise ValueError("Quantity must be positive")
        self._line_items.append(LineItem(product_id, quantity))


@dataclass(frozen=True)
class LineItem:                           # inside the Order aggregate, no identity
    product_id: ProductId
    quantity: int
```

### Repositories — one per aggregate root, collection-like

Port in the domain, implementation in adapters, fake in tests. Methods read as a collection: `get`, `save`, `list`, `delete` — not `update_company_name(id, name)`, which leaks a use case into the persistence contract.

### Commands and events — the naming carries the meaning

Commands are imperative and represent an intention; events are past tense and represent a fact. Both immutable. Events carry identifiers, not whole aggregates, which would be heavy, go stale, and resist serialization.

```python
@dataclass(frozen=True)
class CreateCompany:            # command — imperative, one handler
    name: str
    admin_email: str

@dataclass(frozen=True)
class CompanyActivated:         # event — past tense, many handlers
    company_id: CompanyId
```

### Domain services — for operations spanning entities

When behaviour belongs to no single entity, it goes in a domain service rather than being bolted onto whichever entity happened to be convenient.

```python
# domain/transfer.py
class MoneyTransferService:
    def transfer(self, source: Account, target: Account, amount: Money) -> None:
        if source.currency != target.currency:
            raise ValueError("Cannot transfer between different currencies")
        source.withdraw(amount)
        target.deposit(amount)
```

## Abstract on the third repetition, not the first

Duplication is cheaper than the wrong abstraction. Two similar validators stay inline; extract when a third appears and the shared shape is actually clear.
