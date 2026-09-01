#!/usr/bin/env bash
# Run: ./guard-attribution.test.sh
#
# Trailer assembled at runtime so this file's own text never trips the guard.
T="Co-Authored"; T="$T-By: Claude <noreply@anthropic.com>"
G="Generated with"; G="$G [Claude Code](https://claude.com/claude-code)"
H="${1:-$(dirname "$0")/guard-attribution.sh}"
check() {
  local desc="$1" cmd="$2" want="$3"
  raw=$(jq -Rn --arg c "$cmd" '{tool_input:{command:$c},cwd:"."}' | "$H")
  if [ -z "$raw" ]; then got=allow; else got=$(printf '%s' "$raw" | jq -r '.hookSpecificOutput.permissionDecision'); fi
  [ "$got" = "$want" ] && echo "  PASS  $desc -> $got" || { echo "  FAIL  $desc -> $got (want $want)"; FAILED=1; }
}
FAILED=0
check "git log --grep for the trailer"      "git log --grep=\"$T\""                     allow
check "git show piped to grep"              "git show | grep \"$T\""                    allow
check "grep over transcripts (not git)"     "grep -r \"$T\" ~/.claude"                  allow
check "clean commit"                        'git commit -m "feat: x"'                   allow
check "commit WITH trailer"                 "git commit -m \"feat: x

$T\""                                                                                   deny
check "commit WITH footer"                  "git commit -m \"feat: x

$G\""                                                                                   deny
check "tag WITH trailer"                    "git tag -a v1 -m \"rel

$T\""                                                                                   deny
check "chained commit WITH trailer"         "cd /tmp && git commit -m \"x

$T\""                                                                                   deny
check "env-prefixed commit WITH trailer"    "FOO=1 git commit -m \"x

$T\""                                                                                   deny
check "-c option commit WITH trailer"       "git -c a=b commit -m \"x

$T\""                                                                                   deny
check "-C path commit WITH trailer"         "git -C /tmp commit -m \"x

$T\""                                                                                   deny
exit $FAILED
