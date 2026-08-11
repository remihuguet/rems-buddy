# rems-buddy

A Claude Code plugin marketplace holding Rem's reusable skills and hooks.

## Structure

- `.claude-plugin/marketplace.json` — registers every plugin
- Each plugin subdirectory contains:
  - `.claude-plugin/plugin.json` — manifest (name, description, version, author)
  - `skills/<skill-name>/SKILL.md` — one skill per directory; auto-discovered, no manifest entry needed
  - `hooks/hooks.json` + `scripts/*.sh` — deterministic enforcement, where a rule must not be skippable
  - `README.md`

## How skills actually load

This matters for how they're written, so don't reintroduce the old framing:

- Only a skill's `description` sits in context permanently. The body loads when the skill is invoked — by name, or by Claude judging it relevant from that description.
- **The `description` is the trigger.** It states what the skill covers *and when to use it*. A description without a trigger condition either misfires or never fires.
- Once loaded, the body stays in context for the rest of the session. Every line is a recurring cost — keep bodies to the rules that differ from what Claude does anyway.
- `paths:` gates a skill to matching files (the Python skills use `paths: "**/*.py"`), so it can't fire in an unrelated repo.
- `disable-model-invocation: true` on the workflow skills means only Rem triggers them, and their descriptions stay out of context entirely.

## Plugins

| Plugin | Provides | Description |
|---|---|---|
| `bugfix` | `/bugfix` | TDD bug fix workflow: RED, GREEN, commit |
| `git-workflows` | `/commit`, `/commit-push`, `/fix-mr` + 2 skills + hook | Conventional commits, GitLab MRs; hook denies commit/push on `main` |
| `issue-workflow` | `/issue` + 1 skill | Notion-issue loop: analyze, plan, implement, MR, sync back |
| `attribution-policy` | 1 skill + hook | No AI attribution anywhere; hook blocks it in commits |
| `coding-standards` | 1 skill | Docstring, comment, and naming conventions |
| `python-testing` | 2 skills | Testing strategy and pytest conventions (`paths`-gated) |
| `python-architecture` | 3 skills | Hexagonal layers, DDD, MessageBus/CQRS (`paths`-gated) |

## Conventions

- Conventional commits for changes to this repo
- Register new plugins in `marketplace.json`; skills inside a plugin need no entry
- Run `claude plugin validate ./<plugin>` after editing frontmatter — a YAML parse error makes a skill load with *silently empty* metadata rather than failing loudly
- Quote any `description` containing `: ` (a colon plus space breaks unquoted YAML scalars)
- Prefer a hook over a skill for anything that must not be skippable; a skill is advice, a hook is a guarantee
- Test a hook script by piping a sample `PreToolUse` payload to it before trusting it

## Writing skills for current models

Claude 5-generation models handle a lot that older harnesses spelled out. Before adding a rule, ask whether removing it would change any behavior:

- Don't restate model defaults — well-known specs, generic clean-code advice, or "figure out the scope from context"
- Don't add verification scaffolding ("run the suite and confirm it passes", "double-check your work"). Per Anthropic's Opus 5 guidance this causes over-verification. Domain-specific ordering, like TDD's test-must-fail-first, is different and stays
- Don't restrict tool use in ways that fight the harness — e.g. "ask only one question at a time" conflicts with `AskUserQuestion` batching up to four
- Do state scope limits explicitly; scope creep is a real failure mode worth constraining
- Keep exactly one rule per topic across the whole marketplace. Two skills giving different test-naming conventions is worse than neither
