# dotfiles
Dotfiles for Github Codespaces
- Windsurf IDE configuration

## Hints for getting Rubocop working in Windsurf

* Open your remote folder to a specific app (e.g. `/workspaces/monorama/apps/nds`) or
  gem (e.g. `/workspaces/monorama/lib/gems/panorama_ai`) rather than to the monorama root
* Ask for help if you may have manually configured Ruby LSP settings (at the
  User, Remote, or Workspace levels) which may be conflicting with these settings.

## Usage

1. Install the **Ruby LSP** extension in Windsurf
2. Uninstall _any Rubocop_ extensions from Windsurf
3. Exit and restart Windsurf after installing the Windsurf settings below

### Only the Windsurf settings - one codespace

```bash
mkdir -p /home/codespace/.windsurf-server/data/Machine
cd /home/codespace/.windsurf-server/data/Machine
curl -O https://raw.githubusercontent.com/ms-ati/dotfiles/refs/heads/main/windsurf/Machine/settings.json
```

### Manual - one codespace

```bash
cd /workspaces
git clone https://github.com/ms-ati/dotfiles.git
cd dotfiles
bash install.sh
```

### Automatic - all new codespaces

1. Fork this [ms-ati/dotfiles](https://github.com/ms-ati/dotfiles) repo into a public repo that you own
2. Go to [codespaces settings](https://github.com/settings/codespaces) and select your new repo under _Automatically install dotfiles_
3. Now, whenever you create a new codespace it will clone the repo and run `install.sh`

## Contents

### Bash config

Symlinked into your home directory `~`:

- `.bash_aliases` — Set bash shell aliases here
- `.bash_profile` — Configure bash shell environment here

### Windsurf IDE config

Symlinked into `/home/codespace/.windsurf-server/data/Machine`:

- `windsurf/Machine/settings.json` — Remote settings for Windsurf
