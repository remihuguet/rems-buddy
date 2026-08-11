# bugfix

TDD bug fix workflow.

```
/bugfix users can log in with expired tokens
```

RED (a test that must fail, for the reason you predicted) → GREEN (the minimal fix) → commit as `fix(<scope>): ...`.

Marked `disable-model-invocation: true` — Claude won't start this loop on its own.

Test naming (`test_{subject}__should_{expected_behavior}`) and file placement match the `python-testing` plugin's `testing-strategy` skill.
