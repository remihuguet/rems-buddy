---
name: standards-review
description: "Review an MR/PR for conformity to the repo's own standards: architectural drift, and whether the normative docs the change ships still match the code it ships"
argument-hint: "[MR/PR url, number, or blank for the current branch]"
disable-model-invocation: true
allowed-tools: Read Glob Grep Write WebFetch Bash(glab:*) Bash(gh:*) Bash(git:*)
---

## Target

$ARGUMENTS

## Context

- Branch: !`git branch --show-current 2>/dev/null || echo "not a repo"`
- MR for this branch: !`glab mr list --source-branch "$(git branch --show-current 2>/dev/null)" 2>/dev/null | head -5 || echo "none"`
- Declared standards here: !`ls AGENTS.md CLAUDE.md CONTRIBUTING.md 2>/dev/null; ls -d docs/adr .packmind/standards .claude/rules .cursor/rules 2>/dev/null`

## What this review is

Does the change conform to the standards **this repo declares for itself**? Three parts:

1. **Declared standards** — the rules the repo writes down, in the artifacts it calls authoritative.
2. **Drift** — expensive failure modes that pass review because each one looks locally reasonable.
3. **Documents as code** — the normative docs and config a change ships must describe the code it ships. In a repo that tells its readers "treat these as the source of truth", a stale doc is a defect, not a typo.

**Not in scope:** behavior and test coverage — `behavior-review` owns those; bug hunting — `/code-review` owns that.

A stale claim about *behavior* ("inert until configured", "still 403s on X") belongs to `behavior-review`'s promise inventory: note it in one line and move on. This review owns claims about *artifacts*.

Never modify source, never approve or merge. Name the deviation and the fix; the author applies it.

## Workflow

### 1. Find what this repo declares, and let it win

Read before judging anything:

- `AGENTS.md` / `CLAUDE.md`, `CONTRIBUTING.md`, `docs/adr/`
- whatever holds the written rules — `.packmind/standards/`, `.claude/rules/`, `.cursor/rules/`, a `docs/` playbook
- lint, type and test config (`pyproject.toml`, `ruff.toml`, `.pre-commit-config.yaml`) — a configured rule is a declared rule

Precedence, strictly: **the repo's own documents > a marketplace skill > generic best practice.** Where the repo is silent, the skills in step 3 speak. Where neither speaks, you have a preference rather than a finding — drop it, or label it as a preference in one line.

Note which artifacts the repo calls authoritative, and in what words. That sentence is what makes step 5 a defect rather than a nit.

### 2. Read the change as published

Prefer the platform API over the local checkout — review what the reviewer of record sees.

- `glab mr view <n>` / `gh pr view <n>`, plus the diff and the **commit list** (commit format is a declared standard in most repos here)
- No MR yet: diff the branch against its merge base
- Read the existing review threads, so you neither repeat a resolved finding nor miss that a later push landed after the last approval

### 3. Check the diff against the clusters — by delegation

These skills hold the rule text. Load the ones the diff actually touches; don't restate their rules, here or in your report:

| Cluster | Owner |
|---|---|
| layers, DDD, ports and adapters | `python-architecture:layers-and-ddd` |
| MessageBus, UnitOfWork, CQRS | `python-architecture:messaging-and-cqrs` |
| module and file placement | `python-architecture:file-organization` |
| test tiers, fakes, test naming | `python-testing:testing-strategy` |
| pytest mechanics | `python-testing:pytest-conventions` |
| names, comments, docstrings | `coding-standards:naming-and-comments` |
| commit format | `git-workflows:conventional-commits` |

Cite the rule you are applying, from the repo's own file wherever it has one. An uncited finding is step 1's "preference".

### 4. Check the drift catalog

Load [references/drift-catalog.md](references/drift-catalog.md) — failure modes already paid for, each with its grep-able trigger, plus the false-positive guards. The portable half applies to any backend; the second half only to DDD/CQRS ones.

### 5. Documents as code

The step a linter can't do, and the reason this skill exists.

- **A doc that quotes code drifts silently.** A snippet pasted into `AGENTS.md` or an ADR has no mechanical link to the symbol it copies, so nothing fails when the two diverge. Diff every quoted snippet against the shipped code. When they differ, the fix isn't only an edit: the doc should state the *guarantee* and point at the symbol.
- **A deleted symbol outlives its documentation.** Grep the normative docs for every identifier the diff removed or renamed.
- **An ADR shipped inside the MR is part of the MR.** Check it against the house format the existing ADRs set — status, section order, length — and against itself: a `Status: Accepted` ADR still saying "none decided here" is a leftover from its proposal revision. Check that its scope/file list names the files actually changed.
- **Config that encodes identity must name it.** A UUID, account id or ARN in infrastructure code with no comment saying *which* entity it is cannot be reviewed by anyone.
- **A doc the change should have touched and didn't** is the same finding as a stale one.

### 6. Discount what isn't a finding

- Consistency with the surrounding code beats abstract purity. A change that follows the file's existing pattern conforms; if the pattern itself is the problem, that's a follow-up — named as one.
- A pre-existing deviation the diff merely touches is not this MR's finding. Say so explicitly rather than padding the count.
- Walk the catalog's false-positive guards before raising anything from it.

## Output

### Global rating

A score out of 10 plus a one-line verdict — never a bare approve. Break it out so the number is arguable:

| Dimension | Score | Note |
|---|---|---|
| Layering & dependency conformity | /10 | |
| Declared-standard conformity | /10 | naming, commits, config safety |
| Drift risk | /10 | catalog hits |
| Normative-doc accuracy | /10 | step 5 |

Then say which findings block merge and which are follow-up.

### Findings by severity

Each finding: **severity** · `file:line` · the **rule** and where it is written · why it matters *here* · the concrete fix. Quote the offending code.

- **Critical** — a declared rule broken with real consequence: authorization that fails open, an incompatible removal shipped in one phase, a boundary contract changed with no coordination
- **Major** — a clear deviation from a written rule; a normative doc contradicting the code the MR ships; a catalog failure mode present
- **Minor** — a local deviation; a naming or comment miss; a doc inaccuracy with no behavioral reading

A clean diff is a valid result: say "no drift found" and stop.

### Credit what's good

Name the patterns worth repeating, specifically — above all the standards followed where it was tempting not to. Close with the generalizable lesson when the findings share a root cause; "a fix commit landed without updating the two documents that quote it" teaches more than three separate doc findings.

## Posting

Report in the terminal by default. Post **only** when asked — `--post` in `$ARGUMENTS`, or a follow-up message.

Use a **discussion thread**, not a plain note, so it can be resolved:

```
glab api -X POST "projects/<url-encoded-path>/merge_requests/<iid>/discussions" -F "body=@<file>"
gh pr review <n> --comment --body-file <file>
```

Write the body to the session scratchpad first — heredocs mangle backticks and tables.
