# claude-skills

Reusable Claude Code skills packaged as a plugin marketplace. Install once, use across all projects.

## Installation

Add to your Claude Code plugins:

```
/plugins add /Users/remihuguet/workspaces/claude-skills
```

Or add to `.claude/settings.json`:

```json
{
  "plugins": ["/Users/remihuguet/workspaces/claude-skills"]
}
```

## Available Commands

### `/bugfix` — TDD Bug Fix

Strict red-green workflow: write a failing test reproducing the bug, implement minimal fix, run full suite, commit.

```
/bugfix users can log in with expired tokens
```

### `/commit` — Conventional Commit

Analyzes staged/unstaged changes and creates a properly formatted conventional commit.

### `/commit-push` — Commit and Push

Same as `/commit` but also pushes to the remote tracking branch.

## Adding New Skills

1. Create a new directory with a `commands/` subdirectory
2. Add command `.md` files with YAML frontmatter (`allowed-tools`, `description`)
3. Update `.claude-plugin/marketplace.json` to register the plugin
