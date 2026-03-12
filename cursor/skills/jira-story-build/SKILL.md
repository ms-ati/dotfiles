---
name: jira-story-build
description: Build or continue implementation of a Jira story with re-entrant setup, progress tracking, context loading, and idempotent Jira status updates. Use when starting or resuming story implementation.
---

# Build Jira Story

Build or continue implementation of a Jira story by detecting current state, running only
needed setup, orienting to next tasks, and keeping progress easy to resume.

## Steps

### 1. Read the Issue

**Use the `jira-issue-load` skill** to get the issue into context. It handles server detection,
`cloudId`, resolving issue key (user-provided, git branch, or ask), and fetching full
description. Retain `cloudId` and server name for later Jira calls.

If the issue cannot be found or the Atlassian MCP is unavailable, inform the user and stop.

### 2. Validate Plan Exists

Check the issue description for a structured plan with:
- **Goals / Problems to Solve**
- **High-level Solution**
- **Acceptance Criteria / Definition of Done**
- **Task Breakdown**

If missing or incomplete:
- **STOP** and inform the user
- Suggest: "This issue doesn't have a structured plan. Run the `jira-story-plan` skill first."
- Do not proceed until the issue is planned

### 3. Detect Mode (`start` vs `resume`)

Classify the run mode before taking setup actions:

- **Likely `start`**:
  - issue is not yet in progress, or
  - user explicitly says "start", "kick off", or "begin"
- **Likely `resume`**:
  - issue already in progress, or
  - user explicitly says "resume", "continue", "pick up", or "next step"

If ambiguous, ask:
"Should I run in start mode (fresh setup) or resume mode (pick up from current status)?"

### 4. Verify Git Safety

Run `git status --porcelain` and report the current state.

**Start mode**:
- Require clean working directory
- If dirty: **STOP**, list changes, and ask the user to commit/stash/discard

**Resume mode**:
- Do not hard-stop on dirty tree
- Warn and ask for explicit confirmation before continuing

### 5. Ensure Branch State

Construct branch name from issue key and summary using project convention:
`IOPZ-123-short-description-with-dashes` (issue key must be at start).

**Start mode**:
1. Ensure default branch (`develop` or `main`) is current
2. Checkout/create issue branch

**Resume mode**:
- If already on matching issue branch, keep it
- If on another branch, ask before switching
- Do not force a default-branch pull unless user asks

If `git pull --ff-only` is required and fails (diverged history), stop and report manual
intervention is needed.

### 6. Summarize Progress and Next Task

Parse checklist state from **Task Breakdown** and summarize:

1. Completed vs pending tasks count
2. First unchecked task as **Next task**
3. Linked blockers (`blocks` / `is blocked by`)
4. Open questions or plan ambiguities

Format:
```
## Ready to Build: IOPZ-1234

**Branch**: `IOPZ-1234-short-description`
**Mode**: resume
**Progress**: 3/9 tasks complete
**Next task**: Step 4 — [task description]

**Blockers**: None
**Open questions**: None
```

### 7. Load Context

Pre-load implementation context:

**A) Explicit file paths**:
- Scan issue description for paths (`src/`, `app/`, `llm-docs/`, `.rb`, `.ts`, etc.)
- Read found files

**B) Documentation**:
- Follow repo/app `llm-docs/index.yml` conventions and load relevant docs

**C) Code search**:
- Search using issue title/description keywords for related code paths

Then ask:
"Does this cover the context you need, or should I explore other areas?"

### 8. Ensure Jira Is In Progress (Idempotent)

Transition to **In Progress** only if needed:

1. Call `getTransitionsForJiraIssue`
2. If current status is not In Progress, call `transitionJiraIssue`
3. If already In Progress, report and continue

### 9. Sync Plan Progress (Optional but Recommended)

Offer to update checklist progress in Jira so future runs can resume cleanly.

Rules:
- Only mark tasks complete/incomplete with explicit user confirmation
- Never infer completion from code changes alone
- Preserve all non-task description content and existing formatting
- If task matching is ambiguous, ask the user to identify task number/title

### 10. Ready to Implement

Provide a concise handoff with mode, branch, progress, next task, blockers, and open
questions. Ask:

"What would you like to tackle first?"

## Additional Resources

- For detailed mode heuristics, scenarios, and edge-case handling, see [reference.md](reference.md)

## Notes

- **Loading the issue**: Step 1 delegates to `jira-issue-load`; use the same server and
  `cloudId` for `getTransitionsForJiraIssue`, `transitionJiraIssue`, and any Jira edits.
- Branch names must start with the Jira key (CI/CD enforces this).
- Related skills:
  - `jira-story-plan` — create/update the structured story plan
  - `jira-label-ensure-ai-planned` — ensure `AI-planned` label on planned issues
