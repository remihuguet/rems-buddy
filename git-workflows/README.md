# git-workflows

Conventional commits, GitLab merge requests, and branch safety.

## Workflow skills (`disable-model-invocation` — you trigger these)

- `/commit` — one conventional commit from the current changes
- `/commit-push` — commit, push, open or update a GitLab MR
- `/fix-mr [mr]` — pull failing CI logs, fix root causes, address CodeRabbit / reviewer comments

## Reference skills (Claude loads these when relevant)

- **conventional-commits** — allowed type list, subject format, 72-char limit, `BREAKING CHANGE:` footer
- **branch-safety** — `rh/` prefix, never commit or push on `main`/`master`

## Hook

`hooks/hooks.json` registers a `PreToolUse` guard on `Bash(git *)` that denies `git commit` and `git push` while on `main` or `master`. Read-only git commands are unaffected.

The skill and the hook are both intentional: the skill explains the rule so Claude branches correctly on its own, the hook makes it unskippable when context fills up. `scripts/guard-branch.sh` fails open if `jq` is unavailable rather than blocking every git command.

## Notes

- MR creation uses `glab`. Authenticate once with `glab auth login`.
- Attribution is handled separately by the `attribution-policy` plugin.
