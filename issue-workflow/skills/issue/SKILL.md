---
name: issue
description: Work a Notion issue end to end — analyze, plan, sync the plan to Notion, implement, open a GitLab MR, close the loop
argument-hint: "<notion url, page id, or search term>"
disable-model-invocation: true
allowed-tools: Read Edit Write Glob Grep Bash(git:*) Bash(glab:*) mcp__claude_ai_Notion__notion-fetch mcp__claude_ai_Notion__notion-search mcp__claude_ai_Notion__notion-update-page mcp__claude_ai_Notion__notion-create-comment
---

## Issue reference

$ARGUMENTS

## Context

- Branch: !`git branch --show-current`
- Status: !`git status --short`

## Workflow

This is the standard loop for this user's issue-driven work. Follow it unless they say otherwise.

**1. Read the issue.** `notion-fetch` the page (a search term means `notion-search` first, then confirm the match before proceeding). Follow linked spec pages. Extract the problem, the acceptance criteria, and the constraints.

**2. Analyze.** Locate the relevant code and establish what's actually happening and why. If the acceptance criteria are genuinely ambiguous — as opposed to merely unstated — surface the specific question before writing code.

**3. Plan.** Concrete steps, the files and layers involved. Bugs follow the TDD loop in the `bugfix` skill.

**4. Sync to Notion before implementing.** Write the analysis and plan into a clearly-labeled section on the issue via `notion-update-page`. Add a section; don't overwrite the user's existing structure.

**5. Implement.** On a `rh/` feature branch, following the repo's testing and architecture conventions. Update the Notion issue as meaningful milestones land, not per commit.

**6. Open the MR.** Conventional commits, push, `glab mr create`. Put the Notion issue URL in the MR description.

**7. Close the loop.** Add the MR link and final status to the Notion issue.

Report the analysis summary, the MR URL, and which Notion sections you touched.
