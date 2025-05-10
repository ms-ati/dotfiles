##
# Bash profile to customize Github Codespaces
##

# Start with Codespaces image ~/.profile (which sources ~/.bashrc)
if [ -f ~/.profile ]; then
    . ~/.profile
fi

# Git
git config --global alias.co checkout
