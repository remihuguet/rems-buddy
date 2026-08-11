---
name: branch-safety
description: Branch rules for this user's repos — rh/ naming prefix, and never commit or push on main/master. Use before creating a branch, committing, or pushing.
---

# Branch safety

- Never commit or push on `main` or `master`. Changes reach the default branch through a GitLab MR.
- New branches: `rh/<short-kebab-description>` — e.g. `rh/fix-login-redirect`.
- Already on `main` with uncommitted work? `git switch -c rh/<name>` carries it across.

A `PreToolUse` hook in this plugin denies `git commit` and `git push` on `main`/`master`. If it fires, switch branch — don't look for a way around it.
