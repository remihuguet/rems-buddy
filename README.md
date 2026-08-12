# rems-buddy

Rem's buddy — reusable Claude Code skills and hooks packaged as a plugin marketplace. Install once, use across all projects.

## Installation

```
/plugin marketplace add remihuguet/rems-buddy
/plugin install git-workflows@rems-buddy
```

Or from a local checkout:

```
/plugin marketplace add /Users/remihuguet/workspaces/personal/rems-buddy
```

Then `/plugin` to browse and install individual plugins.

## Plugins

### `git-workflows` — commits, MRs, and branch safety

| | |
|---|---|
| `/commit` | one conventional commit from the current changes |
| `/commit-push` | commit, push, open or update a GitLab MR |
| `/fix-mr [mr]` | fix failing CI and address CodeRabbit / human review comments |

Plus two skills Claude loads on its own — `conventional-commits` (the allowed type list and subject format) and `branch-safety` (`rh/` prefix, never `main`).

**Enforced by hook:** a `PreToolUse` guard denies `git commit` and `git push` while on `main` or `master`. Read-only git commands pass through. This is deliberate belt-and-braces: the skill tells Claude the rule, the hook makes it unskippable when context gets long.

### `attribution-policy` — no AI attribution

Overrides Claude Code's built-in instruction to append `Co-Authored-By: Claude` trailers and "Generated with Claude Code" footers.

**Enforced by hook:** a `PreToolUse` guard denies any `git` command whose text carries an attribution trailer or footer.

### `bugfix` — TDD bug fix

```
/bugfix users can log in with expired tokens
```

RED (a test that must fail for the predicted reason) → GREEN (minimal fix) → commit.

### `behavior-review` — MR review scoped to behavior

```
/behavior-review <mr url or number>
```

Reads the MR description and every spec it links, then checks two things the diff alone can't answer: does the change keep the promises it made, and is every behavior it changed pinned by a test. Extends past the diff — when a change works by altering a shared dependency, it enumerates that dependency's consumers, which is where the untested behavior hides.

Rates out of 10 across fidelity / coverage presence / coverage completeness / test design rather than approving. Posts to the MR only with `--post`.

### `standards-review` — MR review scoped to conformity

```
/standards-review <mr url or number>
```

The companion lens to `behavior-review`: not "did it do what it promised", but "was it built the way this repo says to build things". Reads the repo's own declared rules first — `AGENTS.md`, `CONTRIBUTING.md`, ADRs, the written standards, the lint config — and applies them in strict precedence over any skill in this marketplace. Delegates the rule text to the `python-architecture` / `python-testing` / `coding-standards` plugins rather than restating it.

Also reviews **documents as code**: a snippet pasted into `AGENTS.md` or an ADR has no link to the symbol it copies, so nothing fails when they diverge. Carries a drift catalog of eleven failure modes with grep-able triggers, split portable / DDD-CQRS.

Rates out of 10 across layering / declared-standard conformity / drift risk / normative-doc accuracy. Posts to the MR only with `--post`.

### `issue-workflow` — Notion issue loop

```
/issue https://notion.so/...
```

Read the issue, analyze, plan, sync the plan back to Notion, implement on a feature branch, open the MR, cross-link both ways. Requires the Notion MCP server.

### `coding-standards`

Docstrings off by default, comments only where naming and abstraction can't carry the context, domain vocabulary in names.

### `python-testing` · `python-architecture`

Gated to `**/*.py` via skill `paths`, so they stay quiet in non-Python repos.

- `testing-strategy` — three-tier unit/integration/e2e split, fakes over mocks, `test_{subject}__should_{behavior}`
- `pytest-conventions` — function-style tests, factory fixtures, parametrize, `pytest.raises`
- `layers-and-ddd` — five-layer hexagonal architecture, value objects, entities, aggregates, repositories
- `messaging-and-cqrs` — MessageBus, UnitOfWork, command/query separation
- `file-organization` — group first and split on evidence, no `utils`/`helpers`

## Plugin structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json           # manifest
├── skills/
│   └── my-skill/
│       └── SKILL.md          # auto-discovered; no manifest entry needed
├── hooks/
│   └── hooks.json            # deterministic enforcement (optional)
├── scripts/
│   └── guard-something.sh    # hook implementation (optional)
└── README.md
```

## Adding a plugin

1. Create the directory above and add `.claude-plugin/plugin.json`
2. Write `skills/<name>/SKILL.md` — the `description` must say **what it covers and when to use it**, since that's the whole trigger surface
3. Add `paths:` if the skill is language- or framework-specific
4. Add `disable-model-invocation: true` if it's a workflow with side effects that only you should trigger
5. Register the plugin in `.claude-plugin/marketplace.json`
6. `claude plugin validate ./<plugin>` — a frontmatter YAML error loads the skill with silently empty metadata rather than erroring at runtime

See `CLAUDE.md` for the conventions on writing skills that don't fight current models.
