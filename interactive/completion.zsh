#!/bin/zsh
##############################################################################
# Completion System - Tab completion setup
##############################################################################

# Only load for interactive shells
[[ ! -o interactive ]] && return

# Initialize Zsh completion system
zstyle :compinstall filename '/home/tcomer/.zshrc'
autoload -Uz compinit
compinit

# Vi mode bindings
bindkey -v

# Kubernetes completion
if command -v kubectl &>/dev/null; then
    source <(kubectl completion zsh)
    alias k=kubectl
    compdef _kubectl k
fi