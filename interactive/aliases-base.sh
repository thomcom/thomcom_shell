#!/bin/bash
##############################################################################
# Base Aliases - Universal command shortcuts (all tiers)
##############################################################################

# Basic file operations
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Sensible du defaults
du() {
    command du -h -d 1 -- "$@"
}

# Find shortcut
ff() { /usr/bin/find . -name "$1"; }

# Exit prevention (use logout to exit)
alias exit="echo Use 'logout' to exit"

# Load custom aliases if available
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
