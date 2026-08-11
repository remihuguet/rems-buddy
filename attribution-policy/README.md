# attribution-policy

Never add `Co-Authored-By: Claude`, `Generated with Claude Code`, or similar AI/tool attribution to commits, MRs, PRs, issues, or docs — unless explicitly asked for.

## Skill

- **no-ai-attribution** — overrides Claude Code's built-in instruction to append attribution to commits and PR/MR bodies

## Hook

`hooks/hooks.json` registers a `PreToolUse` guard on `Bash(git *)` that denies any command whose text carries an attribution trailer or footer, and tells Claude to delete the line rather than reword it past the check.

The hook lives here rather than in `git-workflows` so this plugin enforces its own rule when installed alone. `scripts/guard-attribution.sh` fails open if `jq` is unavailable.
