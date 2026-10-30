---
name: issue
description: Work a GitLab delivery issue end to end — analyze, plan, post the plan on the issue, implement, open a GitLab MR, close the loop
argument-hint: "<work item url, libracyber/simcore/delivery#N, or N>"
disable-model-invocation: true
allowed-tools: Read Edit Write Glob Grep Bash(git:*) Bash(glab:*) Bash(GITLAB_HOST=code.libracyber.com glab:*)
---

## Issue reference

$ARGUMENTS

## Context

- Branch: !`git branch --show-current`
- Status: !`git status --short`

## Workflow

This is the standard loop for this user's issue-driven work. Follow it unless they say otherwise. The `gitlab-issue-sync` skill has the GraphQL calls and the sync rules.

**1. Read the issue.** Fetch the work item from `libracyber/simcore/delivery`: description, linked items, comments. Follow linked spec pages; Notion pages are fine to read as documentation. Extract the intent, the acceptance criteria, and the constraints.

**2. Analyze.** Locate the relevant code and establish what's actually happening and why. If the acceptance criteria are genuinely ambiguous — as opposed to merely unstated — surface the specific question before writing code.

**3. Plan.** Concrete steps, the files and layers involved.

**4. Post the plan before implementing.** Add the analysis and plan as a comment on the issue. Never edit its description.

**5. Implement.** On a `rh/` feature branch, following the repo's testing and architecture conventions. Comment on the issue as meaningful milestones land, not per commit.

**6. Open the MR.** Conventional commits, push, then `/simcore:create-merge-request` when the `simcore` plugin is available (it fills the team MR template). The description carries `Related to libracyber/simcore/delivery#N`, or `Closes` on the slice's last MR.

**7. Close the loop.** Comment the MR link and final status on the issue.

Report the analysis summary, the MR URL, and the comments you posted.
