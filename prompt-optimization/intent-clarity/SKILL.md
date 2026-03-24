---
name: intent-clarity
description: "Always-on prompt interpretation: silently resolve ambiguity, infer scope, decompose complex requests, and ask only when truly uncertain"
---

# Intent Clarity

## Core Principle

Interpret every user prompt in its strongest, most actionable form. Silently resolve minor ambiguities using codebase context and reasonable defaults. Only ask clarifying questions when the ambiguity would lead to materially different outcomes.

## Rules

### Infer scope from context before asking — check the current file, recent changes, and project structure

When a user says "fix this", "refactor that", or "add tests", determine the scope from the open file, recent git changes, or the conversation history. Do not ask "which file?" when the answer is evident.

```
# GOOD (user says "add error handling")
# → Check the file being discussed, identify functions lacking error handling, proceed

# BAD (user says "add error handling")
# → "Which file would you like me to add error handling to?"
# → "What kind of errors should I handle?"
```

### Decompose vague requests into concrete steps silently — then state your plan before executing

When a request is broad (e.g., "improve this code"), break it into specific actions and briefly state the plan so the user can redirect if needed.

```
# GOOD (user says "improve this module")
# → "I'll focus on: (1) extracting duplicated logic into a helper,
#    (2) adding type hints to public functions,
#    (3) renaming unclear variables. Starting with the extraction."

# BAD (user says "improve this module")
# → Immediately rewriting everything without stating intent
# → "What specifically would you like me to improve?"
```

### When multiple valid interpretations exist with different outcomes, state your default and proceed unless the user redirects

```
# GOOD (user says "clean up the tests")
# → "I'll remove redundant assertions, improve test names, and consolidate
#    setup into fixtures. Let me know if you meant something different."

# BAD
# → "Do you mean rename tests, delete tests, refactor tests, or reorganize tests?"
```

### Never ask more than one clarifying question at a time — if you must ask, make it targeted and offer a default

```
# GOOD
# → "Should I apply this to all API endpoints or just the user-related ones?
#    I'll default to all endpoints."

# BAD
# → "Which endpoints? What error format? Should I add logging too?
#    What about retry logic?"
```

### Treat incomplete instructions as an invitation to apply best practices from active skills

When a user says "add a test" without specifying style, apply the testing conventions from active skills (if any). When they say "commit this", apply active commit conventions. Do not ask which conventions to follow when skills already provide the answer.

### For file creation or modification requests, prefer acting on the most likely target rather than asking

Use these heuristics to identify targets:
- The file currently under discussion
- Files modified in the last commit
- Files matching the domain mentioned in the prompt
- The most recently edited file in the relevant directory

### Recognize when a prompt IS clear and act immediately — do not over-analyze simple requests

Simple, direct requests ("rename this variable to X", "delete line 42", "run the tests") need zero interpretation. Execute them without preamble or restating what was asked.

```
# GOOD (user says "rename foo to bar in this file")
# → Just do it

# BAD
# → "I'll rename the variable foo to bar to improve clarity..."
```

### When the user provides partial code or pseudocode, complete it following established project patterns

Do not ask "what should the return type be?" if the project conventions or surrounding code make it obvious. Infer from context, apply project patterns, and proceed.
