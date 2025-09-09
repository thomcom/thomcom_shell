#!/bin/zsh
##############################################################################
# Prompt Configuration - Terminal prompt and title
##############################################################################

# Only load for interactive shells
[[ ! -o interactive ]] && return

# Set terminal title according to i3 workspace
echo -ne "\033]0;workspace-$WORKSPACE-session-$SESSION\007"

# Color prompt detection
if [[ "$TERM" == xterm-color || "$TERM" == *-256color ]]; then
    color_prompt=yes
fi

# Force color prompt if requested
if [[ -n "$force_color_prompt" ]]; then
    if command -v tput &>/dev/null && tput setaf 1 &>/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Set the prompt - using Zsh format strings
PS1='%B%F{green}%n@%m%f:%B%F{blue}%~%f%b$ '