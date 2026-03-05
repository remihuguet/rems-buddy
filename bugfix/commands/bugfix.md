---
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(pytest:*), Bash(poetry run pytest:*), Bash(uv run pytest:*), Bash(ruff:*), Bash(mypy:*), Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*)
description: TDD bug fix workflow
---

## Context

- Current git status: !`git status`
- Current branch: !`git branch --show-current`
- Current diff: !`git diff HEAD`

## Bug description

$ARGUMENTS

## Workflow

Follow this strict TDD workflow to fix the bug:

### 1. Understand

Analyze the bug description. Explore the codebase to locate the relevant code. Identify the root cause before writing any code.

### 2. RED - Write a failing test

Write a test that reproduces the bug. The test MUST fail before the fix.

Rules:
- Naming: `test_{entity}__should_{expected_behavior}`
- File: place in the existing test file or create one with `_test.py` suffix
- Pattern: Arrange-Act-Assert with blank line separating each section
- The test should be minimal and focused on the bug

Run the test and confirm it fails for the right reason.

### 3. GREEN - Implement the minimal fix

Write the minimum code change that makes the failing test pass. Do not refactor yet.

Run the full test suite and confirm all tests pass.

### 4. Quality

Run linter/formatter on changed files only (ruff, mypy if available).

### 5. Commit

Stage the changed files (specific files, not `git add -A`) and commit with:

```
fix(<scope>): <description>
```

Following conventional commits: lowercase, imperative mood, under 72 characters.
