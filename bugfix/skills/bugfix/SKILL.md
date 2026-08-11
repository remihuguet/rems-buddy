---
name: bugfix
description: TDD bug fix workflow — reproduce with a failing test, apply the minimal fix, commit
argument-hint: "<bug description>"
disable-model-invocation: true
allowed-tools: Read Edit Write Glob Grep Bash(pytest:*) Bash(uv run:*) Bash(poetry run:*) Bash(git add:*) Bash(git status:*) Bash(git diff:*) Bash(git commit:*) Bash(git branch:*) Bash(git switch:*)
---

## Bug

$ARGUMENTS

## Context

- Branch: !`git branch --show-current`
- Status: !`git status --short`

## Workflow

Strict TDD. The order is the point — don't reorder or collapse steps.

**1. Find the root cause.** Explore before writing anything. If you can't identify why the bug happens, say so and ask — a fix aimed at a guess usually moves the bug rather than removing it.

**2. RED.** Write one focused test that reproduces the bug, then run it. It must fail, and fail *for the reason you predicted*. A test that passes straight away means you haven't reproduced the bug yet — go back to step 1 rather than adjusting the test until it goes red.

- Name: `test_{subject}__should_{expected_behavior}`
- Location: the existing `test_*.py` for that module, or a new one beside it
- Arrange / Act / Assert, separated by blank lines

**3. GREEN.** The smallest change that makes the test pass. No refactoring, no tidying adjacent code, no extra defensive branches.

**4. Commit.** `fix(<scope>): <description>`, staging only the files you touched.

Scope: this bug. Anything else you notice goes in your report, not in the diff.
