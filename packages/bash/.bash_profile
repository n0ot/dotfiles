. "$HOME/.bash_helpers/path_functions.sh"
prepend_to_path "$HOME/bin"
prepend_to_path "$HOME/.local/bin"

if [ -f "/opt/homebrew/bin/brew" ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if hash brew 2>/dev/null; then
	prepend_to_path "$(brew --prefix)/opt/sqlite/bin"
fi

# All machine-local changes go in .bash_profile.local, and will not be tracked
# in this dotfiles repo.
[[ -r "$HOME/.bash_profile.local" ]] && . "$HOME/.bash_profile.local"

# I still want .bashrc, even for login shells.
[[ -r "$HOME/.bashrc" ]] && . "$HOME/.bashrc"

# Remove duplicate entries in $PATH
PATH="$(echo -n "$PATH" | awk -v RS=: '!($0 in components) { components[$0]; print }' | paste -d: -s -)"
export PATH

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
