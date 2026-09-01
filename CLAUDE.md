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
- `disable-model-invocation: true` means only Rem triggers the skill, and its description stays out of context entirely. Every skill here now carries it except `no-ai-attribution`, `branch-safety`, `conventional-commits`, and `notion-issue-sync`.
- **The standards skills are slash-only on purpose.** The work repos inline the same rules into their own `AGENTS.md` via Packmind, so those rules are already in context unconditionally and the model never needs to fetch them — across 118 sessions and 154 Python edits, not one of them was ever invoked. They stay here as the banked copy, reachable by name in a repo that has no standards of its own.
- `paths:` is not used. It gates how a skill is surfaced *to the model*, which does nothing once model invocation is off.

## Plugins

| Plugin | Provides | Description |
|---|---|---|
| `bugfix` | `/bugfix` | TDD bug fix workflow: RED, GREEN, commit |
| `git-workflows` | `/commit-push`, `/fix-mr`, `/triage-finding` + 2 skills + hook | Conventional commits, GitLab MRs; hook denies commit/push on `main` |
| `issue-workflow` | `/issue` + 1 skill | Notion-issue loop: analyze, plan, implement, MR, sync back |
| `attribution-policy` | 1 skill + hook | No AI attribution anywhere; hook blocks it in commits |
| `coding-standards` | `/naming-and-comments` | Docstring, comment, and naming conventions |
| `python-testing` | 2 slash-only skills | Testing strategy and pytest conventions |
| `python-architecture` | 3 slash-only skills | Hexagonal layers, DDD, MessageBus/CQRS |

## Conventions

- Conventional commits for changes to this repo
- **Releasing:** any change under a plugin directory bumps that plugin's `plugin.json` version in the same commit — the marketplace refresh skips version-unchanged plugins, so an unbumped push ships nothing to installed caches. Enforced by `.githooks/pre-push` (`git config core.hooksPath .githooks` once per clone). After merge: update the marketplace, `/reload-plugins`, verify the skill is listed. `plugin.json` is the only place a version lives; `marketplace.json` entries carry none
- Register new plugins in `marketplace.json`; skills inside a plugin need no entry
- Run `claude plugin validate ./<plugin>` after editing frontmatter — a YAML parse error makes a skill load with *silently empty* metadata rather than failing loudly
- Quote any `description` containing `: ` (a colon plus space breaks unquoted YAML scalars)
- Prefer a hook over a skill for anything that must not be skippable; a skill is advice, a hook is a guarantee
- Test a hook script by piping a sample `PreToolUse` payload to it before trusting it — see `attribution-policy/scripts/guard-attribution.test.sh`. A guard that matches its pattern anywhere in the command blocks reading about the rule as well as breaking it

## Writing skills for current models

Claude 5-generation models handle a lot that older harnesses spelled out. Before adding a rule, ask whether removing it would change any behavior:

- Don't restate model defaults — well-known specs, generic clean-code advice, or "figure out the scope from context"
- Don't add verification scaffolding ("run the suite and confirm it passes", "double-check your work"). Per Anthropic's Opus 5 guidance this causes over-verification. Domain-specific ordering, like TDD's test-must-fail-first, is different and stays
- Don't restrict tool use in ways that fight the harness — e.g. "ask only one question at a time" conflicts with `AskUserQuestion` batching up to four
- Do state scope limits explicitly; scope creep is a real failure mode worth constraining
- Keep exactly one rule per topic across the whole marketplace. Two skills giving different test-naming conventions is worse than neither
