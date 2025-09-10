#!/bin/zsh
##############################################################################
# FZF (Fuzzy Finder) Integration
##############################################################################
#
# Supercharges your shell with fuzzy finding capabilities. Most importantly,
# this enables the magical Ctrl+R history search that makes command recall
# lightning-fast and intuitive. No more typing `history | grep` ever again.
#
# Benefits:
# - Ctrl+R: Fuzzy search through your entire command history instantly  
# - Tab completion: Intelligent file and directory completion
# - Works seamlessly with fd for ultra-fast file finding
# - Handles non-interactive environments gracefully (CLAUDECODE compatibility)
# - Smart fallback loading from multiple possible installation locations
#
##############################################################################

# Load FZF if available
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# FZF custom functions
# Note: FZF_EXCLUDE can be set elsewhere if needed
_fzf_compgen_path() { fd --follow $FZF_EXCLUDE . "$1"; }
_fzf_compgen_dir()  { fd --type d --follow $FZF_EXCLUDE . "$1"; }