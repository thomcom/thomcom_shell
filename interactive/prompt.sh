#!/bin/bash
##############################################################################
# Prompt Configuration - Terminal prompt and title
##############################################################################

# Only load for interactive shells
[[ $- != *i* ]] && return

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

# Set the prompt - using Bash format strings
# Bold green user@host, reset, colon, bold blue path, reset, dollar space
PS1='\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]$ '
