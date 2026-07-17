---
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git push:*), Bash(git branch:*), Bash(git log:*), Bash(git checkout:*), Bash(git switch:*), Bash(git fetch:*), Bash(git rebase:*), Bash(glab:*), Bash(pytest:*), Bash(poetry run pytest:*), Bash(uv run pytest:*), Bash(ruff:*), Bash(mypy:*), AskUserQuestion
description: Fix a GitLab MR — failing CI jobs and CodeRabbit review comments
---

## MR reference

$ARGUMENTS

(An MR URL, an MR number, or empty to use the MR for the current branch.)

## Context

- Current branch: !`git branch --show-current`
- MR for current branch: !`glab mr list --source-branch "$(git branch --show-current)" 2>/dev/null || echo "none"`

## Your task

Bring the merge request to a green, review-clean state. Work in this order.

### 1. Identify the MR

Resolve `$ARGUMENTS` to a concrete MR. If empty, use the MR for the current branch (see context). If ambiguous, ask the user. Make sure you are on the MR's source branch locally.

### 2. Fix failing CI

1. List the pipeline / job status: `glab ci status` or `glab mr view <mr> --comments` to see checks.
2. For each failing job, pull its log: `glab ci trace <job-id>` (or view the job in the pipeline).
3. Reproduce the failure locally where possible:
   - Test failures → run the relevant tests (`pytest`/`uv run pytest`) and fix the root cause, not the symptom.
   - Lint/type failures → run `ruff` / `mypy` on the changed files and fix.
4. If the pipeline is failing only because the branch is behind, `git fetch` and `git rebase origin/main`, resolve conflicts, and re-push.

### 3. Address CodeRabbit (and other reviewer) comments

1. Read the review threads: `glab mr view <mr> --comments`.
2. For each actionable comment (CodeRabbit or human): either apply the fix in code, or, if you disagree, note a short rationale to reply with. Group trivial nits.
3. Skip comments that are already resolved or purely informational.

### 4. Commit, push, and summarize

1. Commit fixes with conventional-commit messages (lowercase, imperative, `<type>(<scope>): <description>`). Prefer separate commits for CI fixes vs. review fixes when it aids clarity.
2. Push to update the MR (this re-triggers CI).
3. Report: what CI jobs were failing and how you fixed them, which review comments you addressed, and any comments you intentionally did not act on (with reasons).

Do **not** add AI attribution to commits or MR comments — this repo's attribution policy forbids it. When unsure whether a reviewer comment reflects a real requirement, ask the user rather than guessing.
