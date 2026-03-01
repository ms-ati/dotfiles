# Dotfiles for Cursor IDE in GitHub Codespaces

This repo serves two purposes:

1. **Personal customization** — your shell, editor settings, and extensions applied automatically to every new Codespace.
2. **Tooling experimentation** — a personal sandbox for building and testing Cursor AI tooling (skills, commands, agents, MCP servers) before promoting stable pieces to shared repos like `monorama` for the whole engineering team.

## Setup

### Automatic (all new codespaces)

1. Ensure this repo is in your GitHub account and [enable dotfiles for Codespaces](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles): **Settings → Codespaces → Dotfiles** → enable **Automatically install dotfiles** and select this repository.
2. New codespaces will clone the repo and run `install.sh` automatically.

### Manual (existing codespace or re-run)

```bash
cd /workspaces/.codespaces/.persistedshare/dotfiles
git pull
bash install.sh
```

Each script in `scripts/` can also be run standalone:

```bash
bash scripts/install-cursor-tools.sh
```

### After first open in Cursor

- **Atlassian:** Install the [Atlassian plugin](https://cursor.com/marketplace/atlassian) from Cursor (Settings → Plugins / Marketplace). The dotfiles already write the Atlassian MCP entry to `~/.cursor/mcp.json`; complete the OAuth sign-in when Cursor prompts you.

## Repo layout

### Personal customization

| Path | What it does |
| ---- | ------------ |
| `.bash_aliases` | Shell aliases (injected into `~/.bash_aliases` via marker block) |
| `.bash_profile` | Shell profile — sources `~/.profile`, sets git aliases (injected into `~/.bash_profile`) |
| `cursor/Machine/settings.json` | Cursor remote (Machine) settings: Ruby LSP, file trimming. Symlinked into `~/.cursor-server/data/Machine/`. |
| `cursor/extensions.txt` | Extension IDs to install (one per line). Installed via `code`, then copied to Cursor's extensions dir. |
| `cursor/mcp.json` | MCP server definitions. Merged into `~/.cursor/mcp.json` — repo keys win on conflicts, local-only servers are preserved. |

### Tooling experimentation

| Path | What it does |
| ---- | ------------ |
| `cursor/skills/` | [Agent Skills](https://cursor.com/docs/context/skills) — each subfolder is one skill. Individual subfolders are symlinked into `~/.cursor/skills/`. Experiment here; promote to `monorama/.cursor/skills/` when ready. |
| `cursor/commands/` | [Global commands](https://cursor.com/docs/context/commands) — individual subfolders symlinked into `~/.cursor/commands/`. Slash commands available in every project. |
| `cursor/agents/` | [User subagents](https://cursor.com/docs/context/subagents) — individual subfolders symlinked into `~/.cursor/agents/`. |

## How install.sh works

`install.sh` sources a shared library (`scripts/_lib.sh`) then calls six focused scripts in order. Every operation is idempotent — safe to re-run at any time.

### Idempotency rules

| Mechanism | Used for | Behavior |
| --------- | -------- | -------- |
| **Marker blocks** | Shell dotfiles, `.bashrc` | Content is fenced with `# BEGIN id` / `# END id`. Block is inserted on first run, replaced on re-run. Lines outside the markers are never touched. |
| **Individual symlinks** | Cursor settings, skills, commands, agents | Each item is linked only if the destination does not already exist. Pre-existing items (from other sources) are never removed or overwritten. |
| **MCP merge** | `~/.cursor/mcp.json` | On re-run: local file is merged with repo using `jq`. Repo keys win on conflicts; local-only servers are preserved. |

### Log output

Every operation prints one line:

```
[dotfiles] SCRIPT_NAME  VERB      TARGET
```

Verbs: `created`, `updated`, `appended`, `linked`, `merged`, `copied`, `install`, `skip`, `WARN`.

Example first run:

```
[dotfiles] dotfiles           start     running install...
[dotfiles] shell-dotfiles     created   /home/codespace/.bash_aliases (marker block: dotfiles-bash_aliases)
[dotfiles] shell-dotfiles     created   /home/codespace/.bash_profile (marker block: dotfiles-bash_profile)
[dotfiles] cursor-settings    created   /home/codespace/.cursor-server/data/Machine/
[dotfiles] cursor-settings    linked    /home/codespace/.cursor-server/data/Machine/settings.json
[dotfiles] cursor-tools       created   /home/codespace/.cursor/skills/
[dotfiles] cursor-tools       linked    /home/codespace/.cursor/skills/update-dotfiles
[dotfiles] cursor-tools       created   /home/codespace/.cursor/commands/
[dotfiles] cursor-tools       created   /home/codespace/.cursor/agents/
[dotfiles] mcp                created   /home/codespace/.cursor/
[dotfiles] mcp                copied    /home/codespace/.cursor/mcp.json
[dotfiles] extensions         install   Shopify.ruby-lsp
[dotfiles] extensions         copied    Shopify.ruby-lsp-... -> cursor-server
[dotfiles] extensions         install   TakumiI.markdowntable
[dotfiles] extensions         copied    TakumiI.markdowntable-... -> cursor-server
[dotfiles] git-editor         created   /home/codespace/.bashrc (marker block: cursor-git-editor)
[dotfiles] dotfiles           done
```

`WARN` means a destination exists in an unexpected state (not the right symlink, not a file we created). The script skips it and tells you to fix it manually.

## Adding things

### Shell aliases or profile changes

Edit `.bash_aliases` or `.bash_profile` in the repo. On next `install.sh` run the marker block in your home file is replaced with the new content. Your personal lines outside the markers are untouched.

### Cursor settings

Edit `cursor/Machine/settings.json`. The symlink means changes take effect immediately (no re-run needed after editing).

### MCP servers

Edit `cursor/mcp.json` — add a key under `mcpServers`. Push; run `install.sh` and the new server is merged in.

```json
{
  "mcpServers": {
    "Atlassian": { "url": "https://mcp.atlassian.com/v1/mcp", "headers": {} },
    "my-new-server": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-foo"] }
  }
}
```

### Extensions

Add an extension ID (one per line) to `cursor/extensions.txt`. Push; run `install.sh`. The extension is installed and copied to Cursor.

### Skills, commands, agents

Create a subfolder under `cursor/skills/`, `cursor/commands/`, or `cursor/agents/` with a `SKILL.md` (or `.md` for commands/agents). Push; run `install.sh` and the subfolder is symlinked into Cursor.

## Promoting experiments to shared repos

When a skill, command, or MCP server is stable and useful for the whole team:

1. Copy the subfolder (or config entry) into the relevant shared repo, e.g. `monorama/apps/nds/.cursor/skills/`.
2. Open a PR there following the standard workflow.
3. Once merged, the tool is available to everyone in that repo.
4. Optionally remove it from your personal dotfiles once the shared version is live.

## Notes

### Ruby LSP / Rubocop

`cursor/Machine/settings.json` points Ruby LSP at the monorama LSP Gemfile (`rubyLsp.bundleGemfile`). Open the folder to the app or gem you care about (e.g. `apps/nds` or `lib/gems/some-gem`) rather than the monorepo root for correct Rubocop scope.

### Extensions: VS Code vs Cursor

`install.sh` uses `code` (VS Code CLI) to install extensions because it is available when dotfiles run, before Cursor has connected. It then copies the installed extension directories from `~/.vscode-server/extensions` into `~/.cursor-server/extensions`. If you open a codespace in Cursor and extensions are missing (e.g. dotfiles ran before the first Cursor connection), re-run `bash install.sh`.

### User-level Cursor rules

User-level rules in `~/.cursor/rules` are [not applied by Cursor today](https://forum.cursor.com/t/rules-in-home-folder-cursor-rules-are-not-applied/147236). Use project rules (`.cursor/rules/` in each repo) or Cursor Settings → Rules instead.
