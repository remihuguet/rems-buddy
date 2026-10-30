# issue-workflow

The GitLab-issue-driven development loop, on `libracyber/simcore/delivery` (`code.libracyber.com`).

## Skills

- `/issue <work item url|libracyber/simcore/delivery#N|N>` — analyze → plan → post the plan on the issue → implement → open MR → close the loop. `disable-model-invocation: true`.
- **gitlab-issue-sync** — loaded automatically when work originates from a delivery issue: plan as a comment before implementing, update at milestones, link the MR

## Requirements

- `glab` logged in to `code.libracyber.com`. Delivery issues are `SimCore Issue` work items, which `glab issue` cannot see, so the skills go through `glab api graphql`
- The `simcore` plugin (`simcore-agent` marketplace) for `/simcore:create-merge-request`, paired with the `git-workflows` plugin
