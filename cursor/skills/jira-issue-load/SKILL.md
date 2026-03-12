---
name: jira-issue-load
description: Loads a Jira issue into chat context via Atlassian MCP. Use when the user asks for a Jira issue, wants to load or fetch a ticket, needs issue context for a branch, or mentions an issue key (e.g. IOPZ-8125).
---

# Load Jira Issue

Load a single Jira issue into the conversation so its full text is in context for the rest of the chat.

## MCP configuration

The user may be using either the **Atlassian plugin** or a **user-configured Atlassian MCP server**. Cursor exposes the former as `Atlassian` and the latter as `user-Atlassian`. Detect which is active before making Jira calls.

- **Detect active server**: Call `getAccessibleAtlassianResources` with `{}` on `user-Atlassian`. If you get "MCP server does not exist", try `Atlassian`. Use whichever server returns a list of resources (sites with Jira scopes).
- **cloudId**: From the successful response, take the `id` of the entry that has Jira scopes (e.g. `read:jira-work`). Use this `cloudId` for all subsequent Jira tool calls on the same server.
- **If neither works**: Show the user the **Re-authentication** steps below (do not invent different wording).

## Re-authentication (when Jira / Atlassian MCP isn't working)

Use this exact checklist whenever the user hits auth errors or "MCP server does not exist" for Atlassian.

1. **Sign out from Atlassian** in Cursor (Settings → MCP or Extensions → find Atlassian → sign out / disconnect).
2. **Quit Cursor completely** (fully quit the app, not just close the window).
3. **Reopen Cursor**, then **sign in to Atlassian** when prompted (or from the same place you signed out).
4. **Try the Jira request again.** If it still fails, **quit Cursor once more and reopen** — the MCP often only connects after a second restart.

Reassure the user that the double-restart is a known quirk, not something they did wrong.

## Steps

1. **Get server and cloudId**: Call `getAccessibleAtlassianResources` with `{}` on `user-Atlassian`. If that fails with "MCP server does not exist", try `Atlassian`. From the successful response, take the `id` of the entry that has Jira scopes. This is your `cloudId`; remember which server name worked. If both attempts fail, show the **Re-authentication** checklist above and stop.
2. **Resolve issue key**: Use the issue key the user gave. If none was given, check the current git branch name for a pattern like `PROJ-1234` or `IOPZ-8125` and use that. If still unknown, ask the user for the issue key.
3. **Fetch the issue**: Call `getJiraIssue` on the same server you used in step 1, with:
   - `cloudId`: from step 1
   - `issueIdOrKey`: the issue key (e.g. `"IOPZ-8125"`)
   - `expand`: `"names,renderedFields"`
4. **Surface the issue**: Present a short **header** (key, summary, type, status, assignee, link: `https://panoramaed.atlassian.net/browse/<KEY>`), then **include the full description text** in your response. Do not summarize or truncate — Cursor works best with the complete text in context.
   - **Screenshots and attachments**: If the issue has attachments (`fields.attachment`) or the description references images, prefer pulling image attachments into context via any MCP tool that fetches attachment content. For other files, list filename and link. If the MCP has no attachment API or fetch fails, list attachment filenames and add: *"Open the issue link above to view attachments in Jira."*

## Optional: related issues

If the user needs linked or related issues, use `searchJiraIssuesUsingJql` on the same server with the same `cloudId` and a JQL query (e.g. `parent = IOPZ-8125` for sub-tasks). Fetch each with `getJiraIssue` and surface each with a brief header plus full description text.

## Output

- Header: brief (key, type, status, assignee, link). Description: **always the full text** — no summarization.
- For auth or "server does not exist" errors, show the **Re-authentication** checklist and mention that the second restart is a known quirk.
