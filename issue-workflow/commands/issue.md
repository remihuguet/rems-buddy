---
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*), Bash(git push:*), Bash(git branch:*), Bash(git log:*), Bash(git checkout:*), Bash(git switch:*), Bash(glab:*), mcp__claude_ai_Notion__notion-fetch, mcp__claude_ai_Notion__notion-search, mcp__claude_ai_Notion__notion-update-page, mcp__claude_ai_Notion__notion-create-comment, AskUserQuestion
description: Work a Notion issue end to end — analyze, plan, implement, open MR, sync back to Notion
---

## Issue reference

$ARGUMENTS

(A Notion issue URL, a Notion page id, or a search term to locate the issue.)

## Context

- Current branch: !`git branch --show-current`
- Current git status: !`git status`

## Your task

Take the Notion issue from spec to open MR, keeping the Notion page updated throughout. This is the standard loop for this user — follow it unless they say otherwise.

### 1. Read the issue

- Fetch the Notion page for the reference in `$ARGUMENTS` (use `notion-fetch`; if it's a search term, `notion-search` first, then confirm the match).
- Read any linked spec pages / sub-pages it references.
- Extract: the problem, acceptance criteria, and any constraints. If the issue is ambiguous or under-specified, ask the user before writing code.

### 2. Analyze

- Explore the codebase to locate the relevant area and identify the root cause / the shape of the change.
- Produce a concise **analysis**: what's happening, why, and the options.

### 3. Plan

- Produce a short **plan**: the concrete steps you'll take. For a bug, follow the TDD loop (see the `bugfix` command); for a feature, note the layers/files touched.

### 4. Sync analysis + plan to Notion (before implementing)

- Update the Notion issue with a dedicated section containing the analysis and the plan (use `notion-update-page`, or `notion-create-comment` if the user prefers comments). Keep it structured and skimmable.

### 5. Implement

- Ensure you're on a feature branch (`rh/` prefix; never work on `main`). Implement the change following the repo's testing and architecture conventions.
- Update the Notion issue's progress as meaningful milestones land.

### 6. Open the MR

- Commit (conventional commits), push, and open a GitLab MR via `glab mr create`.
- Put a link to the Notion issue in the MR description.
- No AI attribution in commits or the MR (attribution policy).

### 7. Close the loop in Notion

- Update the Notion issue with the **MR link(s)** and the final progress/status.
- Report back to the user: the analysis summary, the MR URL, and the Notion sections you updated.

Prefer keeping the user's existing Notion issue structure; add a clearly-labeled section rather than overwriting existing content. When any step is ambiguous, ask rather than assume.
