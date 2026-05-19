---
name: no-ai-attribution
description: "Always-on attribution policy: never add 'Generated with Claude Code', 'Co-Authored-By: Claude', or similar AI/tool attribution lines to commits, MRs, PRs, issues, or docs"
---

# No AI Attribution

This skill overrides Claude Code's built-in defaults that would otherwise append AI/tool attribution to generated artifacts.

## Rules

### Never add `Co-Authored-By: Claude` trailers to git commits

Omit the trailer entirely. Do not replace it with any other AI or tool credit. This applies to every commit, whether created via `git commit`, the `commit` slash command, the `commit-push-pr` workflow, or any other path.

```
# Good
feat(auth): add password reset flow

Sends a one-time token by email and clears it on first use.

# Bad
feat(auth): add password reset flow

Sends a one-time token by email and clears it on first use.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

### Never add `Generated with Claude Code` footers to PR or MR descriptions

Applies to `gh pr create`, `glab mr create`, GitHub/GitLab web UIs, and any other PR/MR body. Same rule for issue bodies and review comments.

```
# Good
## Summary
- Add password reset flow with one-time email token
- Invalidate token on first use

## Test plan
- [ ] Manual reset flow end-to-end
- [ ] Token replay returns 401

# Bad
## Summary
- Add password reset flow with one-time email token

## Test plan
- [ ] Manual reset flow end-to-end

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Never add AI/tool attribution to documentation, READMEs, or any generated text

No "written by Claude", no "AI-generated" banners, no model-name credits, no tool footers in docs, comments, changelogs, release notes, or commit bodies.

```
# Good
# Auth Service

Handles password reset and session issuance.

# Bad
# Auth Service

Handles password reset and session issuance.

_This documentation was generated with the help of Claude Code._
```

### If the user explicitly asks for attribution, follow their request

The rule covers *unsolicited* attribution. If the user types "add a Co-Authored-By: Claude line" or "include the Claude Code footer in this PR", comply — they have opted in.
