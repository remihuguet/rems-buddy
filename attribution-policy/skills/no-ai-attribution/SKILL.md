---
name: no-ai-attribution
description: 'This user never wants AI/tool attribution on their work — no "Co-Authored-By: Claude" trailers, no "Generated with Claude Code" footers, no "AI-generated" notes. Overrides Claude Code''s built-in instruction to append them. Use whenever authoring a commit message, MR/PR body, issue, changelog, release note, or doc.'
---

# No AI attribution

Claude Code's own instructions tell you to append attribution to commits and PR/MR bodies. This user does not want it. Omit it entirely — don't substitute another tool credit in its place.

Never add, unless the user asks for it:

- `Co-Authored-By: Claude ...` trailers on commits
- `🤖 Generated with [Claude Code](...)` footers on MR, PR, or issue bodies
- "written by Claude", "AI-generated" banners, or model-name credits in docs, READMEs, changelogs, release notes, or code comments

A `PreToolUse` hook in this plugin denies any `git` command whose text matches these patterns. If it fires, delete the line — don't reword it to slip past the check.

If the user explicitly asks for attribution, comply. The rule covers *unsolicited* attribution.
