---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*)
description: Create a conventional commit
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single git commit following conventional commits format.

Rules:
- Analyze changes and determine the appropriate type: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `ci`
- Determine scope from the area of code changed
- Format: `<type>(<scope>): <description>` — lowercase, imperative mood, under 72 characters
- Stage specific files (not `git add -A` or `git add .`)
- If there are no changes to commit, do nothing

You have the capability to call multiple tools in a single response. Stage and create the commit using a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.
