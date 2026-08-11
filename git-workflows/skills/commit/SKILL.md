---
name: commit
description: Create a single conventional commit from the current changes
argument-hint: "[scope or message hint]"
disable-model-invocation: true
allowed-tools: Bash(git add:*) Bash(git status:*) Bash(git commit:*) Bash(git diff:*) Bash(git log:*) Bash(git branch:*) Bash(git switch:*)
---

## Context

- Branch: !`git branch --show-current`
- Status: !`git status --short`
- Diff: !`git diff HEAD`
- Recent commits: !`git log --oneline -10`

## Task

Create one conventional commit from the changes above. $ARGUMENTS

- Stage specific files — never `git add -A` or `git add .`
- Subject: `<type>(<scope>): <description>` — lowercase, imperative, under 72 chars, from `feat|fix|docs|chore|refactor|test|style|ci`
- On `main`/`master`: `git switch -c rh/<short-kebab-description>` first, naming the branch after the change
- Nothing staged and nothing to stage: say so and stop

Scope: commit only. Don't fix, refactor, or push. Note anything you spot without acting on it.
