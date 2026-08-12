# standards-review

MR/PR review scoped to conformity.

```
/standards-review https://gitlab.com/group/project/-/merge_requests/237
/standards-review 237 --post
/standards-review            # the MR for the current branch
```

One question: does the change conform to the standards **this repo declares for itself**? In three parts — the rules the repo writes down, the architectural drift that passes review because each step looks locally reasonable, and whether the normative documents the change ships still describe the code it ships.

The companion lens to `behavior-review`. Same verb, different question: that one asks whether the change did what it promised and whether tests watch it; this one asks whether it was built the way this repo says to build things. Neither hunts bugs — `/code-review` owns that.

## What it does differently

**The repo outranks the skill.** Step one is reading `AGENTS.md`, `CONTRIBUTING.md`, `docs/adr/`, the written rule set (`.packmind/standards/`, `.claude/rules/`, `.cursor/rules/`) and the lint config, then applying them in strict precedence: the repo's own documents beat a marketplace skill, which beats generic best practice. A finding you can't cite to one of those is a preference, and gets labelled as one or dropped.

**It delegates the rule text.** The `python-architecture`, `python-testing`, `coding-standards` and `git-workflows` plugins already hold the rules; this skill names which one owns each cluster and loads only what the diff touches. It deliberately does not restate them — two skills stating the same rule differently is worse than neither.

**It reviews documents as code.** The part a linter cannot do:

> A snippet pasted into `AGENTS.md` or an ADR has no mechanical link to the symbol it copies, so nothing fails when the two diverge.

So it diffs every quoted snippet against the shipped code, greps the normative docs for identifiers the change deleted or renamed, checks an ADR shipped inside the MR against the house format *and against itself*, and flags identity-bearing config — a UUID or account id in infrastructure code — that carries no comment saying which entity it is. In a repo whose docs say "treat these as the source of truth", that class of drift is a defect.

## Drift catalog

`references/drift-catalog.md`, loaded on demand: eleven failure modes with their grep-able triggers, split into a **portable** half (fail-open authorization, silent partial failure, one-phase incompatible removal, boundary-crossing rename, invariant-as-flag-plus-fallback, mis-tiered tests) and a **DDD/CQRS** half (Repository-vs-Gateway, scoped-repository proliferation, read side delegating to a write repo, internal code reading through views, authorization in the command). A repo that doesn't declare that architecture skips the second half.

The false-positive guards matter as much as the catalog — including the one that keeps reports honest: a local compromise matching every neighbour in the file is the file's pattern, not this change's defect.

## Output

A rating out of 10 broken into layering / declared-standard conformity / drift risk / normative-doc accuracy — never a bare approve — then findings as Critical / Major / Minor, each with `file:line`, the rule and where it's written, why it matters here, and the fix. "No drift found" is a valid result.

## Posting

Reports in the terminal. Posts to the MR only with `--post` or when you ask, as a resolvable **discussion thread**.

## Requirements

`glab` (GitLab) or `gh` (GitHub), authenticated.

Marked `disable-model-invocation: true` — Claude won't start a review on its own.
