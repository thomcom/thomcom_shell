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

# Load FZF if available - respect the trusted ~/.fzf.zsh structure
if command -v fzf >/dev/null 2>&1; then
    # In interactive shells, use the trusted ~/.fzf.zsh
    if [[ -o interactive && -f ~/.fzf.zsh ]]; then
        source ~/.fzf.zsh
    else
        # For non-interactive (like CLAUDECODE), manually source the key parts
        # This preserves the trust legacy of ~/.fzf.zsh while enabling non-interactive use
        if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
            source /usr/share/doc/fzf/examples/completion.zsh 2>/dev/null || true
        fi
        
        # For non-interactive shells, provide basic Ctrl+R functionality
        if [[ -n "$ZSH_VERSION" ]]; then
            # Simple history widget that reads from shared history file
            fzf-history-widget() {
                local selected histfile="${SHARED_HISTFILE:-$HOME/.zsh_history}"
                selected=$(cat "$histfile" 2>/dev/null | fzf --height=40% --reverse --tac --query="$LBUFFER")
                if [[ -n "$selected" ]]; then
                    LBUFFER="$selected"
                fi
                zle reset-prompt
            }
            zle -N fzf-history-widget 2>/dev/null || true
            bindkey '^R' fzf-history-widget 2>/dev/null || true
        fi
    fi
fi

# FZF custom functions
# Note: FZF_EXCLUDE can be set elsewhere if needed
_fzf_compgen_path() { fd --follow $FZF_EXCLUDE . "$1"; }
_fzf_compgen_dir()  { fd --type d --follow $FZF_EXCLUDE . "$1"; }

##############################################################################
# Fallback fzf-history-widget (only if atuin not available)
# When atuin is installed, tools/atuin.zsh provides a better session-aware widget
##############################################################################
if [[ -o interactive ]] && ! command -v atuin >/dev/null 2>&1; then
    fzf-history-widget() {
        local selected histfile="${SHARED_HISTFILE:-$HOME/.zsh_history}"
        setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null
        selected=$(cat "$histfile" 2>/dev/null | awk '!seen[$0]++' | tac |
            FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS-} --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m" $(__fzfcmd))
        local ret=$?
        if [[ -n "$selected" ]]; then
            LBUFFER="$selected"
        fi
        zle reset-prompt
        return $ret
    }
    zle -N fzf-history-widget
fi