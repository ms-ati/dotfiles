---
name: plan-jira-story
description: Read a Jira issue with goals, solution, acceptance criteria, and tasks
---

# Plan Jira Story

Plan and document a Jira story with goals, context, solution approach, acceptance criteria,
implementation phases, and task breakdown.

## Steps

### 1. Read the Issue

First, obtain the Jira issue ID:
1. If the user specified an issue ID like `IOPZ-7597`, then use it.
2. If already on a git feature branch, it may start with the issue ID, like `IOPZ-7597-spike-initial-cursor-jira-mcp`
3. We can ask the user for the issue ID if we are not sure
  - Or ask to search issues assigned to them for a subject to find the ID

Before fetching the issue, call `getAccessibleAtlassianResources` to get the `cloudId` needed
for all subsequent Jira tool calls.

Once we have the issue ID and `cloudId`, fetch details using `getJiraIssue`
with `expand: "names,renderedFields"` to get full context. To get linked/related issues,
also fetch each linked issue key using `getJiraIssue` individually.

If no issue identifier is provided, ask the user for one before proceeding.
If the issue cannot be found or the Atlassian MCP is unavailable, inform the user and stop.

**Update Mode**: If the issue already has a structured plan in the description:
- Summarize the existing plan sections
- Ask: "This issue already has a plan. What would you like to update?"
  - Refine specific sections?
  - Add new information?
  - Complete revision?
- Tailor subsequent steps based on the update intent

### 2. Research Issue Context

Before asking questions, read the issue, and any related issues, epics, or sprints.

To search for related issues use `searchJiraIssuesUsingJql` with a relevant JQL query,
e.g. `project = PROJ AND issueType = Epic AND status != Done`.

### 3. Research Codebase Context

Before asking questions, research the codebase to understand existing patterns:

- Follow the project's documentation conventions (e.g. `llm-docs/index.yml` at the repo
  and app level) to find relevant architecture, patterns, and domain context
- Search for existing implementations related to the issue
- Note any constraints or patterns that should inform the solution

### 4. Understand & Clarify

Review the issue and ask clarifying questions to understand:

- **Goals**: What are we trying to achieve? What problem are we solving?
- **Constraints**: Are there technical, timeline, or resource constraints?
- **Scope**: What's in scope vs explicitly out of scope?
- **Dependencies**: Are there blocking issues or dependencies on other work?
- **Solution Options**: If multiple approaches exist, discuss tradeoffs

Ask questions one batch at a time. Wait for user responses before proceeding.

**STOP**: Do NOT proceed to the next step until the user confirms they're ready to draft the plan.

### 5. Draft the Plan

**New Plan**: Create a comprehensive plan in markdown format with these sections.

**Update Mode**: Revise only the sections the user wants to change, preserving the rest.
Show a diff-style summary of what changed.

Plan sections:

```markdown
## Goals / Problems to Solve

[Clear, bulleted list of what we're trying to achieve]

## Background Context

[Relevant context that helps understand why this work matters and any prior decisions]

## High-level Solution

[Summary of the chosen approach and why it was selected]

For complex issues, consider splitting into:
- **High-level Solution**: The "what" and "why" - conceptual approach, key decisions
- **Technical Implementation Plan**: The "how" - specific technologies, patterns, file structures

## Diagram (Optional)

Consider adding a diagram if it helps clarify the solution. Use Mermaid syntax for complex
diagrams, or ASCII for very simple ones.

    ```mermaid
    flowchart LR
        A[Input] --> B[Process] --> C[Output]
    ```

## Acceptance Criteria / Definition of Done

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [etc.]

## Phases of Implementation

### Phase 1: [Name]
[Description of what this phase accomplishes]

### Phase 2: [Name]
[etc.]

## Task Breakdown

Where appropriate, prefer TDD: write tests before implementation.

- [ ] **[Task 1]**: [Brief description]
- [ ] **[Task 2]**: [Brief description]
- [ ] [etc.]

## Out of Scope (Optional)

- [Item explicitly not being addressed]
  - [Reason or future consideration]

## Related Issues (Optional)

- [PROJ-XXXX]: [Title] - [Relationship description]

```

Present the draft to the user for review.

### 6. Iterate on the Plan

Incorporate user feedback and refine the plan. Continue iterating until the user approves.

Ask: "Does this plan look good? Would you like any changes before we update the Jira issue?"

**STOP**: Wait for user approval before proceeding to update Jira.

### 7. Update Jira Issue

Once the user approves the plan, update the Jira issue description with the new plan content
using the `editJiraIssue` tool. Pass `cloudId`, `issueIdOrKey`, and `fields: { description: <markdown> }`.

**Update Mode**: When updating an existing plan:
- Merge changes with existing content
- Preserve sections the user didn't want to change
- Keep completed task checkboxes intact unless explicitly asked to reset

After updating, confirm success and provide a summary of what was updated.

### 8. Handle Related Issues (Optional)

If there are related issues to link or create:

- Use `searchJiraIssuesUsingJql` to find existing candidates to link
- Use `createJiraIssue` if new sub-tasks or follow-up issues should be created
  - Required fields: `cloudId`, `projectKey`, `issueTypeName`, `summary`
  - Pass `parent` to create a sub-task under the current issue
- Ask user before creating any new issues

## Notes

- This workflow uses the Atlassian MCP plugin (server name: `atlassian`)
- All Jira tools require a `cloudId` — always call `getAccessibleAtlassianResources` first
- Issue identifier formats: `PROJ-1234`
- The plan structure can be adapted based on the issue type and complexity
