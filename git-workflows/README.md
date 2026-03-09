# git-workflows

Conventional commit and push workflows for Claude Code with branch safety.

## Skills

- **conventional-commits** — Always-on commit message formatting rules (Conventional Commits spec)
- **branch-safety** — Always-on branch safety: never commit/push to main/master, auto-create `rh/` prefixed branches

## Commands

- `/commit` — Create a conventional commit from current changes (with branch safety check)
- `/commit-push` — Commit and push to remote tracking branch (with branch safety check)
