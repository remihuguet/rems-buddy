---
name: messaging-and-cqrs
description: MessageBus, UnitOfWork, and command/query separation for this user's Python backends — handler signatures, event collection from aggregates, transaction boundaries, and read-side views that bypass the domain. Use when touching a MessageBus, UnitOfWork, command/event handler, or a views/ query in a Python service.
paths: "**/*.py"
---

# Messaging and CQRS

Follows the Cosmic Python MessageBus pattern. Both `MessageBus` and `UnitOfWork` live in `service/` — they coordinate infrastructure, so they don't belong in the domain.

## Commands write, queries read

Commands go through `service/` and get the full domain treatment: load the aggregate, call its method, let it enforce its invariants, commit. Queries live in `views/` and may hit the database directly, returning DTOs without instantiating a single domain object.

```python
# service/company.py — command
async def activate_company(company_id: CompanyId, repository: CompanyRepository) -> None:
    company = await repository.get(company_id)
    company.activate()
    await repository.save(company)

# views/dashboard.py — query
@dataclass
class CompanySummary:
    company_id: UUID
    name: str
    user_count: int

async def get_company_dashboard(session: AsyncSession) -> list[CompanySummary]:
    result = await session.execute("""
        SELECT c.id, c.name, COUNT(u.id) AS user_count
        FROM companies c LEFT JOIN users u ON u.company_id = c.id
        GROUP BY c.id, c.name
    """)
    return [CompanySummary(**row) for row in result]
```

Loading full aggregates to read three fields off them is the read-side mistake; a query that writes anything — even an access log — is the write-side one. A function named `get_and_activate_company` is both.

## UnitOfWork — a Protocol, with explicit commit

`@runtime_checkable` Protocol so fakes satisfy it structurally, no inheritance needed. `__exit__` always rolls back: commit is something a handler does deliberately, so an early return or a raised exception can never leave a half-written transaction.

```python
@runtime_checkable
class UnitOfWork(Protocol):
    companies: CompanyRepository

    def __enter__(self) -> "UnitOfWork": ...
    def __exit__(self, *args) -> None: ...       # calls rollback() unconditionally
    def commit(self) -> None: ...
    def rollback(self) -> None: ...
    def collect_new_events(self) -> Generator[DomainEvent, None, None]: ...
```

## Handlers take `(Message, UnitOfWork)` and return nothing

State changes go through the UoW; events are appended to the aggregate's own `events` list rather than returned, so an aggregate mutated deep in a call stack still gets its events published.

```python
def create_company(cmd: CreateCompany, uow: UnitOfWork) -> None:
    with uow:
        company = Company(id=CompanyId.generate(), name=cmd.name)
        company.events.append(CompanyCreated(company.id))
        uow.companies.add(company)
        uow.commit()
```

## Aggregates accumulate events; the UoW drains them

Popping as it yields is what makes this safe to call repeatedly — the bus drains after every handler, and an event already dispatched is gone from the list.

```python
def collect_new_events(self) -> Generator[DomainEvent, None, None]:
    for aggregate in self.companies.seen:
        while aggregate.events:
            yield aggregate.events.pop(0)
```

## The bus: FIFO queue, drained after each handler

Commands are one-to-one with handlers; events are one-to-many. An unrecognized message type raises rather than falling through, so a message never disappears silently.

```python
COMMAND_HANDLERS: dict[type[Command], CommandHandler] = {
    CreateCompany: create_company,
}
EVENT_HANDLERS: dict[type[DomainEvent], list[EventHandler]] = {
    CompanyCreated: [notify_admin, send_welcome_email],
}

class MessageBus:
    MAX_ITERATIONS = 100

    def handle(self, message: Message) -> None:
        self.queue.append(message)
        iterations = 0
        while self.queue:
            iterations += 1
            if iterations > self.MAX_ITERATIONS:
                raise RecursionError(f"MessageBus exceeded {self.MAX_ITERATIONS} iterations")
            message = self.queue.pop(0)
            if isinstance(message, Command):
                self._handle_command(message)
            elif isinstance(message, DomainEvent):
                self._handle_event(message)
            else:
                raise TypeError(f"Unsupported message type: {type(message).__name__}")
            self.queue.extend(self.uow.collect_new_events())
```

The iteration cap exists because a handler that emits an event handled by a handler that emits the original event will otherwise spin forever.

## A failing event handler must not roll back the command

The command succeeded; a downstream notification failing doesn't change that. Isolate each handler so one failure doesn't strand the rest — but log it with the event payload attached. This is deliberately *not* silent: swallowing the exception without a trace is the failure mode this is trying to avoid.

```python
def _handle_event(self, event: DomainEvent) -> None:
    for handler in self.event_handlers.get(type(event), []):
        try:
            handler(event, self.uow)
        except Exception:
            logger.exception("Event handler %s failed for %r", handler.__name__, event)
```

If a handler's work is business-critical rather than incidental, that's a sign it belongs in the command handler inside the transaction, not in an event handler.
