---
name: gitlab-issue-sync
description: Keep a GitLab delivery issue in sync when work originates from one — post analysis and plan as a comment before implementing, update at milestones, link the MR. Use when the user shares a code.libracyber.com issue or work item link, a libracyber/simcore/delivery#N reference, or says they're working an issue.
---

# GitLab issue sync

Issues live in `libracyber/simcore/delivery` on `code.libracyber.com`, as `SimCore Issue` work items. The issue is the source of truth for progress, not the chat log.

Notion holds no task tracking since 2026-10-30. Never write issue progress to Notion. Read Notion only for documentation and for issues closed before that date.

- **`glab issue` cannot see these work items** (REST returns none). Use GraphQL with `GITLAB_HOST=code.libracyber.com`:
  - read: `glab api graphql -f query='{ namespace(fullPath: "libracyber/simcore/delivery") { workItem(iid: "<N>") { id title state webUrl widgets { ... on WorkItemWidgetDescription { description } } } } }'`
  - comment: `glab api graphql -f query='mutation($id: NoteableID!, $body: String!) { createNote(input: { noteableId: $id, body: $body }) { errors } }' -f id=<workItem id> -f body=<markdown>`
- **Before implementing**, post the analysis and plan as a comment. Teammates should follow the reasoning without reading the diff.
- **Never edit the description.** It is the team template (intent, acceptance criteria, start guide, definition of done). If it needs a change, ask.
- **Update at milestones** — plan agreed, implementation done, MR opened — not per commit.
- **Link the MR**: `Related to libracyber/simcore/delivery#N` in the MR description, `Closes` only on the last MR of the slice.
