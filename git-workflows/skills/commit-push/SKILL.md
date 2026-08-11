---
name: commit-push
description: Commit, push, and open or update a GitLab merge request
argument-hint: "[scope or message hint]"
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash(git add:*) Bash(git status:*) Bash(git commit:*) Bash(git diff:*) Bash(git push:*) Bash(git log:*) Bash(git branch:*) Bash(git switch:*) Bash(glab:*)
---

## Context

- Branch: !`git branch --show-current`
- Status: !`git status --short`
- Diff: !`git diff HEAD`
- Recent commits: !`git log --oneline -10`
- Existing MR: !`glab mr list --source-branch "$(git branch --show-current)" 2>/dev/null || echo "glab unavailable"`

## Task

Commit the changes above, push, and make sure an MR exists. $ARGUMENTS

1. **Branch** — on `main`/`master`, `git switch -c rh/<short-kebab-description>` first.
2. **Commit** — stage specific files (never `git add -A`); subject `<type>(<scope>): <description>`, lowercase, imperative, under 72 chars. Nothing to commit is fine; an MR may still be needed for work already committed.
3. **Push** — `-u` to set upstream on a new branch.
4. **MR** — if one already exists for this branch, the push updated it; report its URL. Otherwise `glab mr create` targeting the default branch, with a hand-written description covering *what* changed and *why*. Ask first if the target branch is ambiguous.

Report the MR URL.

Scope: ship the changes that are already there. Don't fix or refactor along the way.
