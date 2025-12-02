# shellcheck shell=bash
# .bashrc is sourced by interactive, non login shells.  If bash is invoked by a
# remote shell, .bashrc will be included, even when the shell is non
# interactive.  This can break scp and other utilities.  See
# https://unix.stackexchange.com/questions/257571/why-does-bashrc-check-whether-the-current-shell-is-interactive.
# Don't run for non interactive shells
[[ $- == *i* ]] || return

# Prompt
. "$HOME/.bash_helpers/git-prompt.sh"
export GIT_PS1_SHOWDIRTYSTATE=yes
export GIT_PS1_SHOWSTASHSTATE=yes
export GIT_PS1_SHOWUNTRACKEDFILES=yes
host=''
if [[ -n $SSH_CLIENT || -n $SSH_TTY ]]; then
	host='@\h'
fi
PROMPT_COMMAND='__git_ps1 "\u${host}:\W" "\\\$ "'

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

if hash gls 2>/dev/null; then
	alias ls='gls --group-directories-first -Fh'
else
	alias ls='ls -Fh'
fi
alias l1="ls -1"
alias la1="l1 -A"

## Set LESSOPEN, so less can read compressed files.
## The pipe in $LESSOPEN means the lessopen.sh script
## should pipe the contents of the file (%s) to standard output,
## instead of saving it to a temporary file.
export LESSOPEN="|$HOME/.bash_helpers/lessopen.sh %s"

# Easily move up directories
..() {
	if [[ -z $1 ]]; then
		cd ..
		return
	fi
	int_re='^[0-9]+'
	if ! [[ $1 =~ $int_re ]]; then
		echo "..: $1 is not a number" 2>&1
		return
	fi
	if [[ $1 -lt 1 ]]; then
		echo "..: You must move up 1 or more directories" 2>&1
		return
	fi

	dst=""
	for ((i = 0; i < "$1"; i++)); do
		dst="$dst../"
	done
	cd "$dst" || return
}

if hash mpv 2>/dev/null; then
	alias mpva="mpv --no-audio-display --no-ytdl --no-video --af=scaletempo=stride=20:overlap=1"
	alias mpvay="mpv --ytdl-format=bestaudio --no-audio-display --no-video --af=scaletempo=stride=20:overlap=1"
fi
if hash mpsyt 2>/dev/null; then
	alias mpsyt="mpsyt --no-textart"
fi

# The last editor installed will become the default editor
if hash edbrowse 2>/dev/null; then
	export EDITOR=edbrowse
	alias e="edbrowse"
fi
if hash vim 2>/dev/null; then
	export EDITOR=vim
fi
if hash nvim 2>/dev/null; then
	export EDITOR=nvim
fi

# Completions
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [[ -f /usr/share/bash-completion/bash_completion ]]; then
		# shellcheck disable=SC1091 # sourced file may or may not exist
		. /usr/share/bash-completion/bash_completion
	elif [[ -f /etc/bash_completion ]]; then
		# shellcheck disable=SC1091 # sourced file may or may not exist
		. /etc/bash_completion
	fi
fi

if hash brew 2>/dev/null; then
	BREW_PREFIX="$(brew --prefix)"
	COMPLETION_DIR="$BREW_PREFIX/etc/bash_completion.d"
	# shellcheck disable=SC1091 # sourced file may or may not exist
	[[ -r "$BREW_PREFIX/etc/bash_completion" ]] && . "$BREW_PREFIX/etc/bash_completion"
fi

if [[ -n $COMPLETION_DIR ]]; then
	hash doctl 2>/dev/null && doctl completion bash >"$COMPLETION_DIR/doctl"
	hash rustup 2>/dev/null && rustup completions bash >"$COMPLETION_DIR/rustup"
fi

# Add fzf bindings, and set its default find utility to fd, if possible.
if [[ -f $HOME/.fzf.bash ]]; then
	# shellcheck disable=SC1091 # sourced file may or may not exist
	. "$HOME/.fzf.bash"
	if hash fd 2>/dev/null; then
		export FZF_DEFAULT_COMMAND="fd -HI -t f -E '.{git,svn,DS_Store}'"
		export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
		export FZF_ALT_C_COMMAND="fd -LHI -t d -E '.{git,svn}'"
	fi

	fzf-git-branches() {
		git branch "$@" |
			grep -v '^\*' |
			cut -c 3- |
			fzf --multi --preview "git log {} --" --preview-window=down,70% \
				--header="git branch"
	}

	git-co() {
		local branches
		mapfile -t branches < <(fzf-git-branches -a)
		if [[ ${#branches[@]} -ne 1 ]]; then
			echo "Exactly one branch must be selected for checkout" >&2
			return 1
		fi
		git checkout "${branches[0]}"
	}

	git-br-del() {
		local branches
		mapfile -t branches < <(fzf-git-branches)
		if [[ ${#branches[@]} -lt 1 ]]; then
			echo "At least one branch must be selected for deletion" >&2
			return 1
		fi
		git branch -df "${branches[0]}"
	}

	alias fzfpf="fzf --preview 'less {}' --bind shift-up:preview-page-up,shift-down:preview-page-down --preview-window=down,70%"
fi

if [[ -f /usr/lib/ssh-keychain.dylib ]]; then
	# # Use the SecureEnclave on Mac to store resident keys.
	# Run sc_auth create-ctk-identity -l <label> -t <bio|none> -k p-256-ne
	# Then Use sc_auth list-ctk-identities to see them,
	# and ssh-add -K to add them to the agent.
	# /usr/sbin/sc_auth is a bash script; see it for more info.
	# This replaces Secretive.
	export SSH_SK_PROVIDER=/usr/lib/ssh-keychain.dylib
fi

# Start an ssh agent, or use one that is already running,
# then add keys if there are none.

add_ssh_keys() {
	local exit_code
	ssh-add -l &>/dev/null
	exit_code=$?
	# 0 = Agent is running, and there are keys; nothing to do
	# # 1 = agent running, but no keys; add them
	# >1 = agent not running, something else wrong; let the caller deal with it
	[[ $exit_code -ne 1 ]] && return $exit_code

	ssh-add || return $?
	[[ -n $SSH_SK_PROVIDER ]] && SSH_ASKPASS=true SSH_ASKPASS_REQUIRE=force ssh-add -Kq || return $?
}

get_ssh_agent() {
	local exit_code
	add_ssh_keys
	exit_code=$?
	[[ $exit_code -ne 2 ]] && return $exit_code

	# No agent is being used. Try to use one that is already running.
	[[ -r ~/.ssh/agent ]] &&
		eval "$(<~/.ssh/agent)" >/dev/null
	add_ssh_keys
	exit_code=$?
	[[ $exit_code -ne 2 ]] && return $exit_code

	# Either ~/.ssh/agent doesn't exist, or the agent it refers to is no longer running.
	# Start a new one and save it's info in ~/.ssh/agent
	(
		umask 066
		ssh-agent >~/.ssh/agent
	)
	eval "$(<~/.ssh/agent)" >/dev/null
	add_ssh_keys || return $?
}

get_ssh_agent

# All machine-local changes go in .bashrc.local, and will not be tracked
# in this dotfiles repo.
# shellcheck disable=SC1091 # sourced file may or may not exist
[[ -r "$HOME/.bashrc.local" ]] && . "$HOME/.bashrc.local"

# Allow switching between emacs and vi editing modes
# Idealy this should be in .inputrc,
# but switching to vi mode, adding vi-bindings, and switching back to emacs mode doesn't seem to work.
bind '"\ee": vi-editing-mode'
bind -m vi '"\ee": emacs-editing-mode'
