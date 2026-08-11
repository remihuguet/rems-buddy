---
name: conventional-commits
description: Commit message rules for this user's repos — the allowed type list, subject format, and length limit. Use when writing, amending, or reviewing any commit message.
---

# Commit messages

`<type>(<scope>): <description>`

- Types, and only these: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `ci`
- Description: lowercase, imperative mood, no trailing period
- Subject line under 72 characters
- Body (after a blank line) only when the *why* isn't evident from the subject
- Breaking changes go in a `BREAKING CHANGE:` footer, never as `(BREAKING)` in the subject

```
feat(auth): add password reset flow          ✔
feat(auth): Added password reset flow        ✘  capitalised, past tense
improvement(auth): better password reset     ✘  not an allowed type
```
