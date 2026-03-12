---
name: jira-ensure-label-ai-planned
description: Ensures the label `AI-planned` is set on a Jira issue without removing existing labels. Use when a skill or workflow needs to tag a Jira issue as AI-planned (e.g. after planning or reviewing a story with AI assistance).
---

# Jira: Ensure Label `AI-planned`

Idempotently adds the `AI-planned` label to a Jira issue, preserving all existing labels.

## Prerequisites

You need `cloudId`, `issueIdOrKey`, and the Atlassian MCP server name in context. These are
typically available from a prior `load-jira-issue` skill call. If not, run that skill first.

## Steps

1. **Get current labels**: If the issue's `fields.labels` array is already in context (from
   `getJiraIssue`), use it. Otherwise call `getJiraIssue` with `cloudId` and `issueIdOrKey`
   and read `fields.labels` from the response.

2. **Check if already set**: If `"AI-planned"` is already in the labels array, skip to step 4.

3. **Update labels**: Call `editJiraIssue` on the same server with:
   - `cloudId`: from context
   - `issueIdOrKey`: from context
   - `fields: { labels: [...existingLabels, "AI-planned"] }`

   Jira replaces the entire labels array on edit — always include all existing labels.

4. **Confirm**: Report whether the label was added or was already present.
