#!/bin/bash
##############################################################################
# Completion System - Tab completion setup
##############################################################################

# Only load for interactive shells
[[ $- != *i* ]] && return

# Initialize bash completion
if [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
fi

# Vi mode (redundant if already set in options.sh, but harmless)
set -o vi

# Kubernetes completion
if command -v kubectl &>/dev/null; then
    source <(kubectl completion bash)
    alias k=kubectl
    complete -F __start_kubectl k
fi
