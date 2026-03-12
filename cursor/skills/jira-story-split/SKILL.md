---
name: jira-story-split
description: Split a Jira story into multiple peer issues when it becomes too large or complex.
---

# Split Jira Story

Split a Jira story into multiple peer issues when it becomes too large or complex. Migrates
selected tasks from the original issue to new issues while maintaining traceability.

## Steps

### 1. Read the Issue

**Use the `jira-issue-load` skill** to get the issue into context. It handles server detection,
`cloudId`, resolving the issue key (user-provided, git branch, or ask), and fetching the full
description. Retain the `cloudId` and server name for later steps (`createJiraIssue`,
`editJiraIssue`). If the issue cannot be found or the Atlassian MCP is unavailable, inform the
user and stop.

**Validate Plan Exists**: Check that the issue description contains a structured plan with:
- **Goals / Problems to Solve**
- **Task Breakdown** (required for splitting)

If the plan is missing or incomplete:
- **STOP** and inform the user
- Suggest: "This issue doesn't have a structured plan. Run the `jira-story-plan` skill first."
- Do NOT proceed until the issue has been planned

### 2. Load SPIDR Context

Read the file `spidr-story-splitting.md` in the same directory as this skill to understand
splitting techniques.

SPIDR provides five techniques for splitting:
- **S**pike — Extract research/learning as a separate issue
- **P**aths — Split by different user flows
- **I**nterfaces — Split by UI complexity or platform
- **D**ata — Split by data types or formats
- **R**ules — Defer business rules/edge cases to later issues

### 3. Display Plan and Suggest Split

Present the current Task Breakdown to the user, numbered for easy reference:

```
## Current Task Breakdown for IOPZ-123

1. [ ] **Task A**: Description
2. [ ] **Task B**: Description
3. [ ] **Task C**: Description
...
```

Then suggest applicable SPIDR techniques based on the issue content:

```
## Suggested Split Approaches (SPIDR)

Based on your tasks, consider:
- **Paths**: Tasks 1-2 handle the happy path, tasks 3-4 handle error cases
- **Rules**: Task 5 adds validation that could be deferred
```

Ask: "Which tasks would you like to split into a new issue? (e.g., '3, 4, 5' or 'tasks 3-5')"

**STOP**: Wait for user to specify which tasks to migrate.

### 4. Gather New Issue Details

Once the user specifies tasks to migrate:

1. **Propose a title** based on the migrated tasks:
   - Extract common theme from selected tasks
   - Format: Clear, action-oriented title (not "Part 2" or similar)

2. **Ask about context sections**:
   - "Should the new issue inherit the full Goals/Context sections, or should I trim them to
     what's relevant for the migrated tasks?"

3. **Confirm the plan**:
   ```
   ## New Issue Preview

   **Title**: [Proposed title]
   **Tasks to migrate**: 3, 4, 5
   **Context**: [Full / Trimmed]

   Does this look right?
   ```

**STOP**: Wait for user confirmation before creating the issue.

### 5. Create New Issue

Use `createJiraIssue` to create the new issue, using the same `projectKey` and `issueTypeName`
as the original. Pass the plan as markdown in the `description` field.

**Description structure** for the new issue:
```markdown
## Goals / Problems to Solve

[Inherited or trimmed from original]

## Background Context

[Inherited or trimmed from original]
Split from [IOPZ-123] to focus on [specific scope].

## High-level Solution

[Relevant portion or "See original issue for full context"]

## Acceptance Criteria / Definition of Done

- [ ] [Migrated criteria if applicable]

## Task Breakdown

- [ ] **[Migrated Task 1]**: Description
- [ ] **[Migrated Task 2]**: Description
```

Capture the new issue key from the response (e.g., `IOPZ-456`).

**Use the `jira-label-ensure-ai-planned` skill** for the new issue (with its `issueIdOrKey` and
the same `cloudId`/server). If labels aren't in context, get the new issue or pass the key so
the skill can ensure the label.

### 6. Update Original Issue

Use `editJiraIssue` to update the original issue description:

1. **Remove migrated tasks** from the Task Breakdown
2. **Add Related Issues section** (or update if exists):
   ```markdown
   ## Related Issues

   - IOPZ-456: [New issue title] — split from this issue
   ```

Preserve all other content and formatting.

**Use the `jira-label-ensure-ai-planned` skill** for the original issue so it remains tagged.

### 7. Confirm and Suggest Next Steps

Summarize what was done:

```
## Split Complete

**Original issue**: IOPZ-123 — [Title]
- Removed tasks: 3, 4, 5
- Added reference to new issue

**New issue**: IOPZ-456 — [New Title]
- Migrated 3 tasks
- Linked as related to original
```

Suggest next steps:
- "Would you like to run the `jira-story-plan` skill on IOPZ-456 to expand the plan?"
- "Would you like to split more tasks from the original issue?"

## Notes

- **Loading the issue**: Step 1 delegates to the `jira-issue-load` skill for MCP setup and
  `cloudId`; use the same server and `cloudId` for `createJiraIssue` and `editJiraIssue`.
- Issue identifier format: `PROJ-123`
- Related skills:
  - `jira-story-plan` — for planning issues before or after splitting
  - `jira-story-build` — for starting or resuming implementation
  - `jira-label-ensure-ai-planned` — used in this workflow for both new and original issues
- Currently supports splitting to one new issue at a time; run multiple times for bulk splits
