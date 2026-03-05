# claude-skills

This is a Claude Code plugin marketplace repository.

## Structure

- `.claude-plugin/marketplace.json` — registers all plugins
- Each plugin is a subdirectory with a `commands/` folder containing slash command definitions
- Command files use YAML frontmatter with `allowed-tools` and `description`

## Conventions

- Follow conventional commits for changes to this repo
- When adding new commands, update `marketplace.json` to include the plugin
- Command frontmatter uses `allowed-tools` for scoped tool permissions
- Commands support `$ARGUMENTS` for user input and `!` backtick syntax for dynamic context injection
