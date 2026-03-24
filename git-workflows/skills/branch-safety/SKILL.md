---
name: branch-safety
description: "Always-on branch safety rules: never commit or push directly to main/master, create feature branches with rh/ prefix"
---

# Branch Safety

## Rules

### Never commit or push directly to main or master

Before any commit or push operation, check the current branch. If on `main` or `master`, create a new feature branch first.

```
# Good
git switch -c rh/add-user-auth
git commit -m "feat(auth): add user authentication"

# Bad
git commit -m "feat(auth): add user authentication"  # while on main
git push origin main  # pushing directly to main
```

### Use `rh/` prefix for new branch names

When creating a branch, use the `rh/` prefix followed by a short, descriptive kebab-case name.

```
# Good
rh/add-user-auth
rh/fix-login-redirect
rh/refactor-api-client

# Bad
feature/add-user-auth
add-user-auth
my-branch
```

### When in doubt, ask the user

If unsure whether to create a new branch or which name to use, ask the user before proceeding. Suggest a default name based on the changes with `rh/` prefix.
