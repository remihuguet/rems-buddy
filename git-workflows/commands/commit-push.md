---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git push:*), Bash(git branch:*), Bash(git log:*), Bash(git checkout:*), Bash(git switch:*), AskUserQuestion
description: Commit and push to remote
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes:

### Step 1: Branch safety check

Before committing, verify you are NOT on `main` or `master` branch.

- If on `main` or `master`: create a new branch before committing. Default branch name prefix is `rh/`. Suggest a branch name based on the changes (e.g., `rh/add-auth-flow`) and ask the user to validate before creating it.
- If on any other branch: proceed normally.
- If unsure about what to do: ask the user.

### Step 2: Commit and push

1. Stage specific files (not `git add -A` or `git add .`)
2. Create a single commit following conventional commits format: `<type>(<scope>): <description>` — lowercase, imperative mood, under 72 characters
3. Push to the remote tracking branch (use `-u` to set upstream if needed)

You have the capability to call multiple tools in a single response. Do not use any other tools or do anything else.
