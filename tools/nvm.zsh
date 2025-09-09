#!/bin/zsh
##############################################################################
# Node Version Manager (NVM) Integration
##############################################################################

# NVM & Node setup
export NVM_DIR="$HOME/.nvm"

# Load nvm if available
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# Load nvm bash completion if available
[[ -s "$NVM_DIR/zsh_completion" ]] && source "$NVM_DIR/zsh_completion"