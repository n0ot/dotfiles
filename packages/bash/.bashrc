# shellcheck shell=bash
# .bashrc is sourced by interactive, non login shells.  If bash is invoked by a
# remote shell, .bashrc will be included, even when the shell is non
# interactive.  This can break scp and other utilities.  See
# https://unix.stackexchange.com/questions/257571/why-does-bashrc-check-whether-the-current-shell-is-interactive.
# Don't run for non interactive shells
[[ $- == *i* ]] || return

# Prompt
. "$HOME/.bash_helpers/git-prompt.sh"
prompt_command() {
    local exit=$?
    local GIT_PS1_SHOWDIRTYSTATE=yes
    local GIT_PS1_SHOWSTASHSTATE=yes
    local GIT_PS1_SHOWUNTRACKEDFILES=yes
    local GIT_PS1_SHOWUPSTREAM=auto
    local GIT_PS1_SHOWCONFLICTSTATE=yes

    local host=''
    [[ -n $SSH_CLIENT || -n $SSH_TTY ]] && host='@\h'
    local precmd="\\u${host}:\\W"
    local postcmd='\$ '
    [[ $exit -ne 0 ]] && postcmd=" ($exit)$postcmd"

    __git_ps1 "$precmd" "$postcmd"
}
PROMPT_COMMAND=prompt_command

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

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
    # shellcheck disable=SC1091 # sourced file may or may not exist
    [[ -r "$BREW_PREFIX/etc/profile.d/bash_completion.sh" ]] && . "$BREW_PREFIX/etc/profile.d/bash_completion.sh"
fi

# Add fzf bindings, and set its default find utility to fd, if possible.
if hash fzf 2>/dev/null; then
    eval "$(fzf --bash)"
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

# All machine-local changes go in .bashrc.local, and will not be tracked
# in this dotfiles repo.
# shellcheck disable=SC1091 # sourced file may or may not exist
[[ -r "$HOME/.bashrc.local" ]] && . "$HOME/.bashrc.local"

# Allow switching between emacs and vi editing modes
# Idealy this should be in .inputrc,
# but switching to vi mode, adding vi-bindings, and switching back to emacs mode doesn't seem to work.
bind '"\ee": vi-editing-mode'
bind -m vi '"\ee": emacs-editing-mode'

# Load Ghostty's shell integration. Ghostty injects this automatically into
# shells it starts directly, but shells started inside tmux need to source it.
if [[ -r ${GHOSTTY_RESOURCES_DIR:-}/shell-integration/bash/ghostty.bash ]]; then
    . "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash"
fi
