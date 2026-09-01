#!/usr/bin/env bash
# Run: ./guard-comment-noise.test.sh
H="${1:-$(dirname "$0")/guard-comment-noise.sh}"
H=$(cd "$(dirname "$H")" && pwd)/$(basename "$H")

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
repo="$tmp/repo"
git init -q -b rh/x "$repo"
git -C "$repo" -c user.email=t@t -c user.name=t commit -q --allow-empty -m init

stage() { printf '%s\n' "$2" > "$repo/$1"; git -C "$repo" add "$1"; }
reset_stage() { git -C "$repo" rm -q --cached -r . 2>/dev/null; rm -f "$repo"/*.py; }

check() {
  local desc="$1" cmd="$2" want="$3"
  raw=$(jq -Rn --arg c "$cmd" --arg d "$repo" '{tool_input:{command:$c},cwd:$d}' | "$H")
  if [ -z "$raw" ]; then got=allow; else got=$(printf '%s' "$raw" | jq -r '.hookSpecificOutput.permissionDecision'); fi
  [ "$got" = "$want" ] && echo "  PASS  $desc -> $got" || { echo "  FAIL  $desc -> $got (want $want)"; FAILED=1; }
}
FAILED=0

stage a.py '# this was previously handled by the old parser
x = 1'
check "narrative comment staged"       'git commit -m "feat: x"'                      deny
check "escape hatch honored"           'SKIP_COMMENT_SWEEP=1 git commit -m "feat: x"' allow
check "non-commit command"             'git status'                                    allow

reset_stage
stage b.py '# lock ordering matters here: settle() may re-enter on timeout
x = 1'
check "WHY comment staged"             'git commit -m "feat: x"'                      allow

reset_stage
stage c.py 'x = 1  # plain code, no comment noise'
check "clean staged diff"              'git commit -m "feat: x"'                      allow

exit $FAILED
