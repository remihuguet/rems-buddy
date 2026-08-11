# python-testing

Testing strategy and pytest mechanics for Python projects. Both skills are gated to `**/*.py` via skill `paths`.

## Skills

- **testing-strategy** — three-tier `unit`/`integration`/`e2e` split, "unit test" as behavior through an entry point with fakes, fakes over mocks, `test_{subject}__should_{expected_behavior}` naming, Arrange/Act/Assert
- **pytest-conventions** — function-style tests over classes, fixtures and factory fixtures instead of `setUp`, `parametrize`, `pytest.raises` with `match`

`testing-philosophy` and `testing-organization` were merged into `testing-strategy`; they overlapped on what a unit test is and where it lives.
