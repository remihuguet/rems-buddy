---
name: notion-issue-sync
description: "When working from a Notion issue, keep it updated with analysis, plan, progress, and MR links, and cross-link the MR back to the Notion issue"
---

# Notion Issue Sync

When work originates from a Notion issue (the user shares a `notion.so` link or says they're "working on an issue"), keep the issue as the single source of truth for progress.

## Rules

### Record analysis and plan on the Notion issue before implementing

When you finish analyzing an issue, write a concise analysis + plan into a dedicated, clearly-labeled section on the Notion page (not scattered in chat only). This lets the user and teammates follow the reasoning without reading the diff.

### Keep progress updated as work lands

Update the Notion issue at meaningful milestones (analysis done, plan agreed, implementation done, MR opened). Prefer appending to a structured section over overwriting existing content.

### Cross-link the MR and the Notion issue both ways

- Put the Notion issue link in the MR description.
- Put the MR link(s) in the Notion issue.

```
# Good
MR description: "Implements <notion-issue-url>"
Notion issue: "### Progress — MR: <gitlab-mr-url> (open, CI green)"

# Bad
MR opened with no reference to the issue; Notion issue left stale
```

### Do not overwrite the user's existing issue structure

Add a labeled section (e.g. "Analysis", "Plan", "Progress") rather than replacing the issue body. When unsure where updates should go, ask the user.
