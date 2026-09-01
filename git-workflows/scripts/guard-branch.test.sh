#!/usr/bin/env bash
# Run: ./guard-branch.test.sh
#
# Exercises the guard against the bypass shapes that actually occurred:
# push.default=upstream resolving an rh/ branch to main, `git -C` from
# elsewhere, env-var prefixes, explicit refspecs, and an unborn HEAD.
H="${1:-$(dirname "$0")/guard-branch.sh}"
H=$(cd "$(dirname "$H")" && pwd)/$(basename "$H")

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

origin="$tmp/origin.git"
git init -q --bare "$origin"
repo="$tmp/repo"
git init -q -b main "$repo"
git -C "$repo" -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
git -C "$repo" remote add origin "$origin"
git -C "$repo" push -q origin main
git -C "$repo" switch -qc rh/x
git -C "$repo" push -qu origin rh/x

# The upstream trap: rh/x tracks origin/main with push.default=upstream,
# so a plain `git push` would land on main.
trap_repo="$tmp/trap"
git clone -q "$origin" "$trap_repo"
git -C "$trap_repo" switch -qc rh/y
git -C "$trap_repo" branch -q --set-upstream-to=origin/main rh/y
git -C "$trap_repo" config push.default upstream

unborn="$tmp/unborn"
git init -q -b main "$unborn"

check() {
  local desc="$1" cwd="$2" cmd="$3" want="$4"
  raw=$(jq -Rn --arg c "$cmd" --arg d "$cwd" '{tool_input:{command:$c},cwd:$d}' | "$H")
  if [ -z "$raw" ]; then got=allow; else got=$(printf '%s' "$raw" | jq -r '.hookSpecificOutput.permissionDecision'); fi
  [ "$got" = "$want" ] && echo "  PASS  $desc -> $got" || { echo "  FAIL  $desc -> $got (want $want)"; FAILED=1; }
}
FAILED=0

git -C "$repo" switch -q main
check "commit on main"                    "$repo" 'git commit -m "feat: x"'            deny
check "env-prefixed commit on main"       "$repo" 'FOO=1 git commit -m "feat: x"'      deny
check "read-only command on main"         "$repo" 'git log --oneline'                  allow
check "git -C into main repo from /tmp"   "$tmp"  "git -C $repo commit -m x"           deny
check "push while on main"                "$repo" 'git push'                           deny

git -C "$repo" switch -q rh/x
check "commit on rh/x"                    "$repo" 'git commit -m "feat: x"'            allow
check "push rh/x to rh/x"                 "$repo" 'git push origin rh/x'               allow
check "explicit refspec to main"          "$repo" 'git push origin rh/x:main'          deny
check "positional main from rh/x"         "$repo" 'git push origin main'               deny
check "git -c option before push to main" "$repo" 'git -c a=b push origin rh/x:main'   deny

check "plain push, upstream=origin/main"  "$trap_repo" 'git push'                      deny
check "remote-only push, upstream trap"   "$trap_repo" 'git push origin'               deny
check "explicit rh refspec beats trap"    "$trap_repo" 'git push origin rh/y:rh/y'     allow

check "commit on unborn main"             "$unborn" 'git commit -m "feat: x"'          deny

exit $FAILED
