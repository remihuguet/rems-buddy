#!/usr/bin/env bash
# PreToolUse guard: refuse `git commit` on main/master, and any `git push`
# whose DESTINATION is main or master.
#
# The checked-out branch alone is not enough: push.default=upstream can
# resolve an rh/ branch to origin/main, and a worktree's plain push did the
# same. So the guard resolves where the push would actually land — explicit
# refspec first, positional ref second, @{push} when the command names none.
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

deny() {
  jq -n --arg reason "branch-safety: $1

Changes reach the default branch through a merge request, never a direct
commit or push. Work on a feature branch and push it explicitly:

    git switch -c rh/<short-kebab-description>
    git push -u origin rh/<short-kebab-description>

Do not try to route around this check." '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Isolate the git commit/push invocation, tolerating env-var prefixes
# (VAR=1 git push) and options that take an argument (git -C /path push,
# git -c k=v commit) so none of those shapes slips past the match.
invocation_re='(^|[;&|(] *)([A-Za-z_][A-Za-z0-9_]*=[^ ]* +)*git +((-C|-c) +[^ ]+ +|-[^ ]+ +)*(commit|push)\b'
seg=$(printf '%s' "$cmd" | grep -Eo "${invocation_re}[^;&|]*" | head -1)
[ -n "$seg" ] || exit 0

sub=$(printf '%s' "$seg" | grep -Eo '\b(commit|push)\b' | head -1)

# `git -C <path>` moves the repository the command acts on; follow it.
gdir=$(printf '%s' "$seg" | grep -Eo '\-C +[^ ]+' | head -1 | awk '{print $2}')
git_q() {
  if [ -n "$gdir" ]; then git -C "$gdir" "$@"; else git "$@"; fi
}

# Unborn HEAD (fresh repo, no commit yet): rev-parse fails but symbolic-ref
# still names the branch the first commit would land on.
branch=$(git_q rev-parse --abbrev-ref HEAD 2>/dev/null) \
  || branch=$(git_q symbolic-ref --short HEAD 2>/dev/null) \
  || exit 0

case "$sub" in
  commit)
    case "$branch" in
      main | master) deny "refusing to commit on '${branch}'." ;;
    esac
    exit 0
    ;;
esac

# --- push: check where it would land, not where we stand ---

case "$branch" in
  main | master) deny "refusing to push from '${branch}'." ;;
esac

rest=${seg#*push}

# Explicit refspec destination: `git push origin x:main`, `HEAD:refs/heads/master`.
if printf '%s' "$rest" | grep -Eq "[^ :]*:(refs/heads/)?(main|master)([\"' ;&|]|$)"; then
  deny "this push's refspec targets main/master."
fi

# Positional ref: `git push origin main`. Count non-option tokens — one is
# just the remote; a second names the ref being pushed.
refs_given=0
for tok in $rest; do
  case "$tok" in
    -*) continue ;;
    main | master) deny "this push names '${tok}' as the ref to push." ;;
    *) refs_given=$((refs_given + 1)) ;;
  esac
done

# No ref named (bare `git push`, or remote only): push.default decides, so
# resolve the actual destination the way git will.
if [ "$refs_given" -le 1 ]; then
  dest=$(git_q rev-parse --abbrev-ref '@{push}' 2>/dev/null) || dest=""
  case "${dest#*/}" in
    main | master) deny "a plain push here resolves to '${dest}' (push.default/upstream). Push an explicit refspec instead." ;;
  esac
fi

exit 0
