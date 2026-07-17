# git-workflows

Conventional commit, push, and GitLab merge request workflows for Claude Code with branch safety.

## Skills

- **conventional-commits** — Always-on commit message formatting rules (Conventional Commits spec)
- **branch-safety** — Always-on branch safety: never commit/push to main/master, auto-create `rh/` prefixed branches, merge to the default branch via MR

## Commands

- `/commit` — Create a conventional commit from current changes (with branch safety check)
- `/commit-push` — Commit, push, and open or update a GitLab merge request (with branch safety check)
- `/fix-mr` — Fix a GitLab MR: pull failing CI job logs, reproduce and fix locally, and address CodeRabbit / reviewer comments

## Notes

- MR creation uses the GitLab CLI (`glab`). Authenticate once with `glab auth login`.
- MR titles/descriptions never include AI attribution (see the `attribution-policy` plugin).
