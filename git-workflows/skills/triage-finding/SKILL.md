---
name: triage-finding
description: Decide whether a third-party finding (CodeRabbit, Snyk, Aikido, pentest report, a colleague's issue) is real here before anyone acts on it
argument-hint: "[MR url, note url, or paste the finding — plus any context you already know]"
disable-model-invocation: true
allowed-tools: Read Glob Grep Bash(git:*) Bash(glab:*) WebFetch
---

## Finding

$ARGUMENTS

## Context

- Repo: !`basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"`
- Branch: !`git branch --show-current 2>/dev/null || echo "n/a"`

## Task

Reach a verdict on each finding. A verdict is the deliverable — not a fix, not a plan, not a
severity table. Nothing gets applied from this skill.

Resolve `$ARGUMENTS` first: an MR or note URL means `glab mr view <mr> --comments` (or fetch the
page) to get the finding text; pasted text is the finding itself. Then read the code the finding
names, and the callers that reach it.

### The three verdicts

- **REAL** — reachable in this repo. Name the actor, input or state, and the wrong outcome it
  produces. If you cannot name all three, it is not REAL yet.
- **FALSE** — the premise is wrong. Name the wrong premise: the function it describes does
  something else, the path it traces does not exist, the version it assumes is not the one here.
- **DISMISSED** — technically true, not reachable here. Name the *specific* control that closes
  it. A control is a fact about this deployment, not a reassurance: an M2M-only token audience,
  a caller gated to one GCP service account, an env var that is false by default and set at
  deploy time, authoring restricted to Django admin, a human review step before publish.

"Needs more information" is a fourth outcome and a legitimate one — see below.

### Rules

**No severity without a path.** Before rating anything, state how it would be exploited or how
it would fail. A finding whose path you cannot trace gets `REAL — path not established`, never a
severity. This is the gate, not a follow-up question.

**The reporter's severity is an input, not a fact.** Downgrading is the normal outcome. A
scanner rates the pattern; you are rating the instance, in this deployment.

**Missing context stops the verdict.** When one fact decides it — is this endpoint public, who
holds this permission, is that flag on in prod — ask for exactly that fact and stop. Never guess
a severity to fill the slot, and never split the difference between two readings.

**Three to six lines per finding.** If a verdict needs more, the extra length belongs in the
follow-up issue, not here. Volume of output is not evidence of rigour.

**A control that only holds today is not DISMISSED.** If the reason it is unreachable is a
convention rather than an enforced boundary, say REAL and name the convention as the fragile part.

### Deployment facts worth checking before dismissing

Do not restate these from memory — check the current state, and read the recorded ones rather
than re-deriving them: token audiences and which backends are end-user-facing vs M2M-only, S2S
auth via Google identity tokens, and IAP's per-service exemptions are all already written down
in the memory files for this workspace. Verify they still hold for the service in question.

## Output

Per finding, nothing else:

```
[REAL|FALSE|DISMISSED|NEEDS-CONTEXT] <one-line restatement of the claim>
  Path:    <actor/input/state → wrong outcome>  | or: the wrong premise | or: the control that closes it
  Where:   path/to/file.py:120
  Then:    <fix in one clause, follow-up issue, or the one fact you need>
```

Close with one line: how many REAL, and which one to act on first. No summary table, no praise,
no restatement of what the scanner said.
