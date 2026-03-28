# rems-buddy

This is a Claude Code plugin marketplace repository.

## Structure

- `.claude-plugin/marketplace.json` — registers all plugins
- Each plugin is a subdirectory containing:
  - `.claude-plugin/plugin.json` — plugin manifest (name, description, version, author)
  - `commands/` folder with slash command definitions (on-demand workflows)
  - `skills/` folder with skill subdirectories, each containing a `SKILL.md` file (always-on behavioral guidance)
  - `README.md` describing the plugin

## Plugins

| Plugin | Type | Description |
|---|---|---|
| `bugfix` | Command | TDD bug fix workflow: reproduce, fix, verify, commit |
| `git-workflows` | Command + Skill | Conventional commit workflows + always-on commit conventions |
| `coding-standards` | Skill | Naming, comments, and docstring conventions |
| `python-testing` | Skill | Pytest conventions, testing philosophy, test organization |
| `python-architecture` | Skill | Hexagonal layers, DDD, CQRS, event-driven, anti-patterns |
| `prompt-optimization` | Skill | Always-on prompt interpretation and intent clarity |
| `glab-review` | Command | Load and triage unresolved GitLab MR review comments |

## Conventions

- Follow conventional commits for changes to this repo
- When adding new commands or skills, update `marketplace.json` to include the plugin
- Command frontmatter uses `allowed-tools` for scoped tool permissions
- Commands support `$ARGUMENTS` for user input and `!` backtick syntax for dynamic context injection
- SKILL.md files use YAML frontmatter with `name` and `description` fields
- Skills must be placed under `skills/<skill-name>/SKILL.md` (not directly at plugin root)
- Skill paths in `marketplace.json` are relative to the plugin source directory (e.g., `./skills/my-skill`)
- Skills provide always-on guidance; commands provide on-demand workflows
