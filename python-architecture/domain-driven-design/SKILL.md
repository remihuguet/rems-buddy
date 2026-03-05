---
name: domain-driven-design
description: "DDD patterns: value objects, entities, aggregates, repositories, domain events, and commands"
---

# Domain-Driven Design Patterns

## Rules

### Use Value Objects for concepts defined by their attributes, not identity

Implement as immutable dataclasses with `frozen=True`, validation in `__post_init__`, and specific names like `CompanyId` or `Money`.

```python
# Good
@dataclass(frozen=True)
class Money:
    amount: Decimal
    currency: str

    def __post_init__(self):
        if self.amount < 0:
            raise ValueError("Amount cannot be negative")
        if self.currency not in ["USD", "EUR"]:
            raise ValueError("Invalid currency")

    def add(self, other: "Money") -> "Money":
        if self.currency != other.currency:
            raise ValueError("Cannot add different currencies")
        return Money(self.amount + other.amount, self.currency)

# Bad -- mutable, generic name, no validation
@dataclass
class Value:
    amount: float
    currency: str
```

### Use Entities for concepts with persistent identity and lifecycle

Mutable dataclasses with a unique id field (typically UUID), equality based only on identity, domain behaviors encapsulated as methods.

```python
# Good
@dataclass
class Company:
    id: CompanyId
    name: str
    active: bool = False
    _users: list[UserId] = field(default_factory=list)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Company):
            return False
        return self.id == other.id

    def activate(self) -> None:
        if not self.name:
            raise ValueError("Cannot activate without name")
        self.active = True

# Bad -- frozen entity (should be mutable), no behavior methods (anemic model)
@dataclass(frozen=True)
class Company:
    id: CompanyId
    name: str
```

### Define Aggregates as consistency boundaries with a root entity

All external access goes through the aggregate root. Business invariants enforced within aggregate methods. Each aggregate has exactly one repository.

```python
# Good
@dataclass
class Order:  # Aggregate root
    id: OrderId
    customer_id: CustomerId
    _line_items: list[LineItem] = field(default_factory=list)

    def add_item(self, product_id: ProductId, quantity: int) -> None:
        if quantity <= 0:
            raise ValueError("Quantity must be positive")
        self._line_items.append(LineItem(product_id, quantity))

@dataclass(frozen=True)
class LineItem:  # Part of Order aggregate, no identity
    product_id: ProductId
    quantity: int

# Bad -- separate repository for aggregate member
class LineItemRepository:
    async def save(self, line_item: LineItem) -> None: pass
```

### Create one repository per aggregate root with collection-like semantics

Define the repository interface as a port in the domain layer with methods like `get(id)`, `save(entity)`, `list()`, `delete(entity)`.

```python
# Good -- domain/ports.py
class CompanyRepository(ABC):
    @abstractmethod
    async def get(self, id: CompanyId) -> Company | None: pass
    @abstractmethod
    async def save(self, company: Company) -> None: pass
    @abstractmethod
    async def list(self) -> list[Company]: pass
    @abstractmethod
    async def delete(self, company: Company) -> None: pass

# Bad -- non-collection-like methods
class CompanyRepository(ABC):
    async def create_company(self, name: str) -> Company: pass
    async def update_company_name(self, id, name) -> None: pass
```

### Use Domain Events to represent significant things that happened

Name with past tense verbs (e.g., `CompanyCreated`, `UserActivated`). Make them immutable with minimal data (prefer IDs over full objects).

```python
# Good
@dataclass(frozen=True)
class CompanyCreated:
    company_id: CompanyId
    created_at: datetime

# Bad -- imperative name (that's a command), full object (heavy, stale data risk)
@dataclass
class CreateCompany:
    company: Company
    action: str
```

### Use Commands to represent intentions to change state

Name with imperative verbs (e.g., `CreateCompany`, `ActivateUser`). Contain all data needed for the operation. Each command has a dedicated handler in the service layer.

```python
# Good
@dataclass(frozen=True)
class CreateCompany:
    name: str
    admin_email: str

async def handle_create_company(
    command: CreateCompany, repository: CompanyRepository
) -> CompanyId:
    company = Company(id=CompanyId(uuid4()), name=command.name)
    await repository.save(company)
    return company.id

# Bad -- past tense name (that's an event), generic/untyped
@dataclass(frozen=True)
class CompanyCommand:
    action: str
    data: dict
```

### Implement the Repository pattern to abstract persistence from domain logic

Define collection-like interfaces in the domain, implement in adapters, use fake/in-memory implementations for unit testing.

```python
# domain/ports.py
class CompanyRepository(ABC):
    @abstractmethod
    async def save(self, company: Company) -> None: pass

# adapters/repositories.py
class PostgresCompanyRepository(CompanyRepository):
    async def save(self, company: Company) -> None: ...

# tests/unit/fakes.py
class FakeCompanyRepository(CompanyRepository):
    def __init__(self):
        self._companies: dict[CompanyId, Company] = {}
    async def save(self, company: Company) -> None:
        self._companies[company.id] = company
```

### Place domain services in the domain layer for operations spanning multiple entities

```python
# Good -- domain/transfer_service.py
class MoneyTransferService:
    def transfer(self, from_account: Account, to_account: Account, amount: Money) -> None:
        if from_account.currency != to_account.currency:
            raise ValueError("Cannot transfer between different currencies")
        from_account.withdraw(amount)
        to_account.deposit(amount)

# Bad -- in entity when it spans multiple entities
class Account:
    def transfer_to(self, other_account: Account, amount: Money) -> None:
        self.withdraw(amount)
        other_account.deposit(amount)
```

### Maintain an events list on aggregate roots to track domain events

```python
# Good
@dataclass
class Company:
    id: CompanyId
    name: str
    active: bool = False
    events: list[DomainEvent] = field(default_factory=list)

    def activate(self) -> None:
        self.active = True
        self.events.append(CompanyActivated(self.id))

# Bad -- no event tracking on aggregate
@dataclass
class Company:
    id: CompanyId
    name: str
    active: bool = False

    def activate(self) -> None:
        self.active = True
        # Caller must remember to emit event
```

### Clear aggregate events after collection to prevent duplicate processing

```python
# Good
def collect_new_events(self) -> Generator[DomainEvent, None, None]:
    for aggregate in self.companies.seen:
        while aggregate.events:
            yield aggregate.events.pop(0)

# Bad -- events not cleared
def collect_new_events(self) -> list[DomainEvent]:
    events = []
    for aggregate in self.companies.seen:
        events.extend(aggregate.events)  # List unchanged
    return events
```

### Keep domain events minimal -- store only essential identifiers, not full objects

```python
# Good
@dataclass(frozen=True)
class CompanyActivated(DomainEvent):
    company_id: CompanyId

# Bad -- full aggregate in event
@dataclass(frozen=True)
class CompanyActivated(DomainEvent):
    company: Company  # Heavy, may become stale, hard to serialize
```
