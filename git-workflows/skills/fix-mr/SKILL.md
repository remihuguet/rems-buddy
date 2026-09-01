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

Where a comment asserts something about intended behaviour that the code and tests don't settle, ask rather than guessing — reviewers are sometimes wrong, and silently complying can bake in a bug. Where a whole comment's validity is the question rather than its wording, run `/triage-finding` on it first and act on the verdict.

### Reply and resolve

Reply on every thread you acted on, then resolve it — a fix nobody can trace to a thread leaves the thread open and the loop manual. Verdict first, evidence attached:

- `Fixed in <sha>` — one line on the mechanism
- `Declined: <the mechanism that makes the finding wrong>` — runnable evidence beats prose
- `Skipped: <reason>` — out of scope or tracked elsewhere; name where

Post the reply into the thread and resolve it via `glab api` (`projects/:id/merge_requests/<iid>/discussions/<did>/notes` then `PUT .../discussions/<did>?resolved=true`) — a top-level `glab mr note` leaves the thread open.

### Loop until mergeable

Commit with conventional messages, splitting CI fixes from review fixes where that aids review. Push, then re-check instead of stopping at "pushed":

- unresolved threads: `glab api "projects/:id/merge_requests/<iid>/discussions" --paginate | jq '[.[] | select(.notes[0].resolvable and (.notes[0].resolved | not))] | length'`
- pipeline, tri-state — never trust a silent exit: `glab ci get --output json | jq -r '.status // "none"'`. `running`: wait and re-check. `failed`: back to Failing CI. `none`: say so explicitly — no pipeline is not green.

A push can trigger a fresh bot round; poll once more after the pipeline goes green. Done means 0 unresolved threads and a green pipeline — report the MR as mergeable.

### Finish

Report: which jobs were red and why, each thread's verdict, and which comments you deliberately didn't act on with your reasoning. Name anything the change leaves dead — an unused wrapper, flag, column, template or setting — as a follow-up, not a fix in this MR.
