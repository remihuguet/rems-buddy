---
name: conventional-commits
description: "Commit message formatting rules based on the Conventional Commits specification"
---

# Conventional Commits

## Rules

### Format commit messages as `<type>(<scope>): <description>` where type is required and scope is optional

```
# Good
feat(auth): add password reset flow
fix: resolve null pointer in user service

# Bad
added password reset
bugfix - null pointer fixed
```

### Use only allowed types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `ci`

```
# Good
feat: implement dark mode toggle
fix: correct validation logic
docs: update API reference
chore: upgrade dependencies

# Bad
update: add new feature
improvement: better performance
misc: various changes
```

### Write the description in lowercase starting with imperative verb

```
# Good
feat: add user authentication
fix: remove deprecated api call

# Bad
feat: Added user authentication
fix: Removes deprecated API call
```

### Keep subject line under 72 characters for readability in git log and tools

```
# Good
feat(api): add pagination to user list endpoint

# Bad
feat(api): add pagination support to the user list endpoint with configurable page size and cursor-based navigation
```

### Add body separated by blank line for complex changes explaining what and why

```
# Good
fix(auth): handle expired token gracefully

Previously, expired tokens caused a 500 error.
Now returns 401 with clear message for client retry.

# Bad
fix(auth): handle expired token gracefully. Previously expired tokens caused a 500 error now returns 401 with clear message.
```

### Use `BREAKING CHANGE:` footer to signal breaking API or behavior changes

```
# Good
feat(api): change user endpoint response format

BREAKING CHANGE: user endpoint now returns nested address object instead of flat fields

# Bad
feat(api): change user endpoint response format (BREAKING)
```
