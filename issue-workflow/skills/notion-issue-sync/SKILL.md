---
name: notion-issue-sync
description: Keep a Notion issue in sync when work originates from one — record analysis and plan before implementing, update at milestones, and cross-link the MR both ways. Use when the user shares a notion.so link or says they're working an issue.
---

# Notion issue sync

The Notion issue is the source of truth for progress, not the chat log.

- **Before implementing**, write the analysis and plan into a labeled section on the issue page. Teammates should be able to follow the reasoning without reading the diff.
- **Add sections, never overwrite** the user's existing issue structure. Where the update belongs isn't obvious, ask.
- **Update at milestones** — plan agreed, implementation done, MR opened — not per commit.
- **Cross-link both ways**: the Notion URL in the MR description, the MR URL in the issue.
