---
name: glab-review
description: Load and triage unresolved GitLab MR review comments for the current branch. Use when reviewing a merge request, addressing reviewer feedback, or checking what still needs to be fixed.
disable-model-invocation: true
allowed-tools: Bash(glab *)
---

# GitLab MR Review

## Step 1 — Check prerequisites

The following environment checks are pre-injected. If any command returned an error, stop and inform the user of what is missing before continuing.

- `glab` version: !`glab --version 2>&1`
- GitLab auth: !`glab auth status 2>&1`
- Open MR: !`glab mr view >/dev/null && echo "current branch has an open MR" 2>&1`

## Step 2 — Fetch and summarize comments via sub-agent

Spawn a sub-agent with the following task:

> 1. Run `glab mr view --output json` to extract the MR `iid`, the project `id` (numeric), and the project full path (for display only).
> 2. Run `glab mr note list --state unresolved -F json` to get all unresolved discussions with their note IDs.
> 3. Organize comments into three categories:
>    - **BLOCKING** — reviewer requested changes (look for "request changes", "must", "needs to", "blocking")
>    - **NON-BLOCKING** — suggestions or nits (look for "nit", "suggestion", "optional", "consider")
>    - **QUESTIONS** — open questions that need a reply before code changes
>
> Return only this format — one line per comment, no raw content:
>
> ```
> MR !<iid> — <title>  (project: <full_path>, id: <project_id>)
> <N> unresolved comments
>
> BLOCKING
> 1. [note:<note_id>] `path/to/file.ts:42` — <one-line summary> (@author)
>
> NON-BLOCKING
> 2. [note:<note_id>] `path/to/file.ts:10` — <one-line summary> (@author)
>
> QUESTIONS
> 3. [note:<note_id>] <one-line summary> (@author)
> ```
>
> Do not return raw comment bodies. One-line summaries only.
>
> **To retrieve the full conversation for a specific comment later:**
> ```bash
> # By file (high-level)
> glab mr note list --file <path/to/file> --state unresolved
>
> # By note ID (precise)
> glab api projects/<project_id>/merge_requests/<iid>/notes/<note_id>
> ```
> Include both command templates in the returned summary.

Present the summary returned by the sub-agent to the user.

## Step 3 — Recommend and ask what to fix

Based on the summary, provide a prioritized recommendation:

- Suggest starting with blocking comments, grouped by file to minimize context switching
- Flag quick wins: non-blocking comments that are trivial to fix alongside a nearby blocking one
- If there are open questions, highlight them as needing a reply before making code changes

Then ask the user:

> "Which comments would you like to address? I recommend starting with: [top 2–3 blocking items by file].
> You can say **all blocking**, pick items **by number**, or tell me to **skip** any."

## Step 4 — Address selected comments

For each comment the user selects:
1. Retrieve the full conversation using either:
   - `glab mr note list --file <path/to/file> --state unresolved` — all threads on that file
   - `glab api projects/<project_id>/merge_requests/<iid>/notes/<note_id>` — the exact note
2. Read the relevant file
3. Apply the fix
4. Show the change and confirm with the user before moving to the next item
