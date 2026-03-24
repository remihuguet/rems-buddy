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

### prompt-optimization — Intent Clarity (skill)

Always-on prompt interpretation: resolve ambiguity from context, decompose vague requests, minimize unnecessary questions.

## Plugin Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (name, description, version, author)
├── commands/                 # On-demand slash commands
│   └── my-command.md
├── skills/                   # Always-on behavioral guidance
│   └── my-skill/
│       └── SKILL.md
└── README.md
```

## Adding New Plugins

1. Create a plugin directory following the structure above
2. Add `.claude-plugin/plugin.json` with name, description, version, and author
3. Place skills under `skills/<skill-name>/SKILL.md`
4. Place commands under `commands/<command-name>.md` with YAML frontmatter
5. Register the plugin in `.claude-plugin/marketplace.json`
6. Skill paths in `marketplace.json` are relative to the plugin source (e.g., `./skills/my-skill`)
