#!/bin/bash
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

# If atuin is available, let it handle history (loaded via tools/atuin.sh)
# Just set minimal bash history options for compatibility
if command -v atuin >/dev/null 2>&1; then
    export HISTFILE=~/.bash_history
    export HISTSIZE=10000
    export SAVEHIST=10000
    export HISTCONTROL=ignoredups
    # Atuin handles the rest - session tracking, storage, search
    return 0
fi

##############################################################################
# Fallback: Simple shared history (no atuin)
##############################################################################
export HISTFILE=~/.bash_history
export SHARED_HISTFILE=$HISTFILE  # For fzf widget compatibility
export HISTSIZE=100000
export SAVEHIST=100000

shopt -s histappend           # Append to history file instead of overwrite
export HISTCONTROL=ignoreboth # Ignore duplicates and commands starting with space

# Incremental history append (equivalent to zsh INC_APPEND_HISTORY)
# Skip for CLAUDECODE agents - they don't need persistent history
if [[ "$CLAUDECODE" != "1" ]]; then
    _history_append() {
        history -a  # Append new commands to HISTFILE
    }

    # Add to PROMPT_COMMAND (preserve existing hooks)
    if [[ -n "$PROMPT_COMMAND" ]]; then
        PROMPT_COMMAND="$PROMPT_COMMAND; _history_append"
    else
        PROMPT_COMMAND="_history_append"
    fi
fi

# SHARE_HISTORY removed - complex in bash, not essential
# HIST_REDUCE_BLANKS removed - bash doesn't have this
