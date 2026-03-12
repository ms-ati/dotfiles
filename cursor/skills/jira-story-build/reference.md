# Jira Story Build User Guide

Use this guide to understand when and how to run `jira-story-build` during day-to-day development.

`jira-story-build` is the implementation companion to `jira-story-plan`:

- `jira-story-plan`: define the plan
- `jira-story-build`: execute and resume the plan

## When to Use It

Use `jira-story-build` when you want help:

- Starting implementation from a planned Jira story
- Resuming a story after interruption or context switching
- Finding the next task from the story checklist
- Loading relevant code/docs before coding
- Keeping Jira status and checklist progress up to date

## What It Does For You

When you run `jira-story-build`, it will typically:

1. Load the Jira issue context
2. Verify the story has a structured plan
3. Determine whether this is a start or resume flow
4. Check git state and branch state with safety prompts
5. Summarize progress and suggest the next task
6. Load relevant repo context (files/docs/search)
7. Ensure Jira is in progress (idempotent)
8. Optionally sync task checkboxes in Jira (with explicit confirmation)

## Start vs Resume

You can invoke naturally; the skill will infer intent and ask if unclear.

### Start flow

Best when beginning implementation for the first time.

Typical behavior:

- Requires clean git working tree
- Sets up or switches to issue branch
- Updates Jira status to In Progress if needed
- Presents next task and ready-to-build summary

### Resume flow

Best when returning to an in-flight story.

Typical behavior:

- Reuses current branch if already correct
- If git tree is dirty, warns and asks for explicit confirmation to continue
- Avoids unnecessary setup repeats
- Re-orients you to next pending task quickly

## Example Prompts

Use direct prompts like these:

- "Run `jira-story-build` for IOPZ-8126."
- "Use `jira-story-build` to start IOPZ-8126."
- "Resume IOPZ-8126 with `jira-story-build`."
- "Use `jira-story-build` and sync completed checklist items in Jira."
- "Run `jira-story-build` and show me blockers and next task only."

## Common Scenarios

### Scenario: Fresh story kickoff

You planned the story and are ready to implement.

Expected outcome:

- Branch setup happens once
- Jira moves to In Progress
- You get a focused next-task handoff

### Scenario: Mid-story continuation

You already worked on the issue and need fast re-orientation.

Expected outcome:

- Skill treats it as resume
- Existing progress is summarized from checklist items
- You can continue from first unchecked task

### Scenario: Dirty working tree

You have uncommitted local changes when resuming.

Expected outcome:

- Skill warns you and asks for explicit confirmation before proceeding
- You can choose to continue, stash, or clean up first

### Scenario: Plan missing or incomplete

Issue lacks required structured sections.

Expected outcome:

- Skill stops early
- You are directed to run `jira-story-plan` first

## Troubleshooting

### "It says plan is missing."

- Run `jira-story-plan` on the issue first.
- Ensure it includes Goals, High-level Solution, Acceptance Criteria, and Task Breakdown.

### "It cannot safely continue because git is dirty."

- Confirm you want to proceed, or
- Commit/stash/discard changes, then re-run.

### "It is on the wrong branch."

- Confirm whether to switch to the issue branch now.
- If unsure, ask for a branch summary before switching.

### "Checklist updates are wrong or ambiguous."

- Ask to update by task number/title explicitly.
- Avoid bulk updates if task wording changed.

### "Status transition failed."

- Check Jira permissions and available transitions.
- Retry once; if still failing, continue implementation and update Jira manually.

## Team Usage Tips

- Treat Jira checklist items as the primary progress source for resumability.
- Keep task descriptions specific so matching is easy later.
- Prefer running `jira-story-build` at the start of each coding session on a story.
- If you changed scope, run `jira-story-plan` first, then return to `jira-story-build`.

## Related Skills

- `jira-story-plan` - create/update structured plan
- `jira-story-build` - start/resume implementation work
- `jira-story-split` - split large stories into smaller issues
