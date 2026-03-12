---
name: jira-story-start
description: Start implementation of a Jira story by validating the plan, setting up git, loading context, and updating Jira status.
---

# Start Jira Story

Start implementation of a Jira story by validating the plan, setting up git, loading context,
and updating Jira status.

## Steps

### 1. Read the Issue

**Use the `jira-issue-load` skill** to get the issue into context. It handles server detection,
`cloudId`, resolving the issue key (user-provided, git branch, or ask), and fetching the full
description. Retain the `cloudId` and server name for later steps (`getTransitionsForJiraIssue`,
`transitionJiraIssue`). If the issue cannot be found or the Atlassian MCP is unavailable, inform
the user and stop.

### 2. Validate Plan Exists

Check that the issue description contains a structured plan with these sections:
- **Goals / Problems to Solve** — what we're solving
- **High-level Solution** — how we're solving it
- **Acceptance Criteria / Definition of Done** — how we know we're done
- **Task Breakdown** — what steps to take

If the plan is missing or incomplete:
- **STOP** and inform the user
- Suggest: "This issue doesn't have a structured plan. Run the `jira-story-plan` skill first."
  (Use the actual issue identifier, e.g., `IOPZ-7597`)
- Do NOT proceed until the issue has been planned

### 3. Verify Clean Git State

Run `git status --porcelain` to check for uncommitted changes.

If the working directory is **not clean**:
- **STOP** and list the uncommitted changes
- Ask the user to commit, stash, or discard changes before proceeding
- Do NOT proceed with a dirty working directory

### 4. Update Main Branch

Ensure the local default branch (`develop` or `main`) is up-to-date:

```bash
git checkout develop   # or main if there is no develop
git pull --ff-only origin develop
```

If `git pull --ff-only` fails (diverged history):
- **STOP** and inform the user
- Explain that manual intervention is needed to resolve the divergence
- Do NOT proceed

### 5. Handle Feature Branch

Construct the branch name from the issue key and a short slug of the summary, following the
project convention: `IOPZ-123-short-description-with-dashes`. The issue key **must** be at the
start of the branch name (CI/CD enforces this).

If already on the correct branch, skip checkout. Otherwise:

1. Try `git checkout <branch-name>` (works if branch exists locally or remotely)
2. If that fails, create it: `git checkout -b <branch-name>`

### 6. Summarize Status and Next Tasks

Present a concise summary to orient the user:

1. **Current state**: Which tasks are completed (checked) vs pending (unchecked)
2. **Next task**: The first unchecked task from the Task Breakdown
3. **Blockers**: Linked issues marked as "blocks" or "is blocked by"
4. **Open questions**: Ambiguities in the plan that need clarification before proceeding

Format example:
```
## Ready to Implement: IOPZ-1234

**Branch**: `IOPZ-1234-short-description`
**Progress**: 2/8 tasks complete
**Next task**: Step 3 — [task description]

**Blockers**: None
**Open questions**: None
```

### 7. Load Context

Pre-load relevant context for implementation:

**A) Explicit file paths**: Search the issue description for file paths (e.g., paths containing
`src/`, `app/`, `llm-docs/`, or file extensions like `.md`, `.ts`, `.rb`).
Read any found files.

**B) Documentation**: Follow the project's `llm-docs/index.yml` conventions at the repo and
app level to load relevant architecture, patterns, and domain context.

**C) Code search**: Search the codebase using key terms from the issue title and description
to find related code.

Present what was found and ask: "Does this cover the context you need, or should I explore
other areas?"

### 8. Update Jira Status

Transition the issue to "In Progress":

1. Call `getTransitionsForJiraIssue` to get available transitions and find the "In Progress" transition ID.
2. Call `transitionJiraIssue` with `cloudId`, `issueIdOrKey`, and `transition: { id: "<id>" }`.

Confirm the status update to the user.

### 9. Ready to Implement

Context is loaded and Jira is updated. Ask:

"What would you like to tackle first?"

## Notes

- **Loading the issue**: Step 1 delegates to the `jira-issue-load` skill for MCP setup and
  `cloudId`; use the same server and `cloudId` for `getTransitionsForJiraIssue` and
  `transitionJiraIssue`.
- Issue identifier format: `PROJ-1234`
- Branch names must start with the Jira issue key (CI/CD enforces this)
- Related skills: `jira-story-plan` skill for planning issues before starting
