#!/bin/bash
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

# Load FZF if available - respect the trusted ~/.fzf.bash structure
if command -v fzf >/dev/null 2>&1; then
    # In interactive shells, use the trusted ~/.fzf.bash
    if [[ $- == *i* && -f ~/.fzf.bash ]]; then
        source ~/.fzf.bash
    else
        # For non-interactive (like CLAUDECODE), manually source the key parts
        # This preserves the trust legacy of ~/.fzf.bash while enabling non-interactive use
        if [[ -f /usr/share/doc/fzf/examples/completion.bash ]]; then
            source /usr/share/doc/fzf/examples/completion.bash
        fi
    fi
fi

# FZF custom functions
# Note: FZF_EXCLUDE can be set elsewhere if needed
_fzf_compgen_path() { fd --follow $FZF_EXCLUDE . "$1"; }
_fzf_compgen_dir()  { fd --type d --follow $FZF_EXCLUDE . "$1"; }

##############################################################################
# Fallback fzf-history-widget (only if atuin not available)
# When atuin is installed, tools/atuin.sh provides a better session-aware widget
##############################################################################
if [[ $- == *i* ]] && ! command -v atuin >/dev/null 2>&1; then
    fzf-history-widget() {
        local selected histfile="${SHARED_HISTFILE:-$HOME/.bash_history}"
        selected=$(cat "$histfile" | awk '!seen[$0]++' | tac |
            FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS-} --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_CTRL_R_OPTS-} --query=\"${READLINE_LINE}\" +m" fzf)
        local ret=$?
        if [[ -n "$selected" ]]; then
            READLINE_LINE="$selected"
            READLINE_POINT=${#READLINE_LINE}
        fi
        return $ret
    }
    bind -x '"\C-r": fzf-history-widget'
fi
