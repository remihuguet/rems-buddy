# claude-skills

This is a Claude Code plugin marketplace repository.

## Structure

- `.claude-plugin/marketplace.json` — registers all plugins
- Each plugin is a subdirectory containing:
  - `commands/` folder with slash command definitions (on-demand workflows)
  - Skill subdirectories with `SKILL.md` files (always-on behavioral guidance)
  - `README.md` describing the plugin

## Plugins

| Plugin | Type | Description |
|---|---|---|
| `bugfix` | Command | TDD bug fix workflow: reproduce, fix, verify, commit |
| `git-workflows` | Command + Skill | Conventional commit workflows + always-on commit conventions |
| `coding-standards` | Skill | Naming, comments, and docstring conventions |
| `python-testing` | Skill | Pytest conventions, testing philosophy, test organization |
| `python-architecture` | Skill | Hexagonal layers, DDD, CQRS, event-driven, anti-patterns |

## Conventions

- Follow conventional commits for changes to this repo
- When adding new commands or skills, update `marketplace.json` to include the plugin
- Command frontmatter uses `allowed-tools` for scoped tool permissions
- Commands support `$ARGUMENTS` for user input and `!` backtick syntax for dynamic context injection
- SKILL.md files use YAML frontmatter with `name` and `description` fields
- Skills provide always-on guidance; commands provide on-demand workflows
