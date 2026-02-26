# Dotfiles for Cursor IDE in GitHub Codespaces

Personal config for new Codespaces: Cursor remote settings, MCP servers (e.g. Atlassian), extensions, and shell.

## Contents

| Path                             | Purpose                                                                                                                               |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `install.sh`                     | Entrypoint run by Codespaces; symlinks files, merges MCP config, installs extensions, sets `GIT_EDITOR`.                              |
| `.bash_profile`, `.bash_aliases` | Shell env and aliases (symlinked to `~`).                                                                                             |
| `cursor/Machine/settings.json`   | Cursor remote (Machine) settings — Ruby LSP, editor defaults (symlinked into `~/.cursor-server/data/Machine`).                        |
| `cursor/mcp.json`                | MCP server definitions (e.g. Atlassian). Merged into `~/.cursor/mcp.json` so repo is source of truth but local-only servers are kept. |
| `cursor/extensions.txt`          | Extension IDs (one per line); installed with `code`, then copied into Cursor’s extensions dir when present.                               |

## Design choices

- **Extensions:** “At least these” — we only *install* from the list; we don’t uninstall other extensions. So you get Ruby LSP (and any others you add) without removing preinstalled or other tools.
- **Extension format:** In the repo it’s a text file (`cursor/extensions.txt`). The script always uses `code` to install (so it works at dotfiles-run time when only the VS Code server may exist). It then copies those extensions from `~/.vscode-server/extensions` into `~/.cursor-server/extensions` when both dirs exist, so Cursor gets the same set. If you open the codespace in Cursor and don’t see them (e.g. dotfiles ran before first Cursor connection), run `bash install.sh` again to copy into Cursor.
- **MCP merge:** When `~/.cursor/mcp.json` already exists, we merge: repo-defined servers are applied/updated, and any servers you added only locally are preserved (using `jq`).

## Usage

### Automatic (all new codespaces)

1. Ensure this repo is in your GitHub account and [enable dotfiles for Codespaces](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles): **Settings → Codespaces → Dotfiles** → enable **Automatically install dotfiles** and select this repository.
2. New codespaces will clone the repo and run `install.sh`.

### Manual (one codespace)

```bash
cd /workspaces
git clone https://github.com/ms-ati/dotfiles.git
cd dotfiles
bash install.sh
```

### After first open in Cursor

- **Atlassian:** Install the [Atlassian plugin](https://cursor.com/marketplace/atlassian) from Cursor (Settings → Plugins / Marketplace) if you want the full plugin UI and skills. The dotfiles already add the Atlassian MCP entry to `~/.cursor/mcp.json`, so MCP is configured; complete the OAuth sign-in when Cursor prompts you (e.g. first use of Jira/Confluence tools).

## Adding more MCP servers

Edit `cursor/mcp.json`: add a new key under `mcpServers` with the server’s config (e.g. `"url": "..."` or `"command"` / `"args"`). Push; new codespaces and re-runs of `install.sh` will merge it in. Example:

```json
{
  "mcpServers": {
    "Atlassian": { "url": "https://mcp.atlassian.com/v1/mcp", "headers": {} },
    "my-other-mcp": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-foo"], "env": {} }
  }
}
```

## Ruby LSP / Rubocop

- Remote settings point Ruby LSP at the monorama LSP Gemfile (`rubyLsp.bundleGemfile`). Open the folder to the app or gem you care about (e.g. `apps/nds` or a gem under `lib/gems/`) rather than the monorepo root if you want correct Rubocop scope.
- Don’t install extra Rubocop extensions; Ruby LSP includes the Rubocop integration.
