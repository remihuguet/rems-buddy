# rems-buddy

Rem's buddy — reusable Claude Code skills packaged as a plugin marketplace. Install once, use across all projects.

## Installation

Add to your Claude Code plugins:

```
/plugins add /Users/remihuguet/workspaces/rems-buddy
```

Or add to `.claude/settings.json`:

```json
{
  "plugins": ["/Users/remihuguet/workspaces/rems-buddy"]
}
```

## Available Plugins

### bugfix — TDD Bug Fix (command)

Strict red-green workflow: write a failing test reproducing the bug, implement minimal fix, run full suite, commit.

```
/bugfix users can log in with expired tokens
```

### git-workflows — Conventional Commits (command + skill)

Commands: `/commit`, `/commit-push`

Always-on skill: conventional commit message formatting rules.

### coding-standards — Naming and Comments (skill)

Always-on guidance for domain naming, intent-revealing identifiers, comment strategies, and minimal docstrings.

### python-testing — Testing Conventions (skill)

Three skills providing always-on guidance:
- **pytest-conventions** — Function-style tests, fixtures, parametrize, exception testing
- **testing-philosophy** — Behavior-driven testing, diamond approach, fakes over mocks
- **testing-organization** — Three-tier strategy: unit, integration, e2e

### python-architecture — Backend Architecture Patterns (skill)

Six skills for Python backend architecture:
- **hexagonal-layers** — Five-layer architecture (domain, service, adapters, views, entrypoints)
- **domain-driven-design** — Value objects, entities, aggregates, repositories, events, commands
- **cqrs** — Command/query separation
- **event-driven** — MessageBus, UnitOfWork, handler patterns
- **architecture-pitfalls** — Common anti-patterns to avoid
- **file-organization** — Module organization principles

## Adding New Skills

1. Create a plugin directory with skill subdirectories containing `SKILL.md` files
2. For commands, add a `commands/` subdirectory with `.md` files using YAML frontmatter
3. Update `.claude-plugin/marketplace.json` to register the plugin and its skills
