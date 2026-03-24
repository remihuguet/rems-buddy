---
name: event-driven
description: "Event-driven architecture with MessageBus, UnitOfWork, command/event handlers"
---

# Event-Driven Architecture

Patterns for implementing event-driven architecture using the MessageBus pattern (Cosmic Python). Covers message routing, handler signatures, event collection from aggregates, transaction management, and error handling.

## Rules

### Implement MessageBus in the service layer to route Commands and DomainEvents

Process messages in a FIFO queue, collecting new events from aggregates after each handler execution.

```python
# Good
class MessageBus:
    def __init__(
        self,
        uow: UnitOfWork,
        command_handlers: dict[type[Command], CommandHandler],
        event_handlers: dict[type[DomainEvent], list[EventHandler]],
    ) -> None:
        self.uow = uow
        self.command_handlers = command_handlers
        self.event_handlers = event_handlers
        self.queue: list[Message] = []

    def handle(self, message: Message) -> None:
        self.queue.append(message)
        while self.queue:
            message = self.queue.pop(0)
            if isinstance(message, Command):
                self._handle_command(message)
            elif isinstance(message, DomainEvent):
                self._handle_event(message)
            self.queue.extend(self.uow.collect_new_events())

# Bad -- MessageBus in domain layer
class MessageBus:
    def __init__(self, repository: CompanyRepository):
        self.repository = repository  # Domain importing adapters
```

### Define handler signatures as Callable[[Message, UnitOfWork], None]

Handlers modify state through UnitOfWork and emit events by adding them to aggregate event lists, never returning events directly.

```python
# Good
def create_company(cmd: CreateCompany, uow: UnitOfWork) -> None:
    with uow:
        company = Company(id=CompanyId.generate(), name=cmd.name)
        company.events.append(CompanyCreated(company.id))
        uow.companies.add(company)
        uow.commit()

# Bad -- handler returns events
def create_company(cmd: CreateCompany) -> list[DomainEvent]:
    company = Company(id=CompanyId.generate(), name=cmd.name)
    return [CompanyCreated(company.id)]
```

### Collect domain events from aggregates after each handler execution

Use `UnitOfWork.collect_new_events()` which iterates tracked aggregates and yields their events, clearing after collection.

```python
# Good
class UnitOfWork:
    def collect_new_events(self) -> Generator[DomainEvent, None, None]:
        for aggregate in self.companies.seen:
            while aggregate.events:
                yield aggregate.events.pop(0)

# Bad -- returns list without clearing
def collect_new_events(self) -> list[DomainEvent]:
    events = []
    for aggregate in self.companies.seen:
        events.extend(aggregate.events)  # Events not cleared
    return events
```

### Register command handlers as one-to-one, event handlers as one-to-many

```python
# Good
COMMAND_HANDLERS: dict[type[Command], CommandHandler] = {
    CreateCompany: create_company,
    ActivateCompany: activate_company,
}

EVENT_HANDLERS: dict[type[DomainEvent], list[EventHandler]] = {
    CompanyCreated: [notify_admin, send_welcome_email],
    CompanyActivated: [update_search_index],
}

# Bad -- multiple handlers for same command
COMMAND_HANDLERS = {
    CreateCompany: [create_company, validate_company],  # Should be one-to-one
}
```

### Use UnitOfWork context managers for transaction boundaries

Handlers run within `with uow:` blocks and explicitly call `commit()`.

```python
# Good
def activate_company(cmd: ActivateCompany, uow: UnitOfWork) -> None:
    with uow:
        company = uow.companies.get(cmd.company_id)
        if company is None:
            raise CompanyNotFound(cmd.company_id)
        company.activate()
        uow.commit()

# Bad -- no context manager
def activate_company(cmd: ActivateCompany, uow: UnitOfWork) -> None:
    company = uow.companies.get(cmd.company_id)
    company.activate()
    uow.commit()  # No rollback on exception
```

### Handle event processing errors gracefully

Log exceptions and continue processing remaining events rather than failing the entire operation.

```python
# Good
def _handle_event(self, event: DomainEvent) -> None:
    handlers = self.event_handlers.get(type(event), [])
    for handler in handlers:
        try:
            handler(event, self.uow)
        except Exception:
            logger.exception("Error handling event %s", event)
            continue

# Bad -- fails entire operation on first error
def _handle_event(self, event: DomainEvent) -> None:
    for handler in self.event_handlers.get(type(event), []):
        handler(event, self.uow)  # Exception stops all processing
```

### Raise TypeError for unsupported message types to prevent silent data loss

```python
# Good
else:
    raise TypeError(f"Unsupported message type: {type(message).__name__}")

# Bad -- silently ignore unknown types
```

### Protect against infinite event loops with a configurable iteration limit

```python
# Good
MAX_ITERATIONS = 100

def handle(self, message: Message) -> None:
    queue = [message]
    iterations = 0
    while queue:
        iterations += 1
        if iterations > MAX_ITERATIONS:
            raise RecursionError(f"MessageBus exceeded {MAX_ITERATIONS} iterations")
        message = queue.pop(0)
        # ... handle message

# Bad -- no iteration limit
while queue:
    message = queue.pop(0)
    # Risk of infinite loop
```

### Use UnitOfWork with explicit-commit semantics

`__exit__` unconditionally calls `rollback()` as a safety net. Handlers must explicitly call `commit()`.

```python
# Good
class UnitOfWork:
    def __exit__(self, *args) -> None:
        self.rollback()  # Always rollback as safety net

# Bad -- auto-commit on success
class UnitOfWork:
    def __exit__(self, exc_type, *args) -> None:
        if exc_type is None:
            self.commit()
```
