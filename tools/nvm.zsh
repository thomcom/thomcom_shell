#!/bin/zsh
##############################################################################
# Node Version Manager (NVM) Integration - Lazy loaded
##############################################################################

export NVM_DIR="$HOME/.nvm"

# Lazy load nvm - only initialize when first needed
_nvm_lazy_load() {
    unset -f nvm node npm npx 2>/dev/null
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/zsh_completion" ]] && source "$NVM_DIR/zsh_completion"
}

nvm()  { _nvm_lazy_load; nvm "$@"; }
node() { _nvm_lazy_load; node "$@"; }
npm()  { _nvm_lazy_load; npm "$@"; }
npx()  { _nvm_lazy_load; npx "$@"; }
