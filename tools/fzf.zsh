#!/bin/zsh
##############################################################################
# FZF (Fuzzy Finder) Integration
##############################################################################

# Load FZF if available
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# FZF custom functions
# Note: FZF_EXCLUDE can be set elsewhere if needed
_fzf_compgen_path() { fd --follow $FZF_EXCLUDE . "$1"; }
_fzf_compgen_dir()  { fd --type d --follow $FZF_EXCLUDE . "$1"; }