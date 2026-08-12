---
name: behavior-review
description: "Review an MR/PR for behavior: does it do what the description and linked spec promised, and is every behavior it changed pinned by a test"
argument-hint: "[MR/PR url, number, or blank for the current branch]"
disable-model-invocation: true
allowed-tools: Read Glob Grep Write WebFetch Bash(glab:*) Bash(gh:*) Bash(git:*) mcp__claude_ai_Notion__notion-fetch
---

## Target

$ARGUMENTS

## Context

- Branch: !`git branch --show-current 2>/dev/null || echo "not a repo"`
- MR for this branch: !`glab mr list --source-branch "$(git branch --show-current 2>/dev/null)" 2>/dev/null | head -5 || echo "none"`

## What this review is

One question, asked in three parts:

1. **Fidelity** — does the change do what its description and linked spec said it would?
2. **Coverage presence** — is every behavior that changed pinned by an automated test?
3. **Coverage completeness** — do those tests cover the acceptance cases a careful person would predict, or only the happy path the author had in mind?

**Not in scope:** code style, naming, architecture, or bug hunting. `/code-review` and the `coding-standards` / `python-architecture` skills own those. If you spot a real bug, mention it in one line at the end under "Outside this review" — don't let it displace the behavior analysis.

Never modify source, never approve or merge, never rewrite the author's tests for them. Name the missing case; the author writes it.

## Workflow

### 1. Gather the contract before reading any code

Resolve `$ARGUMENTS` to a concrete MR/PR — blank means the one for the current branch.

- `glab mr view <n>` / `gh pr view <n>` for title, description, state
- Follow **every** link the description contains: the tracking issue, the ADR, the spec, the design doc. Read them **in full**, not the summary — a behavior review is only as good as its knowledge of what was promised
- Notion issues: `notion-fetch` the page. Other hosts: `WebFetch`
- Read any ADR or design doc shipped *inside* the MR itself — a change that documents its own decision has handed you its acceptance criteria

Prefer the platform API over the local checkout. Reviewing the branch as published is what the reviewer of record sees.

### 2. Build the promise inventory

Extract every falsifiable claim from the description and the spec into a flat list. A claim is falsifiable if you could point at code or a test and say "no, that's not true".

Include the quiet ones: "no schema change", "inert until configured", "X stays unchanged", "fails closed". Negative promises are the easiest to break and the least likely to be tested.

Then trace each one to the diff and mark it ✅ / ❌ / ⚠️ partial. Two failure directions matter equally:

- **claimed but absent** — the description promises behavior the diff doesn't implement
- **present but unclaimed** — the diff changes behavior the description never mentions, so nobody agreed to it

### 3. Build the seam inventory — including the behavior that changed invisibly

This is the step that finds what diff-reading misses, and it is the whole reason this skill exists.

List every behavior the change alters *as observed from outside* — per endpoint, per command, per user-facing path. Then extend that list past the diff:

> **When a change works by altering a shared dependency, enumerate every consumer of that dependency, not every line of the diff.**

A widened scope object, a changed guard in a base class, a relaxed filter in a shared gateway, a new default in a factory — each changes behavior at call sites that never appear in the diff. `grep` for the consumers of anything the diff touched at a shared seam. Those consumers are where the untested behavior lives, because the author never saw them scroll past.

If the spec enumerates its own seams ("the ten call sites", "the three accepted effects"), walk *that* list mechanically. An author who counted the seams in prose has usually still tested them from memory.

### 4. Build the coverage matrix

For each behavior in the seam inventory, ask what tests exist — and search the **whole repository**, not the diff. "No test in this MR" and "no test anywhere" are different findings with different severities, and only the second is alarming.

Every behavior change worth shipping has at least two axes to pin. The pair depends on the change; the shape is always the same:

| Axis | The test says |
|---|---|
| Positive | the new thing happens for the intended actor / input |
| Negative | the old restriction still holds for everyone else, or for the same actor on a neighboring action |

A change tested only positively hasn't been tested — it has been demonstrated. Read a passing positive test as "the feature exists" and nothing more.

Then check for the cases a careful person predicts and an author forgets:

- **The unchanged neighbor** — the sibling endpoint/branch that was deliberately *not* changed. Untested, it becomes indistinguishable from an oversight
- **Documented accepted risks and non-goals** — anything the spec says "we deliberately allow / deliberately didn't widen". These need characterization tests most of all: they're the boundary a future refactor will cross silently
- **Error and absence semantics** — 404-vs-403, empty vs missing, the not-found path. Changes to *what is in scope* silently change *what out-of-scope means*
- **Boundary shape of config/infra contracts** — if a Terraform conditional, a feature flag, or a deploy step depends on a stated parsing behavior, something must assert that behavior
- **The realistic production shape** — a parser tested only with two entries when production ships one; a list tested only when non-empty
- **Union, not just reach** — a test asserting the new set contains the new item, but never that it still contains the old one, passes for a bug that *swapped* the scope instead of widening it

### 5. Judge where each behavior is pinned, not only whether

A heuristic, not a rule — but the one that decides whether a suite is still readable in a year.

Core behavior wants to be exercised through the **service-layer API with fakes** where the collaborators get in the way — the "unit" tier as `python-testing:testing-strategy` defines it: behavior through an entry point with in-memory fakes, not a test per class. Behavior that genuinely *lives* at the entrypoint — status codes, routing, serialization, authorization at the request boundary — wants e2e. Don't restate the tier definitions; that skill owns them, and a repo's own convention wins over both.

The goal being served: **test suites that read as a clear statement of the domain's API.** When a core rule is observable only through HTTP, the suite documents the transport instead of the domain, and every entrypoint refactor churns tests that were never about the entrypoint.

So once the matrix says a behavior is covered, ask *where* it's covered:

- pinned only at e2e, but the rule it encodes is a domain rule → **Minor**: it belongs at service level, with a thin e2e kept for the path
- pinned at service level, but the entrypoint mapping it needs (status code, payload shape) is unpinned → **Minor** the other way
- pinned at both, deliberately, each testing its own layer → that's the target; say so in the credit section

Don't raise it when the behavior really is boundary behavior, when there's no service seam to test against, or when a one-line change honestly doesn't earn a second test. A tier finding is **never Critical or Major on its own** — it's about the suite's legibility, not about whether the behavior works. Severity comes from behavior being unobserved; tier placement only ever adjusts *Test design quality*.

### 6. Verify the description's own coverage claims

Descriptions say things like "every behavior is pinned by two tests" or "still 403s on A, B, C and D". Check each named test actually exists. A false coverage claim is a Major finding on its own: reviewers accept the argument, not the diff, and a claim nobody verified is how an untested path gets merged with everyone's blessing.

### 7. Discount coverage that isn't real

- A branch that is **unreachable** given its callers is not a guarded path — it cannot be covered, so don't let it fill a matrix cell. Trace the caller before crediting a guard
- A test whose assertion would pass under the bug it's meant to catch is not coverage
- A test that only exercises a mock of the thing under test proves the mock works

## Output

### Global rating

A score out of 10 plus a one-line verdict — never a bare approve/reject. Break it into the four dimensions so the number is arguable:

| Dimension | Score | Note |
|---|---|---|
| Fidelity to description + spec | /10 | |
| Tests present for new behavior | /10 | |
| Behavior coverage completeness | /10 | |
| Test design quality | /10 | assertion strength and tier placement (step 5) |

Then say plainly what would change the verdict: which specific findings block merge and which are follow-up.

### Findings by severity

Severities are about *behavior*, not correctness — a Critical here means an unkept promise or an unwatched behavior, not a crash.

- **Critical** — a promised behavior isn't implemented; or a behavior change with security, money, or data-loss consequences has no test in either direction
- **Major** — a changed behavior has no test anywhere; a coverage claim in the description is false; a documented accepted risk or non-goal is unpinned; a contract the change depends on (config parsing, infra conditional) is unasserted
- **Minor** — a weak assertion that would pass under the bug it targets; an untested parallel path with a tested twin; unpinned error semantics; a branch credited as guarded that no test can reach

Each finding: what behavior is unobserved, why it matters *here* (not in general), and the concrete test to add — actor, action, expected result. One line each is enough; the author knows the codebase better than you do.

### Credit what's good

Name the test patterns worth repeating, specifically. The strongest signal in a well-tested MR is a new test written as the **twin of an existing negative test** — same setup, one-line delta, a comment saying which test it mirrors. That makes a behavior change legible as a diff between two tests instead of as prose. When you see it, say so; it's the habit you want more of.

Close with the generalizable lesson the gaps suggest, if there is one. "These four endpoints were missed because they changed through a shared gateway rather than through the diff" teaches more than four separate findings do.

## Posting

Report in the terminal by default. Post to the MR **only** when asked — a flag in `$ARGUMENTS` (`--post`), or a follow-up message.

When posting, use a **discussion thread**, not a plain note, so it can be resolved:

```
glab api -X POST "projects/<url-encoded-path>/merge_requests/<iid>/discussions" -F "body=@<file>"
gh pr review <n> --comment --body-file <file>
```

Write the body to the session scratchpad first — heredocs mangle backticks and tables. Leave the thread unanchored: behavior findings are usually about code that *isn't* in the diff, so there's no line to attach them to.
