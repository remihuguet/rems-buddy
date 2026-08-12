# behavior-review

MR/PR review scoped to behavior.

```
/behavior-review https://gitlab.com/group/project/-/merge_requests/237
/behavior-review 237 --post
/behavior-review            # the MR for the current branch
```

Answers one question in three parts: does the change do what its description and linked spec promised, is every behavior that changed pinned by a test, and do those tests cover the cases a careful person would predict.

Deliberately **not** a code review — no style, architecture, or bug hunting. `/code-review` and the `coding-standards` / `python-architecture` plugins own those. Same verb, different lens.

## What it does differently

Reads the tracking issue and any ADR or spec the MR links, then builds a **promise inventory** (every falsifiable claim, including the quiet negative ones like "no schema change" or "inert until configured") and a **seam inventory** of behavior that actually changed.

The seam inventory is the point. It extends past the diff:

> When a change works by altering a shared dependency, enumerate every consumer of that dependency, not every line of the diff.

A widened scope object or a relaxed filter in a shared gateway changes behavior at call sites that never show up in the diff — which is exactly where the untested behavior lives, because the author never saw those files scroll past.

It also checks the description's own coverage claims ("still 403s on A, B, C and D") against the tests that actually exist. Reviewers accept the argument, not the diff.

## Where behavior should be pinned

A heuristic, not a rule. Core behavior wants exercising through the **service-layer API with fakes** — the "unit" tier as the `python-testing` plugin's `testing-strategy` skill defines it. Behavior that genuinely lives at the entrypoint — status codes, routing, serialization, authorization at the request boundary — wants e2e.

The goal is test suites that read as a clear statement of the domain's API. A core rule observable only through HTTP documents the transport instead of the domain, and every entrypoint refactor churns tests that were never about the entrypoint.

Tier placement never raises severity on its own — it adjusts the *test design quality* score. Severity comes from behavior being unobserved, not from which file the observation lives in.

## Output

A rating out of 10 broken into fidelity / coverage presence / coverage completeness / test design — never a bare approve — then findings as Critical / Major / Minor, where severity is about *behavior*, not correctness: a Critical is an unkept promise or an unwatched behavior, not a crash.

## Posting

Reports in the terminal. Posts to the MR only with `--post` or when you ask — as a resolvable **discussion thread**, unanchored, since behavior findings are usually about code that isn't in the diff.

## Requirements

`glab` (GitLab) or `gh` (GitHub), authenticated. Reading Notion-hosted specs needs the Notion MCP server; the `allowed-tools` line names it as `mcp__claude_ai_Notion__notion-fetch`, so adjust that if your connector is registered under a different server name.

Marked `disable-model-invocation: true` — Claude won't start a review on its own.
