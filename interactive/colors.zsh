#!/bin/zsh
##############################################################################
# Color Configuration - Directory colors and colored command output
##############################################################################

# Only load for interactive shells
[[ ! -o interactive ]] && return

# Enable colored ls and grep
if command -v dircolors &>/dev/null; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# For less-friendly input
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"