# python-architecture

Hexagonal architecture, DDD, and messaging patterns for Python backends. Slash-only: invoke a skill by name. The work repos already inline these rules into their own `AGENTS.md`, so Claude does not need to fetch them there.

## Skills

- **layers-and-ddd** — five-layer architecture (domain, service, adapters, views, entrypoints), dependency direction, ports and adapters, value objects, entities, aggregates, repositories, commands and events
- **messaging-and-cqrs** — MessageBus, UnitOfWork as a `runtime_checkable` Protocol with explicit commit, event collection from aggregates, command/query separation
- **file-organization** — group first and split on evidence, no `utils`/`helpers`/`common`, `__init__.py` as the public API

Previously six skills; `hexagonal-layers`, `domain-driven-design`, and `architecture-pitfalls` were merged into `layers-and-ddd`, and `cqrs` and `event-driven` into `messaging-and-cqrs`. The old split repeated the same rules — dependency direction, ports in the domain, the `collect_new_events` implementation — across three files each, which made contradictions possible and cost context every time two of them loaded together.
