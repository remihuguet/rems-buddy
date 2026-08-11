#!/usr/bin/env bash
# PreToolUse guard: refuse git commands carrying AI/tool attribution.
#
# Claude Code's built-in instructions append a `Co-Authored-By: Claude` trailer
# and a "Generated with Claude Code" footer. The skill tells the model not to;
# this makes it impossible.
set -uo pipefail

input=$(cat)

command -v jq >/dev/null 2>&1 || exit 0

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

printf '%s' "$cmd" | grep -Eqi \
  'co-authored-by:[[:space:]]*claude|generated with[[:space:]]*\[?claude code|🤖[[:space:]]*generated with' \
  || exit 0

reason="attribution-policy: this commit message carries AI/tool attribution.

Remove the line entirely — a 'Co-Authored-By: Claude' trailer, a 'Generated
with Claude Code' footer, or any equivalent credit. Do not reword it to pass
this check, and do not substitute another tool credit.

If the user explicitly asked for attribution, tell them the hook blocked it
so they can bypass it themselves."

jq -n --arg reason "$reason" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
