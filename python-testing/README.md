# python-testing

Testing strategy and pytest mechanics for Python projects. Slash-only: invoke a skill by name. The work repos already inline these rules into their own `AGENTS.md`, so Claude does not need to fetch them there.

## Skills

- **testing-strategy** — three-tier `unit`/`integration`/`e2e` split, "unit test" as behavior through an entry point with fakes, fakes over mocks, `test_{subject}__should_{expected_behavior}` naming, Arrange/Act/Assert
- **pytest-conventions** — function-style tests over classes, fixtures and factory fixtures instead of `setUp`, `parametrize`, `pytest.raises` with `match`

`testing-philosophy` and `testing-organization` were merged into `testing-strategy`; they overlapped on what a unit test is and where it lives.
