# glab-review

Load and triage unresolved GitLab MR review comments for the current branch.

## Usage

```
/glab-review
```

## What it does

1. Checks that `glab` is installed, authenticated, and the current branch has an open MR
2. Fetches all unresolved comments and categorizes them as **BLOCKING**, **NON-BLOCKING**, or **QUESTIONS**
3. Recommends a prioritized order to address them (blocking first, grouped by file)
4. Walks you through fixing selected comments one by one

## Requirements

- [glab](https://gitlab.com/gitlab-org/cli) CLI installed and authenticated
- Current branch must have an open merge request
