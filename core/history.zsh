#!/bin/zsh
##############################################################################
# History Configuration
##############################################################################
#
# Strategy:
#   1. If atuin is installed → it handles everything (SQLite, session tracking)
#   2. Otherwise → fallback to simple shared history file
#
# Atuin provides session-aware history with proper metadata. The fallback
# is intentionally simple - no temp files, no complex batching.
#
##############################################################################

# If atuin is available, let it handle history (loaded via tools/atuin.zsh)
# Just set minimal zsh history options for compatibility
if command -v atuin >/dev/null 2>&1; then
    export HISTFILE=~/.zsh_history
    export HISTSIZE=10000
    export SAVEHIST=10000
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE
    # Atuin handles the rest - session tracking, storage, search
    return
fi

##############################################################################
# Fallback: Simple shared history (no atuin)
##############################################################################
export HISTFILE=~/.zsh_history
export SHARED_HISTFILE=$HISTFILE  # For fzf widget compatibility
export HISTSIZE=100000
export SAVEHIST=100000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS