---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git push:*), Bash(git branch:*), Bash(git log:*), Bash(git checkout:*), Bash(git switch:*), Bash(glab:*), AskUserQuestion
description: Commit, push, and open (or update) a GitLab merge request
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`
- Existing MR for this branch (if any): !`glab mr list --source-branch "$(git branch --show-current)" 2>/dev/null || echo "glab unavailable or no MR"`

## Your task

Based on the above changes, commit, push, and ensure a merge request exists.

### Step 1: Branch safety check

Before committing, verify you are NOT on `main` or `master` branch.

- If on `main` or `master`: create a new branch before committing. Default branch name prefix is `rh/`. Suggest a branch name based on the changes (e.g., `rh/add-auth-flow`) and ask the user to validate before creating it.
- If on any other branch: proceed normally.
- If unsure about what to do: ask the user.

### Step 2: Commit

1. Stage specific files (not `git add -A` or `git add .`)
2. Create a single commit following conventional commits format: `<type>(<scope>): <description>` — lowercase, imperative mood, under 72 characters
3. If there are no changes to commit, skip to Step 4 (an MR may still need creating for already-committed work)

### Step 3: Push

Push to the remote tracking branch (use `-u` to set upstream if needed).

### Step 4: Merge request

Look at the "Existing MR for this branch" context above.

- **If an MR already exists** for the current branch: do not create a new one — the push already updated it. Report the existing MR URL.
- **If no MR exists**: create one with `glab mr create`.
  - Title: use the conventional-commit subject of the work (e.g. `feat(auth): add password reset flow`).
  - Description: a short summary of *what* changed and *why*, derived from the commits and diff. Use `--fill` to seed from commit history when appropriate, but prefer a clear hand-written summary for multi-commit branches.
  - Target the default branch (usually `main`) unless the user says otherwise.
  - Use `glab mr create --fill --yes` or an explicit `--title`/`--description`; if the target/base is ambiguous, ask the user first.
- Do **not** add any AI attribution ("Generated with…", "Co-Authored-By: Claude") to the commit or the MR — this repo's attribution policy forbids it.

Report the MR URL when done.

You have the capability to call multiple tools in a single response. Do not use any other tools or do anything else.
