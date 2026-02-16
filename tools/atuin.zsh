#!/bin/zsh
##############################################################################
# Atuin Integration - Session-aware shell history with fzf UI
##############################################################################
#
# Atuin provides SQLite-backed history with session/directory/host metadata.
# This module initializes atuin with NOBIND (we use fzf for Ctrl+R) and
# provides a custom fzf widget that prioritizes current session history.
#
# The widget shows:
#   1. Last 20 commands from current session (most relevant)
#   2. Global history (everything else, deduped)
#
##############################################################################

# Source atuin env to get it in PATH (installer puts it in ~/.atuin/bin)
[[ -f "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"

# Skip if atuin not installed
command -v atuin >/dev/null 2>&1 || return 0

# Disable atuin's default keybindings - we use fzf
export ATUIN_NOBIND="true"

# Initialize atuin (registers hooks for history recording)
eval "$(atuin init zsh)"

# Only set up fzf widget for interactive shells
[[ -o interactive ]] || return 0

# Session-prioritized fzf history widget
fzf-atuin-history-widget() {
    local selected
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null

    # Build history: session first (last 20), then global (deduped)
    # Using process substitution to combine both sources
    selected=$(
        {
            # Current session commands (most recent 20)
            atuin search --cmd-only --limit 20 --filter-mode session 2>/dev/null
            echo "───────────────────────────────────"  # Visual separator
            # Global history, excluding what's already shown
            atuin search --cmd-only --limit 5000 2>/dev/null
        } | awk '!seen[$0]++' |  # Dedupe while preserving order
        FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS-} --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m" fzf
    )
    local ret=$?

    # Skip the separator line if selected
    if [[ -n "$selected" && "$selected" != "───────────────────────────────────" ]]; then
        LBUFFER="$selected"
    fi
    zle reset-prompt
    return $ret
}

zle -N fzf-atuin-history-widget
bindkey '^R' fzf-atuin-history-widget

# Optional: Ctrl+E for atuin's native TUI (useful for advanced filtering)
bindkey '^E' _atuin_search_widget
