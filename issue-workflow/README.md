# issue-workflow

The Notion-issue-driven development loop.

## Skills

- `/issue <notion-url|page-id|search-term>` — analyze → plan → sync to Notion → implement → open MR → close the loop. `disable-model-invocation: true`.
- **notion-issue-sync** — loaded automatically when work originates from a Notion issue: record analysis and plan before implementing, update at milestones, cross-link the MR both ways

## Requirements

- Notion MCP connector enabled (`notion-fetch`, `notion-search`, `notion-update-page`)
- `glab` for MR creation, paired with the `git-workflows` plugin
