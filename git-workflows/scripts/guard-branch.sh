#!/usr/bin/env bash
# PreToolUse guard: refuse `git commit` / `git push` while on main or master.
#
# Advisory instructions can be forgotten once context fills up; this cannot.
# Exits 0 with no output when the rule does not apply, which defers to the
# normal permission flow.
set -uo pipefail

input=$(cat)

# No jq means no reliable way to read the payload. Fail open rather than
# blocking every git command in the session.
command -v jq >/dev/null 2>&1 || exit 0

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""')

[ -n "$cwd" ] && cd "$cwd" 2>/dev/null

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
case "$branch" in
  main | master) ;;
  *) exit 0 ;;
esac

# Match `git commit` / `git push` at the start of the command or after a
# separator, so `git log --oneline` and `git status` pass through untouched.
printf '%s' "$cmd" | grep -Eq '(^|[;&|(] *)git +(-[^ ]+ +)*(commit|push)\b' || exit 0

reason="branch-safety: refusing this command on '${branch}'.

Changes reach the default branch through a merge request, never a direct
commit or push. Create a feature branch first:

    git switch -c rh/<short-kebab-description>

Then re-run the command. Do not try to route around this check."

jq -n --arg reason "$reason" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
