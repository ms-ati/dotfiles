# dotfiles
Dotfiles for Github Codespaces

## Usage

Follow [these instructions](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles)
to configure a Codespace to use this repository for dotfiles.

Then, when a codespace is created, it will clone this `dotfiles` repo and run
`install.sh`, which will install these settings in the codespace.

## Contents

### Bash config

Symlinked into your home directory `~`:

- `.bash_aliases` — Set bash shell aliases here
- `.bash_profile` — Configure bash shell environment here

### Windsurf IDE config

Symlinked into `/home/codespace/.windsurf-server/data/Machine`:

- `windsurf/Machine/settings.json` — Remote settings for Windsurf
