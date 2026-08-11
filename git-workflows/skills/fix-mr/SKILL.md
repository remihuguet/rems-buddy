---
name: fix-mr
description: Bring a GitLab MR green — fix failing CI jobs and address CodeRabbit or human review comments
argument-hint: "[MR url, MR number, or blank for the current branch]"
disable-model-invocation: true
allowed-tools: Read Edit Write Glob Grep Bash(git:*) Bash(glab:*) Bash(pytest:*) Bash(uv run:*) Bash(poetry run:*) Bash(ruff:*) Bash(mypy:*)
---

## MR reference

$ARGUMENTS

## Context

- Branch: !`git branch --show-current`
- MR for this branch: !`glab mr list --source-branch "$(git branch --show-current)" 2>/dev/null || echo "none"`

## Task

Resolve `$ARGUMENTS` to a concrete MR — blank means the MR for the current branch. Check out its source branch, then:

### Failing CI

`glab ci status` for the job list, `glab ci trace <job-id>` for a failing job's log. Reproduce locally where you can and fix the root cause, not the symptom — a passing job that passes for the wrong reason is worse than a red one. If the pipeline is red only because the branch is stale, rebase on `origin/main` and re-push.

### Review comments

`glab mr view <mr> --comments`. For each actionable comment, either apply the fix or note why you disagree. Group trivial nits into one commit. Skip resolved and purely informational threads.

Where a comment asserts something about intended behaviour that the code and tests don't settle, ask rather than guessing — reviewers are sometimes wrong, and silently complying can bake in a bug.

### Finish

Commit with conventional messages, splitting CI fixes from review fixes where that aids review. Push to update the MR.

Report: which jobs were red and why, which comments you addressed, and which you deliberately didn't act on with your reasoning.
