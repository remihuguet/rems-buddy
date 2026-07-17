# issue-workflow

Codifies the Notion-issue-driven development loop: read the spec from Notion, analyze, plan, implement, open a GitLab MR, and sync analysis/plan/progress/MR-links back to the Notion issue.

## Commands

- `/issue <notion-url|page-id|search-term>` — Work a Notion issue end to end (analyze → plan → sync to Notion → implement → open MR → close the loop in Notion).

## Skills

- **notion-issue-sync** — Always-on: when working from a Notion issue, keep it updated with analysis, plan, progress, and MR links, and cross-link the MR back to the issue.

## Requirements

- The Notion MCP connector must be enabled (the command uses `notion-fetch`, `notion-search`, `notion-update-page`).
- GitLab CLI (`glab`) for MR creation, paired with the `git-workflows` plugin.
