#!/usr/bin/env bash
# PreToolUse guard: refuse `git commit` when the staged diff adds narrative
# comments — changelog talk, refactor references, "previously/now we" — the
# recurring human complaint on MRs. Comments must state a WHY the code can't.
#
# Commit-time is the only gate that runs before a sub-hour self-merge, and
# in-context policy alone has already been proven insufficient. Escape hatch
# for a genuinely needed comment: prefix the command with SKIP_COMMENT_SWEEP=1.
set -uo pipefail

input=$(cat)

command -v jq >/dev/null 2>&1 || exit 0

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""')

[ -n "$cwd" ] && cd "$cwd" 2>/dev/null

printf '%s' "$cmd" | grep -q 'SKIP_COMMENT_SWEEP=1' && exit 0

invocation_re='(^|[;&|(] *)([A-Za-z_][A-Za-z0-9_]*=[^ ]* +)*git +((-C|-c) +[^ ]+ +|-[^ ]+ +)*commit\b'
seg=$(printf '%s' "$cmd" | grep -Eo "${invocation_re}[^;&|]*" | head -1)
[ -n "$seg" ] || exit 0

gdir=$(printf '%s' "$seg" | grep -Eo '\-C +[^ ]+' | head -1 | awk '{print $2}')
git_q() {
  if [ -n "$gdir" ]; then git -C "$gdir" "$@"; else git "$@"; fi
}

diff=$(git_q diff --cached 2>/dev/null) || exit 0
# `commit -a` also sweeps up unstaged tracked changes.
if printf '%s' "$seg" | grep -Eq '\-a\b|--all\b'; then
  diff="$diff
$(git_q diff 2>/dev/null)"
fi
[ -n "$diff" ] || exit 0

# Added comment lines only (#, //, /*, *, --, <!--), then the narrative tells.
noise=$(printf '%s' "$diff" \
  | grep -E '^\+[[:space:]]*(#|//|/\*|\*|--|<!--)' \
  | grep -Eic 'was previously|previously (we|this|the|it)|used to|now (we|it|this) |no longer|refactored (from|to)|moved (from|to)|renamed from|instead of the old|replaces the (old|previous)|as part of (the )?(refactor|migration|cleanup)|per (the )?review|after the refactor|kept for reference|old (implementation|version|code)')

[ "$noise" -gt 0 ] || exit 0

lines=$(printf '%s' "$diff" \
  | grep -E '^\+[[:space:]]*(#|//|/\*|\*|--|<!--)' \
  | grep -Ei 'was previously|previously (we|this|the|it)|used to|now (we|it|this) |no longer|refactored (from|to)|moved (from|to)|renamed from|instead of the old|replaces the (old|previous)|as part of (the )?(refactor|migration|cleanup)|per (the )?review|after the refactor|kept for reference|old (implementation|version|code)' \
  | head -8)

reason="comment-sweep: the staged diff adds ${noise} narrative comment(s):

${lines}

Comments explain a WHY the code cannot carry — never what changed, what used
to be there, or what a reviewer said. The past belongs to git history. Delete
these lines (or reword the rare one that truly states a constraint), restage,
and commit again.

If a flagged comment is genuinely needed as written, re-run prefixed with
SKIP_COMMENT_SWEEP=1 to record that human-signed exception."

jq -n --arg reason "$reason" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
